---
title: "Git submodule错误操作"
date: Wed, 18 Dec 2019 21:16:35 +0800
description: "Git submodule错误操作"
draft: false
tags: ["git"]
categories: ["linux command tools"]
---

IDEA中GIt克隆时报：
> Server does not allow request for unadvertised object //工程针对子模块最近提交的改动ID

误操作后工程最近改动为：
> -Subproject commit //工程针对子模块上次提交的改动ID<br>
+Subproject commit //工程针对子模块最近提交的改动ID

工程存储的子模块最近改动ID已经超前于子模块存储的最近改动ID，解决方法是移除子模块后重新添加。

### 解决方法

工程的根目录下，Git Bash中依次执行：
``` shell
$ rm -rf 子模块名称
$ git submodule deinit -f 子模块名称
$ rm -rf .git/modules/子模块名称
$ git rm -f 子模块名称
$ git submodule add 子模块存储网址
$ git commit -m '备注'
$ git push
```
然后就可以重新
` $ git clone --recursive ` 工程存储网址

<!-- 原文链接：https://blog.csdn.net/haoranhaoshi/article/details/97181494 -->
