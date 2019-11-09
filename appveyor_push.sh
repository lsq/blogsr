#!/usr/bin/env bash
set -xe
grep "nothing to commit" <(git status) && exit 0
pwd
git status
git add -A
git status
#git config -l
git commit -m "Update Static Site"
#env
#declare
echo $TARGET_BRANCH
git push -u origin $TARGET_BRANCH
