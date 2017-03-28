# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

declare -i BOPH_TIMER_SECONDS=0

#. -={
function boph:timer.init() {
    declare -i BOPH_TIMER_ELAPSED
    BOPH_TIMER_ELAPSED=0
}

function boph:timer.preexec() {
    ((BOPH_TIMER_SECONDS=SECONDS))
    tput el
}

function boph:timer.postexec() {
    : ${BOPH_TIMER_SECONDS:=0}
    ((BOPH_TIMER_ELAPSED=SECONDS-BOPH_TIMER_SECONDS))
}
#. }=-

function boph:timer.prompt() {
    printf "${BOPH_COLORS[Green]}${BOPH_TIMER_ELAPSED}"
}
