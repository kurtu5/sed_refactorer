#!/bin/bash
#
#  Reactor code with sed
#



debug=true
D() { [[ $debug == "true" ]]; }

HISTORY_FILE=$(basename $0 | sed -e 's/\(.*\)\.sh/\.\1\.history/')
for opt in "$@"; do
case $opt in
	-c)
	CONFIG=True
	shift
	;;
	-m=*)
	MENU="${opt#*=}"
	shift
	;;
	-p=*)
	PATTERN="${opt#*=}"
	shift
	;;
	-s=*)
	SED_SCRIPT="${opt#*=}"
	shift
	;;
	-f=*)
	FIND_ARGS="${opt#*=}"
	shift
	;;
	*)
	;;
esac
done

exit_mode() {
self=${FUNCNAME[0]}
case $1 in
	'start_mode')
		exit
		;;
	'*')
		echo "Unknown method: $1"
		;;
esac; }

main_mode() {
self=${FUNCNAME[0]}
case $1 in
	'start_mode')
		echo ""
		echo "Main menu"
		echo ""
		$self 'options'
		echo ""
		history_mode start $self
		;;
	'switch_mode')
		history_mode stop $self
		set_mode $2
		;;
	'prompt')
		echo "main: " ;;
	'options')
		echo "Sub menus: sed, find, exit" ;;
	'help')
		cat << HELP

The Main menu is simply the general documentation on how to use this program

	Sed Menu  : Allows interactive generation of sed script to change a pattern
	Find Menu : Allows you do dry runs and final runs of sed script on specified files

Commands:

	<command>	- Each menu has specific commands that apply to it's operation
	h|?		- Shows Commands and Menus
	help		- Menu specific detailed help screen

Menus:
	<menu>		- Switches to the specific menu

HELP
		;;
	'command')
		case "$2" in
		'sed')
			$self switch_mode 'sed_mode' ;;
		'find')
			$self switch_mode 'find_mode' ;;
		'exit')
			$self switch_mode 'exit_mode' ;;
		'h'|'?')
			$self 'options';;
		'help')
			$self 'help';;
		"")
			;;
		*)
			echo "Unknown command: $2"
		esac ;;
	*)
	echo "Unknown method: $1"
	exit ;;
esac; }

sed_mode() {
local debug=""
D && echo "sed_mode 1=$1 2=$2 3=$3 4=$4"
self=${FUNCNAME[0]}
case $1 in
	'start_mode')
		echo ""
		echo "Sed menu"
		echo "	Interactive pattern test"
		echo "	Will try against $PATTERN"
		echo ""
		$self 'options'
		echo ""
		history_mode start $self
		;;
	'switch_mode')
		history_mode stop $self
		set_mode $2
		;;
		
	'prompt')
		echo "sed: " ;;
	'options')
		echo "Commands are: pattern, <sed script>, help,h,?  Menus: main, find, exit" ;;
	'help')
		cat << HELP

The Sed Menu allows you to run sed scripts against a pattern for iterative construction.

Commands:

	<sed script>	- Applies against pattern
	pattern		- Prompts for new pattern to use

	h|?		- Shows Commands and Menus
	help		- This screen
Menus:
	<menu>		- Returns to the specific menu

HELP
		;;

	'command')
		case $2 in
		'main')
			$self switch_mode 'main_mode' ;;
		'find')
			$self switch_mode 'find_mode' ;;
		'exit')
			$self switch_mode 'exit_mode' ;;
		'help')
			$self 'help' ;;
		'h'|'?')
			$self 'options';;
		'p'|'pat'|'pattern')
			echo -n "Enter in new pattern: "
			read -r PATTERN
			;;
		"")
			;;
		*)
			# Apply sed pattern
			echo "		$PATTERN  with $2 applied"
			echo -n  "		"
			echo "$PATTERN" | sed -e "$2"
			SED_SCRIPT=$2
			history_uniq "$2"
		esac ;;
	*)
		echo "Unknown method: $1"
		exit ;;
esac; }

find_args_mode() {
self=${FUNCNAME[0]}
case $1 in
	'start_mode')
		history_mode start $self
		echo "Specify arguments in {} for find. Don't include find,print,exec parts. "
		echo "Ex: find {. -name *.sh -type f } -print | -exec cmd.."
		;;
	'switch_mode')
		history_mode stop $self
		set_mode $2
		;;
	'prompt')
		echo "find args: " ;;
	'command')
		FIND_ARGS=$2
		$self switch_mode 'find_mode' ;;
	*)
	echo "Unknown method: $1"
	exit ;;
