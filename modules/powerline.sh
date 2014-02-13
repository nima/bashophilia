#. POWERLINE -={
function powerline_ps1() {
    export PS1="$(
        export PYTHONPATH=/srv/github/powerline/
        /srv/github/powerline//powerline-shell.py $? 2> /dev/null
    )"
}
#. }=-
