#!/bin/bash

export SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

# the shell to test: driven by CI
export TEST_SHELL=${TEST_SHELL:-bash}
export TEST_CONNECTION=${TEST_CONNECTION:-lcl}

export OS=
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
	if [[ -n "$2" ]]; then
		case "$shell" in
			bash) bash --norc -i "${SCRIPT_DIR}/$2" ;;
			zsh)  zsh -fi "${SCRIPT_DIR}/$2" ;;
			*)    echo >&2 "unsupported shell: $shell"; return 1;;
		esac
	else
		case "$shell" in
			bash) bash --norc -i -c "$(cat)" ;;
			zsh)  zsh -fi -c "$(cat)" ;;
			*)    echo >&2 "unsupported shell: $shell"; return 1;;
		esac
	fi
}
