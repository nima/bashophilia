# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. BOP_PREEXEC -={

#. Internals -={
:bop:preexec.run() {
    ${BOP_PREEXEC[ALWAYS]}
    if [ $# -ge 1 ]; then
        for key in $@; do
            ${BOP_PREEXEC[${key}]}
        done
    else
        for key in ${!BOP_PREEXEC[@]}; do
            ${BOP_PREEXEC[${key}]}
        done
    fi
}

:bop:preexec() {
    #. do nothing if completing
    if [ -z "$COMP_LINE" ]; then
        local cmd=$(history 1 | sed -e "s/^[ ]*[0-9]\+[ ]\+//g");
        :bop:preexec.run "${cmd}"
    fi
}
#. }=-

bop:preexec.register() {
    local -i e=1

    if [ $# -eq 1 ]; then
        local module=$1
        BOP_PREEXEC[ALWAYS]+=" bop:${module}.callback"
        e=0
    elif [ $# -gt 1 ]; then
        local key
        key=$1
        shift
        BOP_PREEXEC[${key}]="$*"
        e=0
    fi

    return $e
}

bop:preexec.init() {
    declare -gA BOP_PREEXEC
    trap ':bop:preexec' DEBUG
}

#. }=-
