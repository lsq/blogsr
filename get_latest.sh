#!/usr/bin/env bash

set -xuo pipefail

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
  [[ -n $file_list ]] && local pathd=$(echo "$file_list" | grep "$2" | head -n 1)
  [[ -n $pathd ]] && echo -e "Begin downloading ...........................\n" && curl -sOL "https://github.com$pathd" && echo "--------------finished!--------------------"
}
# [[ -n $(get_latest_release $1) ]] && echo "latest release is: $(get_latest_release $1)"
while read -r line; do 
  user_repo=$(echo "$line" | gawk '/^([[:space:]]*)[^ #]/ {print $1}')
  dl_filename=$(echo "$line" | gawk '/^([[:space:]]*)[^ #]/ {print $2}')
  [[ -n $user_repo && -n $dl_filename ]] && get_release "$user_repo" "$dl_filename"
  [ $? -eq 0 ] && mv -f "$dl_filename" $APPVEYOR_JOB_ID/ && sed -i '/'"$dl_filename"'/s/^/###dl /' $1
done <$1
cp -rf $1 content/posts/downloaded.md
