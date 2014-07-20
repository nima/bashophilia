#!/bin/bash
# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. CDBM - Change Directory Bookmark for bash -={
: ${BOPH_CDBM_STORE:=${HOME}/.cdbm}

#. Internals -={
function :boph:cdbm.reset_cursor() {
    READLINE_LINE="#. Now in $(pwd)"

    #. Without (bind) `-x':
    #tput el
    #pwd
    #tput cuu1
    #tput cuu1
    #tput el
}

function :boph:cdbm.save() {
    source ${BOPH_CDBM_STORE}

    if [ "${BOPH_CDBM[${1^}]}" != "${PWD}" ]; then
        for cdbml in ${!BOPH_CDBM[@]}; do
            if [ "${BOPH_CDBM[${cdbml}]}" == "${PWD}" ]; then
                BOPH_CDBM[${cdbml}]=
            fi
        done
        BOPH_CDBM[${1^}]="${PWD}"
    else
        BOPH_CDBM[${1^}]=
    fi
    declare -p BOPH_CDBM|tr -d "'" > ${BOPH_CDBM_STORE}
    :boph:cdbm.reset_cursor
}

function :boph:cdbm.load() {
    source ${BOPH_CDBM_STORE}

    local dir="${BOPH_CDBM[${1^}]-${PWD}}"
    if [ -d "${dir}" ]; then
        cd "${BOPH_CDBM[${1^}]-${PWD}}"
        :boph:cdbm.reset_cursor
    fi
}

function :boph:cdbm.tab() {
    source ${BOPH_CDBM_STORE}

    local dir="${OLDPWD}"
    if [ -d "${dir}" ]; then
        cd - >/dev/null
        :boph:cdbm.reset_cursor
    fi
}

function :boph:cdbm.dump() {
    source ${BOPH_CDBM_STORE}

    local cdbml
    for cdbml in ${!BOPH_CDBM[@]}; do
        echo "${cdbml} ${BOPH_CDBM[$cdbml]}";
    done
}
#. }=-

function boph:cdbm.init() {
    declare -gA BOPH_CDBM

    if [ -f ${BOPH_CDBM_STORE} ]; then
        source ${BOPH_CDBM_STORE}
    else
        touch ${BOPH_CDBM_STORE}
    fi

    local cdbml
    for cdbml in {a..z}; do
        bind -x '"\e'${cdbml^}'":" :boph:cdbm.save '${cdbml^}'"'
        bind -x '"\e'${cdbml,}'":" :boph:cdbm.load '${cdbml^}'"'
    done
    bind -x '"\e\t":" :boph:cdbm.tab"'
    bind -x '"\e?":"  :boph:cdbm.dump"'
}

function boph:cdbm.prompt() {
    source ${BOPH_CDBM_STORE}

    local gitted
    local cdbm_letter='.'
    local cdbm_relpath=
    local -i cdbmsrp=1024 #. BOPH_CDBM shortest relpath
    for cdbml in ${!BOPH_CDBM[@]}; do
        if [ ${#cdbml} -eq 1 ]; then
            local cdbmrp="${PWD#${BOPH_CDBM[${cdbml}]}}"
            if [ "${cdbmrp}" != "${PWD}" -a ${#cdbmrp} -lt ${cdbmsrp} ]; then
                cdbm_letter=${cdbml}
                gitted=$(git rev-parse --show-toplevel 2>/dev/null)
                if [ $? -ne 0 ]; then
                    cdbm_relpath="${cdbmrp}"
                #else
                #    cdbm_relpath="${cdbmrp//${gitted}}"
                fi
                cdbmsrp="${#cdbmrp}"
                break
            fi
        else
            unset BOPH_CDBM[$cdbml];
        fi
    done

    local prompt=
    case ${cdbm_letter}:${#cdbm_relpath} in
        .:0)
            gitted=$(git rev-parse --show-toplevel 2>/dev/null)
            if [ $? -eq 0 ]; then
                prompt+="${BOPH_COLORS[Blue]}${gitted}"
            else
                prompt+="${BOPH_COLORS[Blue]}${PWD}"
            fi
        ;;
        *:0)
            prompt+="${BOPH_COLORS[LightGreen]}${cdbm_letter}"
        ;;
        *:*)
            prompt+="${BOPH_COLORS[LightGreen]}${cdbm_letter}"
            prompt+="${BOPH_COLORS[LightBlue]}${BOPH_DELIM}${cdbm_relpath}"
        ;;
    esac

    printf "${prompt}"
}
#. }=-
