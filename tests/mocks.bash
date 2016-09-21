#!bin/bash

_lp_cpu_load () {
	echo '0.64'
}

_lp_runtime () {
	echo '2s'
}

_lp_connection() {
	echo "$TEST_CONNECTION";
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
