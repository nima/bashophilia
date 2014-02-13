# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

function boph:title.callback() {
    case ${TERM} in
        xterm*|st*)
            local TitleStart="\033]0;"
            local TitleEnd="\007"
            local eth0=0.0.0.0
            if which ip>/dev/null 2>&1; then
                eth0=$(ip addr show eth0|awk '$1~/\<inet\>/{print$2;exit}')
            fi
            if [ ${ENV_IS_X} -eq 1 ]; then
                : FIXME
                TITLE="[ ${OS_HOST}|${eth0}@${PROFILE} $OS_VENDOR-$OS_VERSION:$OS_ARCH-$HW_VENDOR ]"
                Title="${TitleStart}${TITLE}${TitleEnd}"
            fi
            echo -ne "${Title}"
        ;;
    esac
}
