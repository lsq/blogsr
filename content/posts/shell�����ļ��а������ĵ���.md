---
title: "shell查找文件中包含中文的行"
date: Tue, 10 Nov 2020 10:51:10 +0800
description: "shell查找文件中包含中文的行"
draft: false
tags: ["bash"]
categories: ["linux command tools"]
---
## shell查找文件中包含中文的行

`awk '/[^!-~]/' file`

asscii码从!到~中包含所有的大小写字母，和英文符号

`cat file | grep "[^\u4e00-\u9fa5]"`
