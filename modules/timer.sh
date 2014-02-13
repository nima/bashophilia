# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-


#. -={
function boph:timer.init() {
    declare -gi BOPH_TIMER_ELAPSED
}

function boph:timer.callback() {
    if [ ! -v BOPH_TIMER_SECONDS ]; then
        declare -gi BOPH_TIMER_SECONDS
        BOPH_TIMER_SECONDS=${SECONDS}
    else
        ((BOPH_TIMER_ELAPSED=SECONDS-BOPH_TIMER_SECONDS))
        unset BOPH_TIMER_SECONDS
        tput el
    fi
}

function boph:timer.prompt() {
    printf "${BOPH_COLORS[Green]}${BOPH_TIMER_ELAPSED}"
}

#. }=-
