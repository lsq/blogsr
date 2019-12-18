set -ex

sed -i -f bin/add-code-style.sed content/posts/sed-reference-guide.md
cp content/posts/sed-reference-guide.md $APPVEYOR_JOB_ID
