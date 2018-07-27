# sed_refactorer.sh

### Usage
 You can simply call `./sed_refactorer.sh` on the CLI and use it's menus to start building a sedscript for refactoring.

 Alternately you can specify CLI opts
	-p="some_code_pattern_that_needs_refactoring"  ex. p="oldmethod(self, val)"
	-s="initial_sed_script"  ex. -s="s/oldmethod/newmethod/g"
	-f="find_arguments_wiht_out_print_exec"   ex.  -f=". -type f -name *.py"
	-m="initial_menu"        ex. -m="sed_mode"

 Example:
	Here I want to change `others['bar']` to `sib('bar')` in my code for python scripts
```bash
bash$ ./sed_refactorer.sh -p="foo.others['bar'].do()" -s="s/\.others\['\([^']*\)'\]/.sib('\1')/" -f=". -type f -name *.py" -m='find_mode'

Find Menu
        Set find args, list matching files, do dry run, apply last sed pattern

Commands are: args, list, dry, apply.  Menue: sed, main, exit

find: dry
  ... does a dry run on all files ..

find: final
  ... changes all files with sed script ...

find: exit

# Check the diff to see if it all refactored properly
bash$ git diff

```

The interactive portion of the script has readline completion in the various menus and the uniq last history is saved in .$0.history


### Todo
  Mostly clean up the use of /tmp
