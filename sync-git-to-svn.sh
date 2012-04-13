#!/bin/bash

die() {
	echo "sync-git-to-svn died: $*"
	exit 1
}

# The git master branch that has to be synced to SVN.
if [ -n "$1" ] ; then
	gitmaster=$1
else
	gitmaster=master
fi
# The branch that is used to interface with SVN through git-svn rebase and dcommit.
if [ -n "$2" ] ; then
	svnside=$2
else
	svnside=svn-sync/svn-side
fi
# Pointer (on the git master branch) to the last synced commit.
if [ -n "$3" ] ; then
	gitside=$3
else
	gitside=svn-sync/git-side
fi
# Temporary work branch that will be ported with rebase from $gitmaster to $svnside.
work=svn-sync/tmp-git2svn

# The branch/ref/commit to return to. TODO: detect the current checked out branch/HEAD/ref.
returntarget=$gitmaster


# Handy for debugging
set -x

# Check that SVN-side and Git are in sync
diff=$(git diff --ignore-submodules $svnside..$gitside | wc -c)
if [ $diff -gt 0 ]
then
	die "svn-sync/svn-side and svn-sync/git-side are out of sync"
fi


# Set a temporary working branch, pointing at current master.
# Note that this branch also acts as sort of mutex.
git branch $work $gitmaster || die 'Could not create temporary working branch, maybe another sync is in progress?'

# Remove submodules from work branch before rebasing
git checkout $work
submodules=$(git submodule status | sed 's/^[[:space:]]*\(.*\)/\1/' | cut -d ' ' -f 2)
if [ -n $submodules ]; then
	git filter-branch --prune-empty --force --index-filter "git rm --cached --ignore-unmatch $submodules" $gitside..$work
fi

# Rebase the commits between last sync point and current master on top of the svn sync branch.
git rebase --onto $svnside $gitside $work
successfulrebase=$?

if [ $successfulrebase -ne 0 ]; then
	# Undo rebase.
	git rebase --abort

	# Start over: reset working branch to last sync point.
	git checkout $gitside
	git branch -f $work $gitside
	git checkout $work
	# Now squash the new commits to one commit
	# (to avoid the rebase problems) and commit on the temporary branch.
	git merge --squash $gitmaster
	git commit -F .git/SQUASH_MSG

	# Rebase the squashed commit on top of the svn sync branch.
	git rebase --onto $svnside $gitside $work
	successfulrebase=$?

	if [ $successfulrebase -ne 0 ]; then
		git checkout $returntarget
		die "rebasing failed"
	fi
fi

# Fast forward the svn sync branch with the rebased/squashed commits.
git checkout $svnside
git branch $svnside-orig $svnside
git merge --ff-only $work

if [ $? -ne 0 ]; then
	die "fast forward merge of work into svnside failed"
fi


# Check that rebased SVN-side and Git master branch are in sync
diff=$(git diff --ignore-submodules $svnside..$gitmaster | wc -c)
if [ $diff -gt 0 ]
then
	die "svn-sync/svn-side and $gitmaster are not in sync"
fi

# Send the new rebased/squashed commits to Subversion (updated the SVN-side pointer $svnside).
git svn dcommit --add-author-from

if [ $? -ne 0 ]; then
	# Return to target and clean up a bit.
	git checkout $returntarget
	git branch -f $svnside $svnside-orig
	git branch -D $svnside-orig
	git branch -D $work
	# Die
	die "svn dcommit failed"
fi

# Update the Git-side pointer to the last synced commit.
git branch -f $gitside $gitmaster

# Clean up temporary work branch (release mutex).
git branch -D $work
git branch -D $svnside-orig

# Return to master branch.
git checkout $returntarget

