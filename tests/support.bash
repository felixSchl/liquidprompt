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
	shell="$1"
	code="$(cat)"
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
