export SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

function setup
{
	set -eo pipefail
	export TMP_DIR="$BATS_TMPDIR/liquidprompt-tests"
	rm -rf "$TMP_DIR"
	mkdir -p "$TMP_DIR"
	cd "$TMP_DIR"
	export GIT_CEILING_DIRECTORY="$TMP_DIR"
} >&2

function teardown
{
	set -eo pipefail
	rm -rf "$TMP_DIR"
} >&2

function run_shell
{
	local -r shell="$1"
	local -r code="$(cat)"
	case "$shell" in
		bash) bash --norc -i -c "$code" ;;
		zsh)  zsh -fi -c "$code" ;;
		*)    echo >&2 "unsupported shell: $shell"; return 1;
	esac
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
        if [[ ! "$ps1" == *$sub* ]]
        then
            echo "Expected $name to contain \"$sub\" - got: \"$ps1\""
			return 1
        fi
    elif [[ $has == 0 ]] ; then
        if [[ "$ps1" == *$sub* ]]
        then
            echo "Expected $name to NOT contain \"$sub\" - got: \"$ps1\""
			return 1
        fi
    else
        if [[ ! "$ps1" == "$sub" ]]
        then
            echo "Expected $name to equal \"$sub\" - got: \"$ps1\""
			return 1
        fi
    fi
}

function assert_not { ps1="$1"; shift; _assert "$ps1" 0 "$@"; }
function assert_has { ps1="$1"; shift; _assert "$ps1" 1 "$@"; }
function assert_is  { ps1="$1"; shift; _assert "$ps1" 2 "$@"; }

#!/bin/bash

function cache {
	local -r ns="$1"
	local -r key="__cache_${ns}_${2}"
	local -r fn="$3"
	shift 3
	if [[ -z ${!key} ]]
	then
		eval "$key=\"$($fn "$@")\""
	fi
	echo "${!key}"
}

# load a given PS symbol for the target shell
# for example, zsh uses '%n' to denote the user, whereas bash uses '\\u'
# this function memoizes it's input in order to avoid having to re-source
# liquidprompt for every symbol.
function get_symbol {
	local IFS
	local syms
	local -r shell="$1"
	local -r symbol="$2"
	local -r cache_key="__symbol_cache_${shell}_${symbol}"
	if [ -z "${!cache_key}" ]; then
		syms="$(run_shell "$shell" <<-'EOSH'
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
		eval "__symbol_cache_${shell}_OPEN=\"$1\"";  shift
		eval "__symbol_cache_${shell}_CLOSE=\"$1\""; shift
		eval "__symbol_cache_${shell}_USER=\"$1\"";  shift
		eval "__symbol_cache_${shell}_HOST=\"$1\"";  shift
		eval "__symbol_cache_${shell}_FQDN=\"$1\"";  shift
		eval "__symbol_cache_${shell}_TIME=\"$1\"";  shift
		eval "__symbol_cache_${shell}_MARK=\"$1\"";  shift
		eval "__symbol_cache_${shell}_PWD=\"$1\"";   shift
		eval "__symbol_cache_${shell}_DIR=\"$1\"";   shift
	fi
	echo "${!cache_key}"
}
