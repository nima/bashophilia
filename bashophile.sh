# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. Mandatory BOP globals and modules -={
#. Configuration -={
BOP_ROOT=${HOME}/.config/bop
BOP_MODS=${HOME}/.config/bop/modules
BOP_DELIM=:
#. Enable the modules of your choice, in the order of your choice
declare -a BOP_MODULES=(
    spacer
    cdbm
    git
    timer
)

#. Amend if necessary (user-configuration)
[ ! -r ${HOME}/.boprc ] || source ${HOME}/.boprc
#. }=-
#. Sanity Eject Button -={
[ -e ${BOP_ROOT} ] || exit 1
source ${BOP_MODS}/color.sh

#. Add core modules in position
BOP_MODULES=( preexec ${BOP_MODULES[@]} )
#. }=-
#. Internals -={
function :bop:declared() {
    local -i e=1

    if [ $# -eq 1 ]; then
        local fn="$1"
        declare -F ${fn} >/dev/null
        e=$?
    fi

    return $e
}
function :bop:report() {
    if [ $1 -eq 0 ]; then
        echo PASS
    else
        echo FAIL
    fi
}
#. }=-

function bop:init() {
    local fn
    local module
    printf "Initializing BashOPhile...\n"

    for module in ${BOP_MODULES[@]}; do
        source ${BOP_MODS}/${module}.sh
        fn=bop:${module}.init
        if :bop:declared ${fn}; then
            printf " * Initializing ${module}..."
            ${fn}
            :bop:report $?
        fi

        fn=bop:${module}.callback
        if :bop:declared ${fn}; then
            printf " * Registering pre-exec hook for ${module}..."
            bop:preexec.register ${module}
            :bop:report $?
        fi
    done

    #. This is out of place, but just nice to have
    bind Space:magic-space
}

function bop:prompt() {
    local -i e=$?

    PS1=
    local fn
    local module
    for module in ${BOP_MODULES[@]}; do
        fn=bop:${module}.prompt
        if :bop:declared ${fn}; then
            ps1="$(${fn})"
            if [ ${#ps1} -gt 0 ]; then
                PS1+=${ps1}${BOP_COLORS[Cyan]}${BOP_DELIM}
            fi
        fi
    done

    PS1+="${BOP_COLORS[Cyan]}\$${BOP_COLORS[ResetColor]} "
}

bop:init
export PROMPT_COMMAND=bop:prompt
#. }=-
