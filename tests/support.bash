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

	function run_shell {
		echo "$TEST_SHELL" >> /tmp/foo.bar
		_run_shell "$TEST_SHELL" "$@"
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

function _invalid_assert     {
	echo >&2 'No has test run yet. call "eval_prompt" first.'
	return 1
}

function assert_ps1_has       { _invalid_assert; }
function assert_ps1_not       { _invalid_assert; }
function assert_ps1_is        { _invalid_assert; }
function assert_ps1_plain_has { _invalid_assert; }
function assert_ps1_plain_not { _invalid_assert; }
function assert_ps1_plain_is  { _invalid_assert; }
function shift_ps1            { _invalid_assert; }

function eval_prompt
{
	if [[ -n "$1" ]]; then
		echo "...check: $1"
	fi

	export _LP_PS1 _LP_PS1_PLAIN
	set +e; _lp_set_prompt; set -e
	_LP_PS1="$PS1"
	_LP_PS1_PLAIN="$(strip_colors <<< "$_LP_PS1")"

	function assert_ps1_not       { _assert "$_LP_PS1" 0 "$@"; }
	function assert_ps1_has       { _assert "$_LP_PS1" 1 "$@"; }
	function assert_ps1_is        { _assert "$_LP_PS1" 2 "$@"; }
	function assert_ps1_plain_not { _assert "$_LP_PS1_PLAIN" 0 "$@"; }
	function assert_ps1_plain_has { _assert "$_LP_PS1_PLAIN" 1 "$@"; }
	function assert_ps1_plain_is  { _assert "$_LP_PS1_PLAIN" 2 "$@"; }
}

function strip_colors
{
	perl -pe 's/\e\[?.*?[\@-~]//g' \
		| sed -e '
			s|\\\[||g; s|\\]||g
			s|%{||g;   s|%}||g
			s|||g
		'
}

function _assert
{
	local -r ps1=$1
	local -r mode=$2

	if [[ "$mode" == 2 ]]; then
		local -r sub=$3
	else
		local -r name=$3
		local -r sub=$4
	fi

	if [[ -z "$sub" ]]; then
		echo '_assert: no substring to given to test'
		return 1
	fi

	case "$mode" in
		0) # does NOT contain
			if grep -qE "$sub" <<< "$ps1"; then
				echo "Expected PS1 to NOT contain $name \"$sub\" - got: \"$ps1\""
				return 1
			fi
		;;
		1) # does contain
			if ! grep -qE "$sub" <<< "$ps1"; then
				echo "Expected PS1 to contain $name \"$sub\" - got: \"$ps1\""
				return 1
			fi
		;;
		2) # exact match
			if [[ ! "$ps1" == "$sub" ]]; then
				echo "Expected PS1 to equal \"$sub\" - got: \"$ps1\"" | tee /tmp/foo.bar
				return 1
			fi
		;;
	esac
}
