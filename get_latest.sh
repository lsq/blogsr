#!/usr/bin/env bash
# usage: $0 src_file downloaded_file

set -uo pipefail
#set +x

function get_latest_release() {
  curl --silent "https://api.github.com/repos/${1}/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                 # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' #|
#    xargs -I {} curl -sOL "https://github.com/${1}/archive/"{}'.tar.gz'

}
function get_release(){
  local file_list=`curl --silent "https://github.com/${1}/releases" |
    sed  -n 's^.*a href="\('"/${1}"'/releases/download/\)\([^"]*'"$2"'\)".*^\1\2^p'`
  #[[ -n $file_list ]] && echo "found files: $file_list"
  #pathd=$(grep $2 <<<"$file_list")
  [ -n "$file_list" ] && local pathd=$(echo "$file_list" | grep "$2" | head -n 1)
  [ -n "$pathd" ] && echo -e "Begin downloading ...........................\n" &&
    curl -sOL "https://github.com$pathd" &&
    echo "--------------finished!--------------------"
}
# [[ -n $(get_latest_release $1) ]] && echo "latest release is: $(get_latest_release $1)"
function get_download_list() {
  printf "%s\n" "getting download url list" >&2
  printf "%s\n" "=========================" >&2
  #curl --silent "$1" | sed -n  's/<p>\(.*\)<.*/\1/p'
  curl --silent "$1" | sed -n -e '

#!/usr/bin/env sed -f
#/<td class="d-block \+comment-body markdown-body"/, /<\/td>/p
/<td class="d-block \+comment-body \+markdown-body \+js-comment-body">/, /<\/td>/{
  /<td/!{
    /<\/td/!{
#### head
      s/^ \+//;
      /<h1>/{s/<[^<]*>//g;s/^/#/}
      /<h2>/{s/<[^<]*>//g;s/^/##/}
      /<h3>/{s/<[^<]*>//g;s/^/###/}
      /<h4>/{s/<[^<]*>//g;s/^/####/}
###  paragraph
      s/<[^<]*>//g
      /^$/d
      s/^\[.*\] //
      p
    }
  }
}'

}
function update_download_list(){
  #get_download_list | xargs -I {} sed -r -i 's/^()'"{}"
  local dllist=$(get_download_list "$1")
  while read -ra flist;do
  [[ ${#flist[@]} < 1 || ${flist[0]} =~ ^# ]] && continue
  [[ ${#flist[@]} = 1 && ! ${flist[0]} =~ ^(http|ftp) ]] && continue
  [[ ${#flist[@]} -ge 2  && ! ${flist[0]} =~ ^(http|ftp)  &&  ${flist[1]} =~ ^# ]] && continue
  [[ ${#flist[@]} = 1 ]] &&  flist=(${flist[@]} "#")

  : <<'COMMENTBLOCK'
  sed  -r '/'"${flist[0]}"' +'"${flist[1]}"'/{
  /^ *#/{
  :tag;
  N;
  $!b tag;
  $b add;
  };
  b;
  };
  :add;
  $a '"${flist[0]} ${flist[1]}"'\
  ' "$2"
COMMENTBLOCK

#sedsed --debug   '1b add
#sed --debug   '1b add
#sed -n --debug  '1b add
sed  -i '1b add
  :beg
  \^'"${flist[0]}"' \+'"${flist[1]}"'^{
  /^ *#/b add
  x
  s|\n'"${flist[0]} ${flist[1]}"'||
  x
  }
  $b end
  b
  :add;
  x
  \|'"${flist[0]} ${flist[1]}"'|! {
  s|'"$|\n${flist[0]} ${flist[1]}"'|
  }
  x
  1b beg
  $b end
  b
  : end
  x
  \|^[[:space:]]*$|! {s/^/'"\n### update at: $(TZ='Asia/Shanghai' date)\n"'/
  H
  } 
  x
  ' "$2"

  done <<<"$dllist"
  echo "====================" >&2
  echo "file list updated!" >&2
  echo "====================" >&2
}

function download_file(){
while read -ra line; do
  #declare -a
  #printf "+ %s\n" "${line[*]}"
  [[ ${#line[@]} < 1 || ${line[0]} =~ ^# ]] && continue
  if [[ ${line[@]} && ${line[0]} =~ ^(http|ftp) ]]; then
    user_repo=`: ${line[0]#*//};echo ${_%%/*}` 
    repo_name="$us"
    [[ ${#line[@]} -eq 1 ]] || [[ ${#line[@]} -ge 2 && ${line[1]} = "#" ]] &&
      dl_filename=`${line[0]##*/}`
    [[ ${#line[@]} -eq 2 && ! ${line[1]} =~ ^#$ ]] &&
      dl_filename=`${line[1]#\#}`
    [[ $user_repo && $dl_filename ]] &&
      curl -sL -o "$dl_filename" ${line[0]}
    [ $? -eq 0 ] && mv -f "$dl_filename" "$APPVEYOR_JOB_ID/$user_repo-$dl_filename" &&
    sed -i '\|^ *'"${line[0]}"'|s/^/  - dl /' $1
  else
  [[ ${#line[@]} < 2 || ${line[1]} =~ ^# ]] && continue
  user_repo="${line[0]}"
  dl_filename="${line[1]}"
  repo_name=$(gawk -F'/' '{print $2}' <<<"$user_repo")
 # : <<'COMMENTBLOCK'
  [[ $repo_name && $user_repo && ! $dl_filename =~ ^# ]] &&
    get_release "$user_repo" "$dl_filename"
  [ $? -eq 0 ] && mv -f "$dl_filename" "$APPVEYOR_JOB_ID/$repo_name-$dl_filename" &&
    sed -i '\|^ *'"$user_repo"' \+'"$dl_filename"'|s/^/  - dl /' $1
  fi
#COMMENTBLOCK
done <"$1"
}

: <<'COMMENTBLOCK'
while read -r line; do 
  user_repo=$(echo "$line" | gawk '/^[[:space:]]*[^ #]/ {print $1}')
  dl_filename=$(echo "$line" | gawk '/^[[:space:]]*[^ #]/ {print $2}')
  [[ -n $user_repo && -n $dl_filename ]] && repo_name=$(echo $user_repo | gawk -F'/' '{print $2}')
  [[ -n $user_repo && -n $dl_filename ]] && get_release "$user_repo" "$dl_filename"
  [ $? -eq 0 ] && mv -f "$dl_filename" "$APPVEYOR_JOB_ID/$repo_name-$dl_filename" && sed -i '/'"$dl_filename"'/s/^/  - dl /' $1
done <$1
: <<'COMMENTBLOCK'
COMMENTBLOCK

function gen_log(){
cp -rf "$1" "$2"
sed -i '1i\
---\
title: "Downloaded file list"\
date: '"$(TZ='Asia/Shanghai' date -R)"'\
description: "jugg"\
draft: false\
tags: ["ls"]\
categories: ["demos"]\
---\
\
\
# commit id\
'"## [$APPVEYOR_REPO_COMMIT](https://ci.appveyor.com/project/lsq/blogsr/builds/$APPVEYOR_BUILD_ID)"'\
\
'"## Download [$APPVEYOR_JOB_ID](https://ci.appveyor.com/api/buildjobs/$APPVEYOR_JOB_ID/artifacts/$APPVEYOR_JOB_ID.zip)"'\
' "$2"
sed -i '## s/$/\n/
 /This file contains/,${
 /^$\|This file contains/!{
  /\(### \+update\| \+- \+dl \+\)/! d
}
}
' "$2"
}

url="https://github.com/lsq/blogsr/issues/1"
update_download_list $url "$1"
download_file "$1" 
gen_log "$1" "$2"
