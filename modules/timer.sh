# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. -={
function boph:timer.init() {
    declare -gi BOPH_TIMER_ELAPSED
    BOPH_TIMER_ELAPSED=0
}

function boph:timer.preexec() {
    declare -gi BOPH_TIMER_SECONDS
    BOPH_TIMER_SECONDS=$SECONDS
    tput el
}

function boph:timer.postexec() {
    ((BOPH_TIMER_ELAPSED=SECONDS-BOPH_TIMER_SECONDS))
    unset BOPH_TIMER_SECONDS
}
#. }=-

function boph:timer.prompt() {
    printf "${BOPH_COLORS[Green]}${BOPH_TIMER_ELAPSED}"
}
