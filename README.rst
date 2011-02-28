
This is a bunch of scripts attempting to set up Git to SVN mirroring, without the
branching/merging/pulling constraints set by the standard git-svn tool.

Git-svn caveats
----------------

Git-svn is a well known option to use Git as an SVN client, but it comes with some caveats and
constraints. To quote the git-svn manual page:

	For the sake of simplicity and interoperating with a less-capable system (SVN), 
	it is recommended that all git svn users clone, fetch and dcommit directly from the SVN server, 
	and avoid all git clone/pull/merge/push operations between git repositories and branches. 
	[...]
	Running git merge or git pull is NOT recommended on a branch you plan to dcommit from. 

A related problem is that git-svn dcommit rewrites git commits (e.g. it adds SVN metadata to the commit message).
This means that Git can get easily confused when it tries to merge the branch with the rewritten commits
with a branch with the original commits
(for example when the original branch was forked or pushed before the git-svn dcommit).
I've been there, it's not pretty.

Eventhough the git-svn documentation warns not do git branching, merging and pulling when you use
git-svn, it makes the usefulness of git-svn pretty limited in real projects and workflows.



Mirroring a read/write Git repo to a read-only SVN repo mirror
---------------------------------------------------------------

This was the initial target use case for these sync scripts.
The aim is to allow all standard git operations like branching, merging, pushing, pulling
and still be able to mirror it to a read-only SVN repo. 
"Read-only SVN repo" means here that only the Git commits should be pushed ("svn commit") to it through 
the sync tools, but all other "users" of the SVN repo should only read ("svn update") from it.

The trick to allow full git branching functionality combined with git-svn syncing 
is to keep a dedicated git-svn sync branch completely separate from the bunch of
normal git branches ("master", "develop", topic branches, integration branches, ...).
All normal, daily work and commits should happen on the normal branches, the git-svn sync
branch is only for internal housekeeping and should not be committed on directly.
To avoid merging issues do to commit rewriting, there should also be no merging between
the dedicated git-svn sync branch and the normal branches. 
Instead, to keep things in sync, commits are ported/transferred by the sync script  with a 
"git rebase --onto" trick. This has the added benefit that git rebase will try to 
create a linear commit-history on the git-svn sync branch
from a possibly non-linear history in the bunch of normal branches. 

TODO ...




Literature/inspiration/alternatives
---------------------------------------

* http://www.kerrybuckley.org/2009/10/06/maintaining-a-read-only-svn-mirror-of-a-git-repository/
* http://zenadmin.org/en/blog/page439.html
* http://www.codeography.com/2010/03/17/howto-mirror-git-to-subversion.html


