#!/usr/bin/env bats

load support

@test 'lp: stock' {
	run_shell <<-'EOSH'
		source "$SCRIPT_DIR/liquidprompt"
		source "$SCRIPT_DIR/tests/mocks.bash"
		source "$SCRIPT_DIR/tests/support.bash"

		eval_prompt
		assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests] %(!.#.%%) '
	EOSH
}

# function init_git_repo
# {
# 	mkdir remoterepo
# 	git -C remoterepo init --bare
# 	git clone "file://$PWD/remoterepo" repo
# 	cd repo
# 	git config user.name  'Foo Bar'
# 	git config user.email 'foo@bar.com'
# } >&2
#
# @test 'lp: stock: git' {
#
# 	init_git_repo
# 	git checkout -b funky/branch >&2
#
# 	run <<-'EOSH'
# 		export LP_ENABLE_TIME=false
# 		source "$SCRIPT_DIR/liquidprompt"
# 		source "$SCRIPT_DIR/tests/mocks.bash"
# 		source "$SCRIPT_DIR/tests/support.bash"
#
# 		# initial repo
# 		log_prompt
#
# 		# make some changes
# 		touch some-file > /dev/null
# 		log_prompt
#
# 		# stage some changes
# 		git add some-file > /dev/null
# 		log_prompt
#
# 		# commit the file
# 		git commit -m 'Initial commit' > /dev/null
# 		log_prompt
#
# 		# make some changes to tracked files
# 		echo $'foo\nbar' >> some-file
# 		log_prompt
#
# 		# stage the changes
# 		git add some-file > /dev/null
# 		log_prompt
#
# 		# commit the file
# 		git commit -m 'Second commit' > /dev/null
# 		log_prompt
#
# 		# push to origin/master
# 		git push -u origin funky/branch > /dev/null
# 		sha="$(git --no-pager show -s --format='%H' HEAD)"
# 		echo "$sha" >&2
# 		log_prompt
#
# 		# reset to be behind origin/master
# 		git reset --hard HEAD~ > /dev/null
# 		log_prompt
#
# 		# set origin/master to be behind us
# 		{
# 			git push -f
# 			git reset --hard "$sha"
# 		} > /dev/null
# 		log_prompt
#
# 		# make some changes to tracked files
# 		echo $'foo\nbar' >> some-file
# 		log_prompt
# 	EOSH
#
# 	echo 'initial repo'
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch ± '
#
# 	echo 'after adding untracked file'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch* ± '
#
# 	echo 'after staging'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch ± '
#
# 	echo 'after committing'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch ± '
#
# 	echo 'after modifying tracked file'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch(+2/-0) ± '
#
# 	echo 'after staging tracked file'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch(+0/-0) ± '
#
# 	echo 'after committing'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch ± '
#
# 	echo 'after pushing'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch ± '
#
# 	echo 'after setting to be behind origin'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch(-1) ± '
#
# 	echo 'after setting origin to be behind us'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch(1) ± '
#
# 	echo 'after making local changes'
# 	shift_ps1
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp/liquidprompt-tests/repo] funky/branch(+2/-0,1) ± '
# }
#
# @test 'lp: stock: path shortening' {
# 	mkdir -p this/is/a/very/long/path
# 	cd this/is/a/very/long/path
#
# 	run <<-'EOSH'
# 		source "$SCRIPT_DIR/liquidprompt"
# 		source "$SCRIPT_DIR/tests/mocks.bash"
# 		source "$SCRIPT_DIR/tests/support.bash"
# 		log_prompt
# 	EOSH
#
# 	assert_ps1_plain_is '0.64 1d [%n:/tmp … s/this/is/a/very/long/path] %(!.#.%%) '
# }
