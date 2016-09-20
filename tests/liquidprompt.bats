#!/usr/bin/env bats

load support

@test 'lp: stock' {
	run_shell <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/mocks.bash"
		source "$SCRIPT_DIR/tests/support.bash"

		eval_prompt
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests] 2s $_LP_MARK_SYMBOL "
	EOSH
}

function init_git_repo
{
	mkdir remoterepo
	git -C remoterepo init --bare
	git clone "file://$PWD/remoterepo" repo
	cd repo
	git config user.name  'Foo Bar'
	git config user.email 'foo@bar.com'
} >&2

@test 'lp: stock: git' {

	init_git_repo
	git checkout -b funky/branch >&2

	run_shell <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/mocks.bash"
		source "$SCRIPT_DIR/tests/support.bash"

		# initial repo
		eval_prompt 'initial repo'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch 2s ± "

		# make some changes
		touch some-file > /dev/null
		eval_prompt 'some changes'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch* 2s ± "

		# stage some changes
		git add some-file > /dev/null
		eval_prompt 'staged changes'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch 2s ± "

		# commit the file
		git commit -m 'Initial commit' > /dev/null
		eval_prompt 'initial commit'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch 2s ± "

		# make some changes to tracked files
		echo $'foo\nbar' >> some-file
		eval_prompt 'change tracked file'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch(+2/-0) 2s ± "

		# stage the changes
		git add some-file > /dev/null
		eval_prompt 'stage changes to tracked file'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch(+0/-0) 2s ± "

		# commit the file
		git commit -m 'Second commit' > /dev/null
		eval_prompt 'second commit'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch 2s ± "

		# push to origin/master
		git push -u origin funky/branch &> /dev/null
		sha="$(git --no-pager show -s --format='%H' HEAD)"
		eval_prompt 'push to origin/master'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch 2s ± "

		# reset to be behind origin/master
		git reset --hard HEAD~ > /dev/null
		eval_prompt 'reset to be behind origin/master'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch(-1) 2s ± "

		# set origin/master to be behind us
		{
			git push -f
			git reset --hard "$sha"
		} &> /dev/null
		eval_prompt 'reset origin/mater to be behind us'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch(1) 2s ± "

		# make some changes to tracked files
		echo $'foo\nbar' >> some-file
		eval_prompt 'make changes to tracked file again'
		assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp/liquidprompt-tests/repo] funky/branch(+2/-0,1) 2s ± "
	EOSH
}

@test 'lp: stock: path shortening' {
	mkdir -p this/is/a/very/very/very/long/path
	cd       this/is/a/very/very/very/long/path

	run_shell <<-'EOSH'
		LP_PATH_LENGTH=5

		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/mocks.bash"
		source "$SCRIPT_DIR/tests/support.bash"

		eval_prompt
		case "$TEST_SHELL" in
			bash) assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp … path] 2s $_LP_MARK_SYMBOL " ;;
			zsh)  assert_ps1_plain_is "0.64 1d [$_LP_USER_SYMBOL:/tmp … g/path] 2s $_LP_MARK_SYMBOL " ;;
			*)    exit 1 ;;
		esac
	EOSH
}
