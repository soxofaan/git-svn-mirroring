#!/bin/bash

# Rebase master (which contains new commits) onto the svn sync branch
git rebase svn-sync-branch master
# Dcommit the svn sync branch
git co svn-sync-branch
# fast forward svn-sync branch?
git merge master
git svn dcommit
