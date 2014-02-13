###### vim: tw=0:ts=4:sw=4:et:ft=markdown

# Bashophilia
_A bookmark manager for your cli, and more_

Bashophilia is a modular framework for configuring your CLI experience in bash.

It provides powerful yet simple bookmark functionality, dynamic and configurable
prompt, title setting of your X terminal, and other sweet treats like information
about your git repository.

Each feature is made available via a module which you can disable/enable by the
flick of a switch.

## Requirements
This was written for the bourne-again shell (`bash`), however it can easily be
adapted to `zsh` (send me a pull request!).

## Installation

```bash
mkdir -p ~/.config
cd ~/.config
git clone https://github.com/nima/bashophilia.git
```

And then just add the following line to your `~/.bashrc` or `~/.bash_profile`:
```bash
source ~/.config/bashophilia/bashophile.sh
```

## Configuration
You don't need to do any configuration, as bashophilia will work out of the box,
however if you later decide to change some settings, or write your own modules,
simply drop in a `~/.boprc':

```bash
cp share/dot.boprc ~/.boprc
```

In there, you can configure the delimiter for the prompt tokens (some modules
provide functionality for amending the shell prompt):

```bash
#. Pick your delimiter of choice
BOP_DELIM=:
```

You can also configure which modules are active:
```bash
#. Enable the modules of your choice
declare -a BOP_MODULES=(
    spacer
    cdbm
    git
    timer
)
```

At the time of this writing, bashophile supports 4 modules, and these will be
covered nexd.

## Features

### Spacer
Throw in a line accross the terminal with `<ALT>+<Left>` and `<ALT>+<Right>`. The
idea was taken directly from https://github.com/LuRsT/hr.

### CDBM - The Change-Directory Bookmark Manager
Ever want to book mark a directory you're in at the cli? specially those really
really long and difficult-to-remember ones?  How about even the short ones that
you use really really often?

Well I did, and so here it is - a short bash script to source in your `~/.bashrc`
and enjoy 26 shortcuts:

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
### Git
This module modifies the prompt if you happen to cd into a git repository.  It was forked
from https://github.com/magicmonty/bash-git-prompt, and amended to suit.

### Timer
This module modifies the prompt with the number of seconds elapsed on each command executed.
