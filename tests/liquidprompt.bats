@test "lp: should shorten directories" {
    set -eo pipefail
    echo "${BATS_TEST_DIRNAME}"
    source "${BATS_TEST_DIRNAME}/../liquidprompt"
    echo "and the \$PS1 is: $PS1"
    exit 1
}
