#!/usr/bin/env sh
NOANIMATIONS=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

# $1 might be --force
if [ "$1" = "--force" ] ; then
	NOANIMATIONS=1
fi

if [ "$NOANIMATIONS" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    exit
fi
hyprctl reload
