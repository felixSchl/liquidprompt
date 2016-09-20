#!/bin/bash

export SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

# the shell to test: driven by CI
TEST_SHELL=${TEST_SHELL:-bash}

case "$(uname)" in
	Darwin) OS=osx ;;
	Linux)  OS=linux ;;
	*)      OS=unknown ;;
esac

function setup
{
	set -eo pipefail
	export TMP_DIR="$BATS_TMPDIR/liquidprompt-tests"
	rm -rf "$TMP_DIR"
	mkdir -p "$TMP_DIR"

	# on OSX, we are handed a deep path to some
	# /var/private/tmp/ directory
	if [[ "$OS" == osx ]]
	then
		rm -f /tmp/liquidprompt-tests
		ln -s "$TMP_DIR" /tmp/liquidprompt-tests
		TMP_DIR=/tmp/liquidprompt-tests
	fi

	cd "$TMP_DIR"
	export GIT_CEILING_DIRECTORY="$TMP_DIR"
	_activate_symbols "$TEST_SHELL"

	function run_shell {
		_run_shell "$TEST_SHELL" "$@"
	}

	# reset the assertion handlers for every test case
	function _invalid_assert { echo >&2 'No has test run yet'; return 1; }
	function assert_ps1_has  { _invalid_access; }
	function assert_ps1_not  { _invalid_access; }
	function assert_ps1_is   { _invalid_access; }
	function shift_ps1       { _invalid_access; }

	# run the given block of code (on stdin) in the currently configured shell
	# and expect a return value describing the $PS1 of the shell.
	# finally, modify the assert functions to be in context of this return
	# value.
	# note that the underlying script may return more than one PS1 line, which
	# can be accessed as `${LP_PS1[<index>]}` 
	function run {
		local IFS=$'\n'
		export LP_PS1 _LP_PS1 _LP_PS1_ACTIVE

		_LP_PS1_ACTIVE=0
		_LP_PS1=($(run_shell "$@"))
		LP_PS1="${_LP_PS1[0]}"

		if [ -z "$LP_PS1" ]; then
			echo >&2 "'run' did not return a PS1 string"
			return 1
		fi

		function shift_ps1 {
			((_LP_PS1_ACTIVE+=1))
			LP_PS1="${_LP_PS1[$_LP_PS1_ACTIVE]}"
		}

		function assert_ps1_has { assert_has "$LP_PS1" "$@"; }
		function assert_ps1_not { assert_not "$LP_PS1" "$@"; }
		function assert_ps1_is  { assert_is  "$LP_PS1" "$@"; }
	}
} >&2

function teardown
{
	set -eo pipefail
	rm -rf "$TMP_DIR"
} >&2

function _run_shell
{
	local -r shell="$1"
	local -r code="$(cat)"
	case "$shell" in
		bash) bash --norc -i -c "$code" ;;
		zsh)  zsh -fi -c "$code" ;;
		*)    echo >&2 "unsupported shell: $shell"; return 1;;
	esac
}

function strip_colors
{
	sed -E "s/"$'\E'"\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g"
}

function _assert
{
    local ps1=$1
    local has=$2
    local name=$3
    local sub=$4

    if [[ -z "$sub" ]]
    then
        return 1
    fi

    if [[ $has == 1 ]] ; then
		if ! grep -qE "$sub" <<< "$ps1"
        then
            echo "Expected PS1 to contain $name \"$sub\" - got: \"$ps1\""
			return 1
        fi
    elif [[ $has == 0 ]] ; then
		if grep -qE "$sub" <<< "$ps1"
        then
            echo "Expected PS1 to NOT contain $name \"$sub\" - got: \"$ps1\""
			return 1
        fi
    else
        if [[ ! "$ps1" == "$sub" ]]
        then
            echo "Expected PS1 to equal \"$sub\" - got: \"$ps1\""
			return 1
        fi
    fi
}

function assert_not { ps1="$1"; shift; _assert "$ps1" 0 "$@"; }
function assert_has { ps1="$1"; shift; _assert "$ps1" 1 "$@"; }
function assert_is  { ps1="$1"; shift; _assert "$ps1" 2 "$@"; }

#!/bin/bash

