#!/bin/bash

die() {
	echo "master-sync: $*"
	exit 1
}

#trap 'echo error; exit' ERR

set -x


# Create a temporary branch, starting from last sync point on master
git branch -f svn-tmp svn-last-sync
git checkout svn-tmp

# First try with normal merge
git merge master

# Rebase the squashed commit on top of the svn sync branch.
git rebase --onto svn-sync-branch svn-last-sync svn-tmp
successfulrebase=$?

if [ $successfulrebase -ne 0 ]; then
	git rebase --abort

	# Start over and do a squashed merge.
	git checkout svn-last-sync
	git branch -f svn-tmp svn-last-sync
	git checkout svn-tmp

	# Squash the new commits on master to one commit 
	# (to avoid the rebase problems) and commit on the temporary branch 
	git merge --squash master
	git commit -F .git/SQUASH_MSG

	# Rebase the squashed commit on top of the svn sync branch.
	git rebase --onto svn-sync-branch svn-last-sync svn-tmp

fi



# Fast forward the svn sync branch with the squashed commit.
git checkout svn-sync-branch
git merge --ff-only svn-tmp

# Sync the suqashed commit to Subversion
git svn dcommit

# Update the pointer to the last synced commit
git branch -f svn-last-sync master
git checkout svn-last-sync
