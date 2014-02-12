###### vim: tw=0:ts=4:sw=4:et:ft=markdown

# CDBM (Change Directory Bookmarks)
_A bookmark manager for your cli_

Ever want to book mark a directory you're in at the cli? specially those really
really long and difficult-to-remember ones?  How about even the short ones that
you use really really often?

Well I did, and so here it is - a short bash script to source in your `~/.bashrc`
and enjoy 26 shortcuts:

## Requirements
This was written for the bourne-again shell (`bash`), however it can easily be
adapted to `zsh` (send me a pull request!).

## Installation

```bash
    cp dot.bash_cdbm ~/.bash_cdbm
```

## Usage

* Save the current `pwd` to a bookmark with `<ALT>+<SHIFT>+[a-z]`
* Load it up with `<ALT>+[a-z]`

```bash
    #. Let's try it out:
	/var/tmp$ source dot.bash_profile_eg
	/var/tmp$ 

	#. Create a bookmark:
	/var/tmp$ <ALT>+<SHIFT>+t
	T$ 

	#. Let's now do some work there first:
	T$ mkdir -p www/yyy
	T$ cd www/yyy
	T:/www/yyy$

	#. And now save another bookmark:
	T:/www/yyy$ <ALT>+<SHIFT>+y
	Y$ 

	#. Now let's move back to `/var/tmp' or `T':
	Y$ <ALT>+t
	T$ 

	#. ...and back to `Y':
	T$ <ALT>+y
	Y$ 

	#. ...and back to `t' again, this time via the *last* buffer:
	Y$ <ALT>+<TAB>
	T$ <ALT>+<TAB>
	Y$ <ALT>+<TAB>
	T$ <ALT>+<TAB>
	Y$ 

	#. Finally, to delete a book mark, save it again at the path you saved it at
	Y$ <ALT>+<SHIFT>+y
	/var/tmp/www/yyy$ 
```
