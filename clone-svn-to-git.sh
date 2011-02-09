#!/bin/bash

# Show all commands as we go allong.
set -x

# Clean up output from previous runs before we start.
rm -fr git-repo git-wc

# Get absulute path of current working directory.
root=$(pwd)


##############################################################
# Git-svn proxy: git-repo
cd $root
git svn clone --prefix=svn/ file://$root/svn-repo git-repo

# Initialize "pointer" to last synced commit
# and check that branch out (so master is pushable)
cd $root/git-repo
git branch svn/last-sync master
git checkout svn/last-sync

##############################################################
# Git working copy
cd $root
git clone git-repo git-wc

