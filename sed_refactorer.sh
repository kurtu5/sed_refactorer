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
	-p=*)
	PATTERN="${opt#*=}"
	PATTERN_OPT=True
	shift
	;;
	*)
	;;
esac
done

exit_program() {
	history -a $HISTORY_FILE
	exit
}


main_mode() { case $1 in
	'start')
		main_mode 'options'
		;;
	'prompt')
		echo "main: " ;;
	'options')
		echo "Options are: exit, sed" ;;

	'command')
		case $2 in
		'exit')
			exit_program ;;
		'sed')
			switch_mode 'sed_mode' ;;
		'h'|'help'|'?')
			main_mode 'options';;
		"")
			;;
		*)
			echo "Unknown command"
		esac ;;
	*)
	echo "Unknown method"
	exit ;;
esac; }

sed_mode() { case $1 in
	'start')
		echo "Interactive pattern test"
		echo "Will try against $PATTERN"
		echo ""
		sed_mode 'options'
		history -r $HISTORY_FILE ;;
	'prompt')
		echo "sed: " ;;
	'options')
		echo "Options are:  s/pat/rep/, apply, find, main, history, exit" ;;

	'command')
		case $2 in
		'exit')
			exit_program ;;
		'main')
			switch_mode 'main_mode' ;;
		'find')
			switch_mode 'find_mode' ;;
		'history')
			echo "Note this history only has uniq entries and can't be accessed via !"
			history ;;
		'h'|'help'|'?')
			main_mode 'options';;
		"")
			;;
		*)
			echo "		$PATTERN  with $2 applied"
			echo -n  "		"
			echo "$PATTERN" | sed -e $2
			LAST_SED=$2
			history_uniq "$2"
		esac ;;
	*)
		echo "Unknown method"
		exit ;;
esac; }

find_mode() { case $1 in
	'start')
		find_mode 'options'
		;;
	'prompt')
		echo "find: " ;;
	'options')
		echo "Options are: args(set find args), list(file found), dry(dry run last sed pat), do(refactor all)" ;;

	'command')
		case $2 in
		'args')
			echo 'ex: {find} . -type f -name *.sh {-print|-exec sed ... {}\;}'
			echo "Don't enter in text in parentheses."
			read -p "args: " FIND_ARGS
			echo "find $FIND_ARGS"
			;;
		'sed')
			switch_mode 'sed_mode' ;;
		'h'|'help'|'?')
			find_mode 'options';;
		"")
			;;
		*)
			echo "Unknown command"
		esac ;;
	*)
	echo "Unknown method"
	exit ;;
esac; }

history_mode() { case $1 in
	start)
		sed -ne "s/$2//p" $HISTORY_FILE | history -r -
	

}
history_uniq() {
	local debug=""
	if history | grep -qF "$*"; then
		D && echo "DEBUG $* is not a uniq item in history"
		D && history | tail | sed -e 's/^/DEBUG/'
	else
		history -s "$*"
		D && echo "DEBUG $* is a uniq item in history"
	fi
}

switch_mode() {
	mode=$1
	$mode start
}

switch_mode 'sed_mode'
while [[ true ]]; do
	read -rep "$($mode prompt)" line
	$mode command $line
done
