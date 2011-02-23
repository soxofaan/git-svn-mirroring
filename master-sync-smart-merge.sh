#!/bin/bash

die() {
	echo "master-sync: $*"
	exit 1
}

set -x


# Set a temporary working branch, pointing at current master.
# Note that this branch also acts as sort of mutex.
git branch svn-tmp master || die 'Could not create temporary working branch, maybe another sync is in progress?'

# Rebase the commits between last sync point and current master on top of the svn sync branch.
git rebase --onto svn-sync-branch svn-last-sync svn-tmp
successfulrebase=$?

if [ $successfulrebase -ne 0 ]; then
	# Undo rebase
	git rebase --abort

	# Start over: reset working branch to last sync point
	git checkout svn-last-sync
	git branch -f svn-tmp svn-last-sync
	git checkout svn-tmp
	# Now squash the new commits to one commit
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

# Clean up temporary work branch (release mutex).
git branch -D svn-tmp

