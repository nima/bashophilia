# vim: tw=0:ts=4:sw=4:et:ft=bash
# -*- coding: UTF-8 -*-

#. GIT -={

#. Internals -={
function :bop:git.isrepo() {
    local e=1

    local gitrepo=$PWD
    while [ ! -d "${gitrepo}/.git" -a "${gitrepo}" != '/' ]; do
        gitrepo=$(coreutils readlink -f "${gitrepo}/..")
    done

    if [ "${gitrepo}" != '/' ]; then
        echo "${gitrepo}"
        e=0
    fi

    return $e
}

function :bop:git.status() {
    local -i e=1

    local gitrepo
    gitrepo=$(:bop:git.isrepo)
    if [ $? -eq 0 ]; then
        local sha1
        local tag
        local title
        local branch
        branch=$(git symbolic-ref HEAD 2>/dev/null)
        if [ $? -eq 0 ]; then
            branch="$(basename ${branch})"
            title="${branch}"
        else
            tag=$(git describe --exact-match 2>/dev/null)
            if [ $? -eq 0 ]; then
                title="t:${tag}"
            else
                sha1=$(git rev-parse --short HEAD)
                title="h:${sha1}"
            fi
        fi

        local -i staged=$(git diff --name-status --staged | awk '$1!~/U/{i++};END{print(i)}')
        local -i changed=$(git diff --name-status | awk '$1!~/U/{i++};END{print(i)}')
        local -i conflicts=$(git diff --name-status --staged | awk '$1~/U/{i++};END{print(i)}')
        local -i untracked=$(git ls-files --others --exclude-standard|wc -l)

        local -i clean=0
        (( staged + changed + conflicts + untracked )) || clean=1

        local -i ahead=0
        local -i behind=0
        if [ -n "${branch}" ]; then
            local remote_name
            remote_name="$(git config branch.${branch}.remote)"
            if [ $? -eq 0 ]; then
                local merge_name="$(git config branch.${branch}.merge)"
                local remote_ref
                if [ "${remote_name}" == '.' ]; then
                    remote_ref="${merge_name}"
                else
                    remote_ref="refs/remotes/${remote_name}/$(basename ${merge_name})"
                fi

                local revgit
                revgit="$(git rev-list --left-right ${remote_ref}...HEAD)"
                if [ $? -ne 0 ]; then
                    revgit="$(git rev-list --left-right ${merge_name}...HEAD)"
                fi
                ahead=$(echo "${revgit}"|awk '$1~/^>/{i++};END{print(i)}')
                behind=$(echo "${revgit}"|awk '$1~/^</{i++};END{print(i)}')
            fi
        fi

        local -a data=(
            "${title}"
            "${staged}"
            "${conflicts}"
            "${changed}"
            "${untracked}"
            "${clean}"
            "${ahead}"
            "${behind}"
        )
        echo -n "${gitrepo}" ${data[@]}

        e=0
    fi

    return $e
}
#. }=-

function bop:git.init() {
    declare -gA BOP_GIT_SYMBOLS
    BOP_GIT_SYMBOLS=(
        [SEPARATOR]="${BOP_COLORS[Cyan]}|"
        [BRANCH]="${BOP_COLORS[LightRed]}"
        [STAGED]="${BOP_COLORS[Green]}●"
        [CONFLICTS]="${BOP_COLORS[Red]}✖"
        [CHANGED]="${BOP_COLORS[Yellow]}✚"
        [AHEAD]="${BOP_COLORS[Green]}↑"
        [BEHIND]="${BOP_COLORS[Red]}↓"
        [UNTRACKED]="…"
        [CLEAN]="${BOP_COLORS[LightGreen]}✔"
    )
}

function bop:git.prompt() {
    local -i e=1;

    local -a gitstatusdata
    gitstatusdata=( $(:bop:git.status) )

    if [ $? -eq 0 ]; then
        local gitstatusstr

        local gitrepo=${gitstatusdata[0]}

        local branch
        local -i staged conflicts changed untracked clean ahead behind
        read branch staged conflicts changed untracked clean ahead behind <<< ${gitstatusdata[@]:1}

        gitstatusstr+="${BOP_COLORS[Cyan]}("
        gitstatusstr+="${BOP_COLORS[Yellow]}"
        if [ -f ${gitrepo}/.git_project_symbol ];
            then gitstatusstr+="$(<${gitrepo}/.git_project_symbol)"
        elif [ -f ${gitrepo}/.git/description ];
            then gitstatusstr+="$(<${gitrepo}/.git/description)"
        else
            gitstatusstr+="$(basename ${gitrepo})"
        fi
        gitstatusstr+="${BOP_COLORS[Cyan]}:"

        gitstatusstr+="${BOP_GIT_SYMBOLS[BRANCH]}${branch}"

        local gitrelpath=${PWD/${gitrepo}/}
        gitstatusstr+="${BOP_COLORS[Cyan]}:${BOP_COLORS[Green]}${gitrelpath:-/}"

        gitstatusstr+="${BOP_GIT_SYMBOLS[SEPARATOR]}"
        [ $staged -eq 0 ]    || gitstatusstr+="${BOP_GIT_SYMBOLS[STAGED]}$staged"
        [ $conflicts -eq 0 ] || gitstatusstr+="${BOP_GIT_SYMBOLS[CONFLICTS]}$conflicts"
        [ $changed -eq 0 ]   || gitstatusstr+="${BOP_GIT_SYMBOLS[CHANGED]}$changed"
        [ $untracked -eq 0 ] || gitstatusstr+="${BOP_GIT_SYMBOLS[UNTRACKED]}$untracked"
        [ $clean -eq 1 ]     && gitstatusstr+="${BOP_GIT_SYMBOLS[CLEAN]}"

        if (( ahead + behind )); then
            gitstatusstr+="${BOP_GIT_SYMBOLS[SEPARATOR]}"
            (( behind )) && gitstatusstr+="${BOP_GIT_SYMBOLS[BEHIND]}${behind}"
            (( ahead ))  && gitstatusstr+="${BOP_GIT_SYMBOLS[AHEAD]}${ahead}"
        fi
        gitstatusstr+="${BOP_COLORS[Cyan]})"

        printf "${gitstatusstr}"
        e=0
    fi

    return $e
}
#. }=-
