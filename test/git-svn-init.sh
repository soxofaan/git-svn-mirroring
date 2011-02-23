#!/bin/bash

# Show all commands as we go allong.
set -x

# Clean up output from previous runs before we start.
rm -fr git-repo

# Get absulute path of current working directory.
root=$(pwd)

git init git-repo
cd git-repo

# create readme
echo "hello world" > readme.txt
git add readme.txt
git ci -m "added readme.txt"

# git-svn setup
git svn init --prefix=svn/ file://$root/svn-repo

git svn fetch


git branch svn-sync-branch svn/git-svn


