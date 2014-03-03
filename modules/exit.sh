# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

function boph:exit.prompt() {
    e=$1

    local exitstatus
    case $e in
        0)   exitstatus="${BOPH_COLORS[Green]}${e}";;
        127) exitstatus="${BOPH_COLORS[Yellow]}^?";;
        130) exitstatus="${BOPH_COLORS[Yellow]}^C";;
        148) exitstatus="${BOPH_COLORS[Yellow]}^Z";;
        *)   exitstatus="${BOPH_COLORS[Red]}${e}";;
    esac
    printf "${exitstatus}"
}
