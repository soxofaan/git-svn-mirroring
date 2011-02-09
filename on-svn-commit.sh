#!/bin/bash

die() {
	echo "on-svn-commit: $*"
	exit 1
}

# Pull from SVN to master.
git co master || die "Failed to check out master"
git svn rebase || die "Failed to svn-rebase"

# Move last-sync "pointer" to master
git branch -f svn/last-sync master || die "Failed to move the last-sync pointer to master"
# And check it out (so that master is pushable)
git checkout svn/last-sync || die "Failed to check out last-sync"
