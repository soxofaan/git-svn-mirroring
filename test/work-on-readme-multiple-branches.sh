#!/bin/bash

# Show all commands as we go allong.
set -x

git checkout master

for branch in A B C D E F
do
	git checkout -b branch-$branch master
	echo -n "Greetings from branch $branch, it is now " >> branch-$branch.txt
	date >> branch-$branch.txt
	git add branch-$branch.txt
	git commit -m "Worked from branch-$branch.txt"

done


git checkout branch-A
git merge branch-B
git branch -d branch-B

git checkout branch-C
git merge branch-D
git branch -d branch-D
git merge branch-A
git branch -d branch-A

git checkout branch-E
git merge branch-C
git branch -d branch-C

git checkout master
git merge branch-F
git branch -d branch-F
git merge branch-E
git branch -d branch-E
