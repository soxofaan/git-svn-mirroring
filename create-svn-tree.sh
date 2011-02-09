#!/bin/bash

# Show all commands as we go allong.
set -x

# Clean up output from previous runs before we start.
rm -fr svn-repo svn-wc

# Get absulute path of current working directory.
root=$(pwd)

###############################################################
# Set up initial SVN repo.
svnadmin create svn-repo
svn checkout file://$root/svn-repo svn-wc
cd $root/svn-wc
# Create a readme file.
echo "Hello I'm your readme for tonight." > readme.txt
svn add readme.txt
svn commit -m "Created readme.txt"
echo "enjoy the show" >> readme.txt
svn commit -m "Added some more to read"
# Create some more content
svn mkdir src
svn commit -m "Added src dir"
echo "print 'hello world'" > src/helloworld.py
svn add src/helloworld.py
svn commit -m "Added hello world script"