#!/bin/bash
# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. CDBM - Change Directory Bookmark for bash -={
: ${BOP_CDBM_STORE:=${HOME}/.cdbm}

#. Internals -={
function :bop:cdbm.reset_cursor() {
    tput el
    pwd
    tput cuu1
    tput cuu1
    tput el
}

function :bop:cdbm.save() {
    if [ "${BOP_CDBM[${1^}]}" != "${PWD}" ]; then
        for cdbml in ${!BOP_CDBM[@]}; do
            if [ "${BOP_CDBM[${cdbml}]}" == "${PWD}" ]; then
                BOP_CDBM[${cdbml}]=
            fi
        done
        BOP_CDBM[${1^}]="${PWD}"
    else
        BOP_CDBM[${1^}]=
    fi
    declare -p BOP_CDBM > ${BOP_CDBM_STORE}
    :bop:cdbm.reset_cursor
}

function :bop:cdbm.load() {
    source ${BOP_CDBM_STORE}
    local dir="${BOP_CDBM[${1^}]-${PWD}}"
    if [ -d "${dir}" ]; then
        cd "${BOP_CDBM[${1^}]-${PWD}}"
        :bop:cdbm.reset_cursor
    fi
}

function :bop:cdbm.tab() {
    source ${BOP_CDBM_STORE}
    local dir="${OLDPWD}"
    if [ -d "${dir}" ]; then
        cd - >/dev/null
        :bop:cdbm.reset_cursor
    fi
}

function :bop:cdbm.dump() {
    source ${BOP_CDBM_STORE}
    local cdbml
    for cdbml in ${!BOP_CDBM[@]}; do
        echo "${cdbml} ${BOP_CDBM[$cdbml]}";
    done
}
#. }=-

function bop:cdbm.init() {
    declare -gA BOP_CDBM
    if [ -f ${BOP_CDBM_STORE} ]; then
        source ${BOP_CDBM_STORE}
    else
        touch ${BOP_CDBM_STORE}
    fi

    local cdbml
    for cdbml in {a..z}; do
        bind '"\e'${cdbml^}'":" :bop:cdbm.save '${cdbml^}'\n"'
        bind '"\e'${cdbml,}'":" :bop:cdbm.load '${cdbml^}'\n"'
    done
    bind '"\e\t":" :bop:cdbm.tab\n"'
    bind '"\e?":"  :bop:cdbm.dump\n"'
}

function bop:cdbm.prompt() {
    source ${BOP_CDBM_STORE}

    local cdbm_letter='.'
    local cdbm_relpath=
    local -i cdbmsrp=1024 #. BOP_CDBM shortest relpath
    for cdbml in ${!BOP_CDBM[@]}; do
        if [ ${#cdbml} -eq 1 ]; then
            local cdbmrp="${PWD#${BOP_CDBM[${cdbml}]}}"
            if [ "${cdbmrp}" != "${PWD}" -a ${#cdbmrp} -lt ${cdbmsrp} ]; then
                cdbm_letter=${cdbml}
                cdbm_relpath="${cdbmrp}"
                cdbmsrp="${#cdbmrp}"
            fi
        else
            unset BOP_CDBM[$cdbml];
        fi
    done

    local prompt=
    case ${cdbm_letter}:${#cdbm_relpath} in
        .:0)
            prompt+="${BOP_COLORS[Blue]}\w"
        ;;
        *:0)
            prompt+="${BOP_COLORS[LightGreen]}${cdbm_letter}"
        ;;
        *:*)
            prompt+="${BOP_COLORS[LightGreen]}${cdbm_letter}"
            prompt+="${BOP_COLORS[LightBlue]}${BOP_DELIM}${cdbm_relpath}"
        ;;
    esac

    printf "${prompt}"
}
#. }=-
