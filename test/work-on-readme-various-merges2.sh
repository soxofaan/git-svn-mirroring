#!/bin/bash

# Show all commands as we go allong.
set -x

# stop on error
trap "echo there was an error; exit" ERR

git co master

echo "--- starting to do some work ---" >> readme.txt
date >> readme.txt
git ci -a -m 'starting with work'

echo 'aaa' >> readme.txt
git ci -a -m 'aaa'

git co -b branch-c
echo 'ccc' >> readme.txt
git ci -a -m 'ccc'

git co master
git merge --no-ff branch-c
git branch -d branch-c

git co -b branch-d
echo 'ddd' >> readme.txt
echo 'ddd' >> readme.txt
echo 'ddd' >> readme.txt
git ci -a -m 'ddd'

git co master
perl -p -i -e 's/r/RR/g' readme.txt
git ci -a -m 's/r/RR/g'

git merge branch-d
git branch -d branch-d

git co -b branch-e
echo eee >> readme.txt
git ci -a -m eee

echo fff >> readme.txt
git ci -a -m fff

git co master
git co -b branch-f
perl -p -i -e 's/c/CC/g' readme.txt
git ci -a -m 's/c/CC/g'


git co master
perl -p -i -e 's/o/.o0o./g' readme.txt
git ci -a -m 's/o/.o0o./g'

git co branch-e
git merge branch-f



git co master
git merge branch-e
git branch -d branch-e

git co branch-f
git merge master
echo ggg >> readme.txt
git ci -a -m ggg
git co master
git merge branch-f

git branch -d branch-f



