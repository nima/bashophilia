#!/bin/bash
# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. SSH - Show hostnames when on remote host -={
function boph:ssh.prompt() {
    if [ "${SSH_CONNECTION:-UnsetOrNull}" != 'UnsetOrNull' ]; then
        local prompt="${BOPH_COLORS[LightRed]}@${BOPH_COLORS[Red]}\h"
        printf "${prompt}"
    fi
}
#. }=-
