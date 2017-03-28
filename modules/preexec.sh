# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. BOPH_PREEXEC -={
#. Internals -=
:boph:preexec.run() {
    local fntype
    if [ "${BOPH_PERSIST:-off}" == "on" ]; then
        BOPH_PERSIST=off
        fntype=preexec
    else
        BOPH_PERSIST=on
        fntype=postexec
    fi

    local fn module
    for module in ${BOPH_MODULES[@]}; do
        fn=boph:${module}.${fntype}
        if :boph:declared ${fn}; then
            ${fn}
        fi
    done
}

:boph:preexec() {
    #. do nothing if completing, otherwise...
    if [ "${COMP_LINE:-UnsetOrNull}" == 'UnsetOrNull' ]; then
        local cmd=$(history 1 | sed -e "s/^[ ]*[0-9]\+[ ]\+//g");
        :boph:preexec.run
    fi
}
#. }=-

boph:preexec.terminate() {
    BOPH_PERSIST=on
}

boph:preexec.init() {
    declare -A BOPH_PREEXEC
    declare BOPH_PERSIST=on
    trap ':boph:preexec' DEBUG
}

#. }=-
