#!/bin/bash

# Show all commands as we go allong.
set -x


git co master

echo 'Starting over' > readme.txt
git ci -a -m 'starting over'

echo 'aaa' >> readme.txt
git ci -a -m 'aaa'

echo 'bbb' >> readme.txt
git ci -a -m 'bbb'


git co -b branch-c
echo 'ccc' >> readme.txt
git ci -a -m 'ccc'

git co master
git merge --no-ff branch-c
git branch -d branch-c

git co -b branch-d
echo 'ddd' >> readme.txt
git ci -a -m 'ddd'

git co master
perl -p -i -e 's/r/RR/g' readme.txt
git ci -a -m 's/r/RR/g'

git merge branch-d
git branch -d branch-d