# assign the lp symbols to global variables for ease of access.
function _activate_symbols {
	local -r shell="$1"
	_load_symbols "$shell"
	export LP_OPEN_ESC=
	export LP_CLOSE_ESC=
	export LP_USER_SYMBOL=
	export LP_HOST_SYMBOL=
	export LP_FQDN_SYMBOL=
	export LP_TIME_SYMBOL=
	export LP_MARK_SYMBOL=
	export LP_PWD_SYMBOL=
	export LP_DIR_SYMBOL=
	case "$shell" in
		"") return 0 ;;
		bash|zsh)
			LP_OPEN_ESC="__lp_symbol_cache_${shell}_OPEN_ESC"
			LP_CLOSE_ESC="__lp_symbol_cache_${shell}_CLOSE_ESC"
			LP_USER_SYMBOL="__lp_symbol_cache_${shell}_USER_SYMBOL"
			LP_HOST_SYMBOL="__lp_symbol_cache_${shell}_HOST_SYMBOL"
			LP_FQDN_SYMBOL="__lp_symbol_cache_${shell}_FQDN_SYMBOL"
			LP_TIME_SYMBOL="__lp_symbol_cache_${shell}_TIME_SYMBOL"
			LP_MARK_SYMBOL="__lp_symbol_cache_${shell}_MARK_SYMBOL"
			LP_PWD_SYMBOL="__lp_symbol_cache_${shell}_PWD_SYMBOL"
			LP_DIR_SYMBOL="__lp_symbol_cache_${shell}_DIR_SYMBOL"

			LP_OPEN_ESC="${!LP_OPEN_ESC}"
			LP_CLOSE_ESC="${!LP_CLOSE_ESC}"
			LP_USER_SYMBOL="${!LP_USER_SYMBOL}"
			LP_HOST_SYMBOL="${!LP_HOST_SYMBOL}"
			LP_FQDN_SYMBOL="${!LP_FQDN_SYMBOL}"
			LP_TIME_SYMBOL="${!LP_TIME_SYMBOL}"
			LP_MARK_SYMBOL="${!LP_MARK_SYMBOL}"
			LP_PWD_SYMBOL="${!LP_PWD_SYMBOL}"
			LP_DIR_SYMBOL="${!LP_DIR_SYMBOL}"
		;;
		*) echo >&2 "unsupported shell: $shell"; return 1;;
	esac
}

# load a given PS symbol for the target shell
# for example, zsh uses '%n' to denote the user, whereas bash uses '\\u'
# this function memoizes it's input in order to avoid having to re-source
# liquidprompt for every symbol.
function _load_symbols {
	local IFS
	local syms
	local -r shell="$1"
	local -r cache_key="__lp_symbol_cache_${shell}"
	if [ -z "${!cache_key}" ]; then
		syms="$(_run_shell "$shell" <<-'EOSH'
			source "$SCRIPT_DIR/liquidprompt"
			echo "$_LP_OPEN_ESC"
			echo "$_LP_CLOSE_ESC"
			echo "$_LP_USER_SYMBOL"
			echo "$_LP_HOST_SYMBOL"
			echo "$_LP_FQDN_SYMBOL"
			echo "$_LP_TIME_SYMBOL"
			echo "$_LP_MARK_SYMBOL"
			echo "$_LP_PWD_SYMBOL"
			echo "$_LP_DIR_SYMBOL"
		EOSH
		)"
		IFS=$'\n' set -- $syms
		eval "__lp_symbol_cache_${shell}_OPEN_ESC=\"$1\"";  shift
		eval "__lp_symbol_cache_${shell}_CLOSE_ESC=\"$1\""; shift
		eval "__lp_symbol_cache_${shell}_USER_SYMBOL=\"$1\"";  shift
		eval "__lp_symbol_cache_${shell}_HOST_SYMBOL=\"$1\"";  shift
		eval "__lp_symbol_cache_${shell}_FQDN_SYMBOL=\"$1\"";  shift
		eval "__lp_symbol_cache_${shell}_TIME_SYMBOL=\"$1\"";  shift
		eval "__lp_symbol_cache_${shell}_MARK_SYMBOL=\"$1\"";  shift
		eval "__lp_symbol_cache_${shell}_PWD_SYMBOL=\"$1\"";   shift
		eval "__lp_symbol_cache_${shell}_DIR_SYMBOL=\"$1\"";   shift
	fi
}

function log_prompt
{
	_lp_set_prompt
	echo "$PS1"
}
