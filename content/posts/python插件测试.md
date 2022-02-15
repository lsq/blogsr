---
title: "Python插件测试"
date: Mon, 20 Dec 2021 08:47:46 +0800
#description: "vba导出pdf或者png"
author: lsq
avatar: /me/pk.jpg
cover: /images/python_get_objects.jpg
images:
  - /images/python_get_objects.jpg
draft: false
tags: ["金蝶云星空", "BOS", "Python"]
categories: ["BOS"]
---
## Python插件测试

### 应用场景

功能实现需要插件干预，不方便部署C#插件，且业务逻辑较为简单的业务场景。
### 案例演示---实现步骤

#### 1. 登录BOSIDE，扩展采购订单，新增菜单项，如下图所示![652988ed54c1410d929401e3224d9b64](https://raw.githubusercontent.com/lsq/blogsr/master/content/posts/python插件测试/652988ed54c1410d929401e3224d9b64.png)

#### 2. 在采购订单的表单插件上注册Python插件，如下图所示。![7c39c673702d49c88e4fce1a115a9a89](https://raw.githubusercontent.com/lsq/blogsr/master/content/posts/python插件测试/7c39c673702d49c88e4fce1a115a9a89.png)![7b048cf669a6449fb4d22067374a054f](https://raw.githubusercontent.com/lsq/blogsr/master/content/posts/python插件测试/7b048cf669a6449fb4d22067374a054f.png)

#### 3. BarItem 事件

菜单自定义按钮（BarItem）点击事件Click，可以定义相关操作。

```python
# 第一步：按照需要添加程序集引用
import clr
clr.AddReference('mscorlib')
from System import *
# 第二步：添加插件事件对应的方法
def BarItemClick(e):
 #第三步：添加业务逻辑代码
 if e.BarItemKey == "tbTest":
 	userName = this.Context.UserName
 	msg = userName + "，您好！"
 	this.View.ShowMessage(msg)
```

### Reference

原文链接：https://vip.kingdee.com/article/95847781369345280
