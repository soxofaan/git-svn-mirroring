#!/bin/bash

die() {
	echo "on-git-commit: $*"
	exit 1
}


git branch -f svn/tmp master || die "failed to update/create temporary working branch"
git rebase --onto svn/git-svn svn/last-sync svn/tmp || die "failed to rebase on top of svn/git-svn branch"
git svn dcommit || die "failed to push to SVN repository"
git branch -f svn/last-sync master
git checkout svn/git-svn
git branch -D svn/tmp

