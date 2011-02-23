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
# Pointer to the last synced commit of the git master branch.
svnlastsync=svn-last-sync
# Temporary work branch that will be ported with rebase from $gitmaster to $svnsyncbranch.
workbranch=svn-tmp

# Handy for dedbugging
set -x


# Set a temporary working branch, pointing at current master.
# Note that this branch also acts as sort of mutex.
git branch $workbranch $gitmaster || die 'Could not create temporary working branch, maybe another sync is in progress?'

# Rebase the commits between last sync point and current master on top of the svn sync branch.
git rebase --onto $svnsyncbranch $svnlastsync $workbranch
successfulrebase=$?

if [ $successfulrebase -ne 0 ]; then
	# Undo rebase.
	git rebase --abort

	# Start over: reset working branch to last sync point.
	git checkout $svnlastsync
	git branch -f $workbranch $svnlastsync
	git checkout $workbranch
	# Now squash the new commits to one commit
	# (to avoid the rebase problems) and commit on the temporary branch.
	git merge --squash $gitmaster
	git commit -F .git/SQUASH_MSG

	# Rebase the squashed commit on top of the svn sync branch.
	git rebase --onto $svnsyncbranch $svnlastsync $workbranch
fi

# Fast forward the svn sync branch with the rebased/squashed commits.
git checkout $svnsyncbranch
git merge --ff-only $workbranch

# Send the new rebased/squashed commits to Subversion.
git svn dcommit

# Update the pointer to the last synced commit.
git branch -f $svnlastsync $gitmaster

# Clean up temporary work branch (release mutex).
git branch -D $workbranch

# Return to master branch.
git checkout $gitmaster

