#!/usr/bin/env bats

load support

@test 'lp: stock' {
	run_shell tests/stock.test
}

@test 'lp: stock: git' {
	run_shell tests/git.test
}

@test 'lp: stock: path shortening' {
	run_shell tests/path-shorten.test
}
