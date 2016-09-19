#!/usr/bin/env bats

load support

@test 'lp: stock' {
	run <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/support.bash"
		log_prompt
	EOSH

	assert_ps1_has User     "$LP_USER_SYMBOL"
	assert_ps1_not Hostname "$LP_HOST_SYMBOL"
	assert_ps1_has Perms    ':'
	assert_ps1_has Path     "$(pwd | sed -e "s|$HOME|~|")"
}

function init_git_repo
{
	mkdir repo
	git -c repo init --bare
	git clone "file://$PWD/repo"
	cd repo
	git config user.name  'Foo Bar'
	git config user.email 'foo@bar.com'
} >&2

@test 'lp: stock: git' {

	init_git_repo
	git checkout -b funky/branch >&2

	run <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/support.bash"

		# initial repo
		log_prompt

		# make some changes
		touch some-file > /dev/null
		log_prompt

		# stage some changes
		git add some-file > /dev/null
		log_prompt

		# commit the file
		git commit -m 'Initial commit' > /dev/null
		log_prompt

		# make some changes to tracked files
		echo $'foo\nbar' >> some-file
		log_prompt

		# stage the changes
		git add some-file > /dev/null
		log_prompt

		# commit the file
		git commit -m 'Second commit' > /dev/null
		log_prompt

		# push to origin/master
		git push -u origin funky/branch > /dev/null
		log_prompt
	EOSH

	echo 'initial repo'
	assert_ps1_has 'Git branch'    'funky/branch'
	assert_ps1_has 'Git mark'      '±'
	assert_ps1_not 'Git untracked' '\*'
	assert_ps1_not 'Git changes'   '[+-][0-9]+/[+-][0-9]+'

	echo 'after adding untracked file'
	shift_ps1
	assert_ps1_has 'Git branch'    'funky/branch'
	assert_ps1_has 'Git mark'      '±'
	assert_ps1_has 'Git untracked' '\*'
	assert_ps1_not 'Git changes'   '[+-][0-9]+/[+-][0-9]+'

	echo 'after staging'
	shift_ps1
	assert_ps1_has 'Git branch'    'funky/branch'
	assert_ps1_has 'Git mark'      '±'
	assert_ps1_not 'Git untracked' '\*'
	assert_ps1_not 'Git changes'   '[+-][0-9]+/[+-][0-9]+'

	echo 'after committing'
	shift_ps1
	assert_ps1_has 'Git branch'  'funky/branch'
	assert_ps1_has 'Git mark'    '±'
	assert_ps1_not 'Git mark'    '\*'
	assert_ps1_not 'Git changes' '[+-][0-9]+/[+-][0-9]+'

	echo 'after modifying tracked file'
	shift_ps1
	assert_ps1_has 'Git branch' 'funky/branch'
	assert_ps1_has 'Git mark'   '±'
	assert_ps1_not 'Git mark'   '\*'
	assert_ps1_has 'Git mark'   '[+-][0-9]+/[+-][0-9]+'
	assert_ps1_has 'Git mark'   '\+2/-0'

	echo 'after staging tracked file'
	shift_ps1
	assert_ps1_has 'Git branch' 'funky/branch'
	assert_ps1_has 'Git mark'   '±'
	assert_ps1_not 'Git mark'   '\*'
	assert_ps1_has 'Git mark'   '[+-][0-9]+/[+-][0-9]+'
	assert_ps1_has 'Git mark'   '\+0/-0'

	echo 'after committing'
	shift_ps1
	assert_ps1_has 'Git branch'  'funky/branch'
	assert_ps1_has 'Git mark'    '±'
	assert_ps1_not 'Git mark'    '\*'
	assert_ps1_not 'Git changes' '[+-][0-9]+/[+-][0-9]+'

	echo 'after pushing'
	shift_ps1
	assert_ps1_has 'Git branch'  'funky/branch'
	assert_ps1_has 'Git mark'    '±'
	assert_ps1_not 'Git mark'    '\*'
	assert_ps1_not 'Git changes' '[+-][0-9]+/[+-][0-9]+'
}

@test 'lp: stock: path shortening' {
	mkdir -p this/is/a/very/long/path
	cd this/is/a/very/long/path

	run <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/support.bash"
		log_prompt
	EOSH

	assert_ps1_has 'Shortened path' 'tmp … s/is/a/very/long/path'
}
