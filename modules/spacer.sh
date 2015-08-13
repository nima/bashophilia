# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

function :boph:spacer.draw() {
    declare -i BOPH_COLS
    BOPH_COLS=$(tput cols)
    [ ${BOPH_COLS} -gt 0 ] || BOPH_COLS=${COLUMNS:-80}

    local pattern="${*:-#}"
    if [ ${#pattern} -gt 0 ] ; then
        local -i repeat=1
        let repeat+=BOPH_COLS/${#pattern}
        local spacer=$(eval "printf '${pattern}%.0s' {1..${repeat}}")
        echo "${spacer:0:$BOPH_COLS}"
    fi
}

function boph:spacer.init() {
    bind -x '"[C": ":boph:spacer.draw \>"'
    bind -x '"[D": ":boph:spacer.draw \<"'
}
