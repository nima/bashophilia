# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-


#. -={
function bop:timer.init() {
    declare -gi BOP_TIMER_ELAPSED
}

function bop:timer.callback() {
    if [ ! -v BOP_TIMER_SECONDS ]; then
        declare -gi BOP_TIMER_SECONDS
        BOP_TIMER_SECONDS=${SECONDS}
    else
        ((BOP_TIMER_ELAPSED=SECONDS-BOP_TIMER_SECONDS))
        unset BOP_TIMER_SECONDS
        tput el
    fi
}

function bop:timer.prompt() {
    printf "${BOP_COLORS[Green]}${BOP_TIMER_ELAPSED}"
}

#. }=-
