#!/bin/ksh
#  Victxrlarixs
#  http://w2.syronex.com/jmr/linux/dot-kshrc.html
# .kshrc

#set shell option
set -o emacs
# aliases
alias x=startx \
    cl="tput clear" \
    ll="ls -lh" \
    la="ls -a" \
    v=vi \
    vw=view \
    e="emacs -nw" \
    j=java \
    jc=javac \
    xc="xclock -update 1" \
    startx="startx /usr/X11R6/bin/mwm" \
    nslookup="nslookup -sil" \
    latex="latex -interaction=nonstopmode" \
    pla=pdflatex
# setup direction keys (for use with emacs edit mode)
 alias __A='^P' __B='^N' __C='^F' __D='^B'

# setup prompt
who=' $ '
# text color for root is red, black for others
black="\\033[0;39m"
red="\\033[0;31m"
colr=$black
id | grep '=0(' >/dev/null && who=' # ' && colr=$red

print -ne $colr
trap 'print -ne $black' EXIT

case $TERM in
    xterm*)
        PS1='^[]0;${LOGNAME}@${HOSTNAME}: ${PWD}^G${LOGNAME}@${HOSTNAME} !${who}'
        ;;
    *)
        PS1='${LOGNAME}@${HOSTNAME} !${who}'
        ;;
esac
