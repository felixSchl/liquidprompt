#!/usr/bin/env bats

load support

TEST_SHELL=zsh

function _run_shell { run_shell  "$TEST_SHELL"; }
function _symbol    { get_symbol "$TEST_SHELL" "$@"; }

@test 'lp: stock settings' {

	ps1="$(_run_shell <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/liquidprompt/mocks"
		_lp_set_prompt
		echo "$PS1"
	EOSH
	)"

	_u="$(_symbol USER)"
	_h="$(_symbol HOST)"

	assert_has "$ps1" User     "$_u"
    assert_not "$ps1" Hostname "$_h"
}
