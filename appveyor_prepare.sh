#!/usr/bin/env bash

set -exuo pipefail
PKG_PREFIX="mingw-w64-$MSYS2_ARCH"
pacman -S --noconfirm --needed base-devel\
       ${PKG_PREFIX}-json-c \
       ${PKG_PREFIX}-glib2 \
       ${PKG_PREFIX}-gobject-introspection\
	   bash pacman msys2-runtime
pacman -S --noconfirm git subversion mingw64/mingw-w64-x86_64-ruby\
	   mingw64/mingw-w64-x86_64-libxslt python3 python\
	   mingw64/mingw-w64-x86_64-sqlite3 msys/libsqlite-devel unzip

# 
echo ---------------
# echo %path%
#which set
#echo -----set-------
#set  | grep access_token
#which env
#echo ++++++env++++++
#env | grep access_token
echo $PATH
cat >~/.git-credentials <<EOF
https://$access_token:x-oauth-basic@github.com
EOF
echo ---------------
bash -x get_hugo.sh
# which hugo && /usr/bin/hugo -t hugo-theme-den --baseUrl="https://github.com/lsq/lsq.github.io"
mkdir $APPVEYOR_JOB_ID
#bash -x get_latest.sh 2dust/v2rayNG v2rayNG_1.1.9_arm64-v8a.apk
bash -x get_latest.sh src/readme
