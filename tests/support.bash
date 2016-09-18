#!/usr/bin/env bash

setup
{
	set -eo pipefail
	export SCRIPT_DIR="$PWD"
	export TMP_DIR="$BATS_TMPDIR/liquidprompt-tests"
	[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
	mkdir -p "$TMP_DIR"
	cd "$TMP_DIR"
	export GIT_CEILING_DIRECTORY="$TMP_DIR"
}

teardown
{
	set -eo pipefail
	[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}

function run_shell
{
	shell="$1"
	shift
	case "$shell" in
		bash) bash --norc -i -- "$@" ;;
		zsh) zsh -fi "$@" ;;
		*) echo >&2 "unsupported shell: $shell"; return 1;
	esac
}
