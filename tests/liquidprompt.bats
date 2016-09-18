#!/usr/bin/env bats

load support

TEST_SHELL=bash

function _run_shell
{
	run_shell "$TEST_SHELL" "$@"
}

@test 'lp: stock' {
	ps1="$(_run_shell <<-EOSH
		export LP_MARK_BATTERY="BATT"
		source "$SCRIPT_DIR/liquidprompt"
		_lp_set_prompt
		echo "\$PS1"
	EOSH
	)"
	assert_has "$ps1" 'Battery Mark' BATT
}
