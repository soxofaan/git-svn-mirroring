#!/bin/bash

# TODO: detect current checked out branch/HEAD and return to it after completion.

die() {
	echo "sync-git-master-to-svn died: $*"
	exit 1
}

# The git master branch that has to be synced to SVN.
gitmaster=master
# The branch that is used to interface with SVN through git-svn rebase and dcommit.
svnsyncbranch=svn-sync-branch
# Pointer (on the git master branch) to the last synced commit.
svnlastsync=svn-last-sync
# Temporary work branch pointers for porting the commits.
workbranchstart=svn-tmp-start
workbranchend=svn-tmp-end

# Handy for dedbugging
set -x

# Set pointer to last commit from current SVN branch.
# Note that we use this branch as sort of mutex.
git branch $workbranchstart $svnsyncbranch || die 'Could not create temporary working branch, maybe another sync is in progress?'

# Git-svn fetch and rebase.
git checkout $svnsyncbranch
git svn rebase

# Create temporary work branch to be ported to git master.
git branch $workbranchend $svnsyncbranch

# Rebase work branch on top of git master.
git rebase --onto $svnlastsync $workbranchstart $workbranchend

# Merge work branch in master
git checkout $gitmaster
git merge $workbranchend
successfulmerge=$?
git branch -f $svnlastsync $gitmaster

# Clean up temporary work branches (release mutex).
git branch -D $workbranchstart
git branch -D $workbranchend

