#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
# Not supported in the "fish" shell.
(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias cdwm="nano ~/suckless/dwm/config.h"
alias mdwm="cd ~/suckless/dwm; sudo make clean install; cd -"

PS1='[\u@\h \W]\$ '
