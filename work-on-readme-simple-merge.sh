#!/bin/bash

# Show all commands as we go allong.
set -x

git co master

echo "---------------" >> readme.txt
date >> readme.txt
git ci -a -m 'Starting simple merge'

echo 'aaa' >> readme.txt
echo 'bbb' >> readme.txt
echo 'ccc' >> readme.txt
echo 'ddd' >> readme.txt
git commit -a -m 'abcd'

git checkout -b branch-e
echo 'eee' >> readme.txt
git ci -a -m 'eee'

git co master
perl -p -i -e 's/a/AA/g' readme.txt
git ci -a -m 's/a/AA/g'

git merge branch-e
git branch -d branch-e

echo 'fff' >> readme.txt
git commit -a -m 'fff'


