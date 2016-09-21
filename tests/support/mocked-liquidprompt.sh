#-------------------------------------------------------------------------------
# Definitions *PRIOIR* to sourcing liquidprompt
#...............................................................................
_lp_connection() {
    echo "$TEST_CONNECTION";
}

source "$SCRIPT_DIR/liquidprompt"
source "$SCRIPT_DIR/tests/support/assert.sh"

#-------------------------------------------------------------------------------
# Definitions *AFTER* sourcing liquidprompt
#...............................................................................
_lp_runtime () {
    echo '2s'
}

_lp_cpu_load () {
    echo '0.64'
}

_tmux="$(which tmux)"
tmux () {
    if [[ "$1" == list-sessions ]]; then
        echo 1
    else
        "$_tmux" "$@"
    fi
}

_screen="$(which screen)"
screen () {
    if [[ "$1" == -ls ]]; then
        echo 1
    else
        "$_screen" "$@"
    fi
}

