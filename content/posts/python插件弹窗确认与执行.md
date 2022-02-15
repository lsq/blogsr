---
title: "Python插件弹窗确认与执行"
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
## Python插件弹窗确认与执行

### 应用场景

用户编辑单据后，点击按钮后提示并要求确认![20211220103741](https://raw.githubusercontent.com/lsq/blogsr/master/content/posts/python插件测试/20211220103741.png)

### 方案

在表单插件中增加python插件

```python
import clr;
clr.AddReference("System")
clr.AddReference("Kingdee.BOS.Core")
from System import Action
from Kingdee.BOS.Core.DynamicForm import MessageBoxResult
from Kingdee.BOS.Core.DynamicForm import MessageBoxOptions
def BarItemClick(e):
	if e.BarItemKey.ToUpper()=="TBCHECK":
		action=Action[MessageBoxResult](callback)
		this.View.ShowWarnningMessage("是否执行检测操作？", "", MessageBoxOptions.YesNo,action)
def callback(r):
	if r== MessageBoxResult.Yes:
		this.View.ShowMessage("do something...")
		#.....To do Somethin
```

原文链接：https://vip.kingdee.com/article/238762823747025152
