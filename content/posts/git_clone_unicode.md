---
title: "git_clone中文乱码原因"
date: Tue, 13 Nov 2020 10:51:10 +0800
#description: "git_clone中文乱码原因"
author: lsq
avatar: /me/pk.jpg
cover: /images/git_clone_unicode.jpg
images:
  - /images/git_clone_unicode.jpg
draft: false
tags: ["git", "xxd", "iconv", "printf"]
categories: ["linux command tools"]
---
## windwos 系统中git clone 下来文件名乱码原因
1. github上的文件名原来的编码就utf-8编码
2. git clone 下来的uft-8编码被转为gb18030编码，因为中文的utf-8编码占用3个字节，中文的gb18030只占用两个字节(1,2,4)，会把utf-8三个中的两个字节（此时被当作gb18030编码）再转为utf-8（三个字节），其中遇到错误时会被舍弃，如不想舍弃，需要用到--byte-subst参数，然后再用printf或者echo -e来重新编码。
```
pc@pc-PC MINGW64 /g/tmp/t/LaTeX_Notes
# echo -en `echo -en "texlive安装包下载地址"|iconv --byte-subst="\x%2x" -t utf-8 -f gb18030`|iconv --byte-subst="\x%2x" -f utf-8 -t gb18030
texlive安装包下载地▒\x80
pc@pc-PC MINGW64 /g/tmp/t/LaTeX_Notes
# printf $(echo -en `echo -en "texlive安装包下载地址"|iconv --byte-subst="\x%2x" -t utf-8 -f gb18030`|iconv --byte-subst="\x%2x" -f utf-8 -t gb18030)
texlive安装包下载地址
# echo -en "texlive安装包下载地址"|xxd
00000000: 7465 786c 6976 65e5 ae89 e8a3 85e5 8c85  texlive.........
00000010: e4b8 8be8 bdbd e59c b0e5 9d80            ............
pc@pc-PC MINGW64 /g/tmp/t/LaTeX_Notes
# echo -en "0000000: e5ae" |xxd -r |iconv -f gb18030 -t utf-8
瀹
```

