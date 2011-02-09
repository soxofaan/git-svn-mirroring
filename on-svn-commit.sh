#!/bin/bash

# Pull from SVN
git co svn-sync-branch
git svn rebase
# Merge to master
git co master
git merge svn-sync-branch

# return to svn-sync-branch
git co svn-sync-branch