esac; }
find_mode() {
self=${FUNCNAME[0]}
case $1 in
	'start_mode')
		echo ""
		echo "Find Menu"
		echo "	Set find args, list matching files, do dry run, apply last sed pattern"
		echo ""
		$self 'options'
		echo ""
		history_mode start $self
		;;
	'switch_mode')
		history_mode stop $self
		set_mode $2
		;;
	'prompt')
		echo "find: " ;;
	'options')
		echo "Commands are: args, list, dry, apply.  Menue: sed, main, exit" ;;
	'help')
		cat << HELP

The Find Menu allows you to run sed scripts against files and set the find options to find them

Commands:

	args		- Prompts for arugments for find command
	list		- Runs find with the arguments to show matched files
	dry		- Performs a dry run of the sed script with find
	final		- Performs a final run of the sed script with find

	h|?		- Shows Commands and Menus
	help		- This screen
Menus:
	<menu>		- Returns to the specific menu

HELP
		;;
	'command')
		case $2 in
		'args')
			$self switch_mode 'find_args_mode' ;;
		'list')
			echo "Running: find $FIND_ARGS -print | less"
			find $FIND_ARGS -print
			;;
		'dry')
			echo "Dry running: find $FIND_ARGS -exec echo Filename: {} \; -exec sed -e \"$SED_SCRIPT\" {} \; | less"
			find $FIND_ARGS -exec echo Filename: {} \; -exec sed -e "$SED_SCRIPT" {} \; | less
			;;
		'final')
			echo "Running: find $FIND_ARGS -exec echo Filename: {} \; -exec sed -ie \"$SED_SCRIPT\" {} \; | less"
			find $FIND_ARGS -exec echo Filename: {} \; -exec sed -ie "$SED_SCRIPT" {} \; | less
			;;
		'main')
			$self switch_mode 'main_mode' ;;
		'sed')
			$self switch_mode 'sed_mode' ;;
		'exit')
			$self switch_mode 'exit_mode' ;;
		'h'|'?')
			$self 'options';;
		'help')
			$self 'help';;
		"")
			;;
		*)
			echo "Unknown command: $2"
		esac ;;
	*)
	echo "Unknown method: $1"
	exit ;;
esac; }

history_mode() { 
local debug=""
self=${FUNCNAME[0]}
touch $HISTORY_FILE
case $1 in
	start)
		rm  -f /tmp/l
		# Load mode lines from history file
		D && echo "Loading history for mode $2"
		sed -ne "s/$2[ \t]*[^ \t]*[ \t]*//p" $HISTORY_FILE > /tmp/l
		D && echo "history:" ; D && cat /tmp/l
		history -c
		history -r /tmp/l
		;;
	stop)
		# Save current history as mode lines into history file
		D && echo "Saving history for mode $2"
		rm -f /tmp/s
		history | sed -e "s/^/$2\t/" > /tmp/s
		cat $HISTORY_FILE | sed -e "/$2[ \t]*/d" >> /tmp/s
		cp /tmp/s $HISTORY_FILE
		;;
	*)
		echo "Unknown method: $1"
		;;
esac; }

history_uniq() {
	local debug=""
	if history | grep -qF -e "$*"; then
		D && echo "DEBUG $* is not a uniq item in history"
		D && history | tail | sed -e 's/^/DEBUG/'
	else
		echo "$*" > /tmp/h
		history -r /tmp/h
		#history -s "$*"
		D && echo "DEBUG $* is a uniq item in history"
	fi
}

history_args() {
	local debug=""
	# Insert command line args into history file
	# Crufty
	D && echo 1=$1 2=$2 3=$3
	[[ "$2" == "" ]] && return 
	if ! grep $1 $HISTORY_FILE | grep -qF -e "$2" ; then
		 # not in history
		echo "$1 9000 $2" >> $HISTORY_FILE		
	fi

}

history_args 'sed_mode' "$SED_SCRIPT"
history_args 'find_mode' "$FIND_ARGS"

set_mode() {
	mode=$1
	$mode start_mode
}




[[ "$MENU" == "" ]] && MENU='main_mode'
set_mode $MENU
while [[ true ]]; do
	read -rep "$($mode prompt)" line
	history_uniq "$line"
	set -f
	$mode command "$line"
	set +f
done
