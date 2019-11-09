#!/usr/bin/env bash

set -xe

function get_latest_release() {
  curl --silent "https://api.github.com/repos/${1}/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                 # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' #|
#    xargs -I {} curl -sOL "https://github.com/${1}/archive/"{}'.tar.gz'

}
function get_release(){
  file_list=`curl --silent "https://github.com/${1}/releases" |
    sed  -n 's^.*a href="\('"/${1}"'/releases/download/\)\([^"]*\)".*^\1\2^p'`
  [[ -n $file_list ]] && echo "found files: $file_list"
  #pathd=$(grep $2 <<<"$file_list")
  pathd=$(echo "$file_list" | grep $2)
  [[ -n $pathd ]] && echo -e "Downloading ...........................\n" && curl -sOL "https://github.com$pathd" && echo "--------------finished!--------------------"
}
[[ -n $(get_latest_release $1) ]] && echo "latest release is: $(get_latest_release $1)"
get_release $1 $2
