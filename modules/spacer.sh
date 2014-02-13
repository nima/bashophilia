# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

function :bop:spacer.draw() {
    local pattern="${*:-#}"
    if [ ${#pattern} -gt 0 ] ; then
        local -i repeat=1
        let repeat+=BOP_COLS/${#pattern}
        local spacer=$(eval "printf '${pattern}%.0s' {1..${repeat}}")
        echo "${spacer:0:$BOP_COLS}"
    fi
}

function bop:spacer.init() {
    declare -gi BOP_COLS
    BOP_COLS=$(tput cols)
    [ ${BOP_COLS} -gt 0 ] || BOP_COLS=${COLUMNS:-80}
    bind '"[C": ":bop:spacer.draw ">"\n"'
    bind '"[D": ":bop:spacer.draw "<"\n"'
}
