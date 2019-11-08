#!/usr/bin/env bash
grep "nothing to commit" <(git status) && exit 0
pwd
git add -A
git config -l
git commit -m "Update Static Site"
echo %TARGET_BRANCH%
git push -u origin %TARGET_BRANCH%
