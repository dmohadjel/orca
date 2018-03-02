all: versions.diff.html docs/index.md

.DELETE_ON_ERROR:
.SECONDARY:

SHELL=bash -e -o pipefail

versions.previous.tsv:
	git show origin/master:versions.tsv >$@

versions.current.tsv:
	( printf "Formula\tVersion\n"; \
	docker run --rm bcgsc/orca:latest sh -c 'brew list --versions; pip2 freeze' \
		| tr -s ' =' '\t\t' | gsed 's/\t.*\t/\t/' | sort -f) >$@

versions.diff.html: versions.previous.tsv versions.current.tsv
	Rscript scripts/diff-versions.R

docs/index.md: docs/index.header.md versions.diff.html
	(cat $<; echo; egrep -w 'script|link|div' versions.diff.html) >$@
