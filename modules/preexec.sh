# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. BOPH_PREEXEC -={

#. Internals -={
:boph:preexec.run() {
    ${BOPH_PREEXEC[ALWAYS]}
    if [ $# -ge 1 ]; then
        for key in $@; do
            ${BOPH_PREEXEC[${key}]}
        done
    else
        for key in ${!BOPH_PREEXEC[@]}; do
            ${BOPH_PREEXEC[${key}]}
        done
    fi
}

:boph:preexec() {
    #. do nothing if completing
    if [ -z "$COMP_LINE" ]; then
        local cmd=$(history 1 | sed -e "s/^[ ]*[0-9]\+[ ]\+//g");
        :boph:preexec.run "${cmd}"
    fi
}
#. }=-

boph:preexec.register() {
    local -i e=1

    if [ $# -eq 1 ]; then
        local module=$1
        BOPH_PREEXEC[ALWAYS]+=" boph:${module}.callback"
        e=0
    elif [ $# -gt 1 ]; then
        local key
        key=$1
        shift
        BOPH_PREEXEC[${key}]="$*"
        e=0
    fi

    return $e
}

boph:preexec.init() {
    declare -gA BOPH_PREEXEC
    trap ':boph:preexec' DEBUG
}

#. }=-
