#!/bin/bash

# TODO: detect current checked out branch/HEAD and return to it after completion.

die() {
	echo "sync-git-master-to-svn died: $*"
	exit 1
}

# The git master branch that has to be synced to SVN.
gitmaster=master
# The branch that is used to interface with SVN through git-svn rebase and dcommit.
svnside=svn-sync/svn-side
# Pointer (on the git master branch) to the last synced commit.
gitside=svn-sync/git-side
# Temporary work branch pointers for porting the commits.
workstart=svn-sync/tmp-svn2git-start
workend=svn-sync/tmp-svn2git-end

# Handy for dedbugging
set -x

# Set pointer to last commit from current SVN branch.
# Note that we use this branch as sort of mutex.
git branch $workstart $svnside || die 'Could not create temporary working branch, maybe another sync is in progress?'

# Git-svn fetch and rebase.
git checkout $svnside
git svn rebase

# Create temporary work branch to be ported to git master.
git branch $workend $svnside

# Rebase work branch on top of git master.
git rebase --onto $gitside $workstart $workend

# Merge work branch in master
git checkout $gitmaster
git merge $workend
git branch -f $gitside $gitmaster

# Clean up temporary work branches (release mutex).
git branch -D $workstart
git branch -D $workend

