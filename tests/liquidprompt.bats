#!/usr/bin/env bats

load support

@test 'lp: stock settings' {
	run <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/liquidprompt/mocks"
		_lp_set_prompt
		echo "$PS1"
	EOSH

	assert_ps1_has User     "$LP_USER_SYMBOL"
    assert_ps1_not Hostname "$LP_HOST_SYMBOL"
	assert_ps1_has Perms    ':'
	assert_ps1_has Path     "$(pwd | sed -e "s|$HOME|~|")"

	# assert_has Proxy            proxy    $LINENO
	# assert_has Error            127    $LINENO
	# assert_has GIT_Branch       fake_test    $LINENO
	# assert_has GIT_Changes      "+2/-1"    $LINENO
	# assert_has GIT_Commits      111    $LINENO
	# assert_has GIT_Untrack      untracked    $LINENO
	# assert_has GIT_Mark         gitmark    $LINENO
}
