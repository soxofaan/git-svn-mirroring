#!/bin/bash

# Show all commands as we go allong.
set -x

# Clean up output from previous runs before we start.
rm -fr git-repo

root=$(pwd)

cd $root
git svn clone --prefix=svn/ file://$root/svn-repo git-repo

cd $root/git-repo

git branch svn-sync/svn-side master
git branch svn-sync/git-side master
