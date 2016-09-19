.DEFAULT: test

SHELL=/bin/bash

test:
	bats -p tests

test-all: test-zsh test-bash

test-zsh:
	TEST_SHELL=zsh make test

test-bash:
	TEST_SHELL=zsh make test

watch:
	fswatch -x liquidprompt liquid.ps1 liquid.theme tests/*.{bats,bash} 2>/dev/null | \
		while read -r f attr; do \
			if ! [ -z "$$f" ] && [[ "$$attr" =~ Updated ]]; then \
				echo "file changed: $$f ($$attr)"; \
				make test; \
			fi; \
		done
