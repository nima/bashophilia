# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. Mandatory BOPH globals and modules -={
#. Configuration -={
BOPH_ROOT=${HOME}/.config/bashophilia
BOPH_MODS=${HOME}/.config/bashophilia/modules
BOPH_DELIM=:
#. Enable the modules of your choice, in the order of your choice
declare -a BOPH_MODULES
BOPH_MODULES=(
    spacer
    cdbm
    ssh
    git
    timer
    exit
)
#. Amend if necessary (user-configuration)
[ ! -r ${HOME}/.boprc ] || source ${HOME}/.boprc

#. Add core modules in position
BOPH_MODULES=( preexec ${BOPH_MODULES[@]} )
#. }=-
#. Internals -={
source ${BOPH_MODS}/color.sh

function :boph:md5() {
    local -i e=1

    if [ -e "${1}" ]; then
        md5sum $1|awk '{print$1}'
        e=0
    fi

    return $e
}

function :boph:declared() {
    local -i e=1

    if [ $# -eq 1 ]; then
        local fn="$1"
        declare -F ${fn} >/dev/null
        e=$?
    fi

    return $e
}
function :boph:report() {
    if [ $1 -eq 0 ]; then
        echo PASS
    else
        echo FAIL
    fi
}
#. }=-

function boph:init() {
    local fn
    local module
    printf "Initializing BashOPhile...\n"

    for module in ${BOPH_MODULES[@]}; do
        source ${BOPH_MODS}/${module}.sh
        fn=boph:${module}.init
        if :boph:declared ${fn}; then
            printf " * Initializing ${module}..."
            ${fn}
            :boph:report $?
        fi
    done

    #. This is out of place, but just nice to have
    bind Space:magic-space
}

function boph:prompt() {
    local -i e=$?

    PS1=
    local BOPH_PWD=$(readlink -f "${PWD}")
    local fn
    local ps1
    local module
    local delim="${BOPH_COLORS[Cyan]}${BOPH_DELIM}"
    for module in ${BOPH_MODULES[@]}; do
        fn=boph:${module}.terminate
        if :boph:declared ${fn}; then
            ${fn} $e
        fi

        fn=boph:${module}.prompt
        if :boph:declared ${fn}; then
            ps1="$(${fn} $e)"
            if [ ${#ps1} -gt 0 ]; then
                PS1+="${delim}"
                PS1+="${ps1}"
            fi
        fi
    done

    PS1="${PS1:${#delim}}${BOPH_COLORS[Cyan]}\\\$${BOPH_COLORS[ResetColor]} "
}

boph:init
export PROMPT_COMMAND=boph:prompt
#. }=-
