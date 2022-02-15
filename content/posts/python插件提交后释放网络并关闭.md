---
title: "python插件提交后刷新当前单据"
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
## Python插件提交后刷新当前单据

### 应用场景

用户编辑单据后，点击提交启动了工作流示例，此时并没有释放网络控制，其他用户打开该单据会有如下 提示![f767e173c48f4bf0acae66fea7c8bdaf](https://raw.githubusercontent.com/lsq/blogsr/master/content/posts/python插件测试/f767e173c48f4bf0acae66fea7c8bdaf.png)

### 方案

在表单插件中增加python插件，在提交成功后自动刷新当前单据

```python
import clr
clr.AddReference("System")
clr.AddReference("System.Core")
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from System import *
def AfterDoOperation(e): 
  if e.Operation.Operation.upper() == "SUBMIT" and e.ExecuteResult:
	this.View.InvokeFormOperation("Refresh")
	this.View.ShowMessage("hello, lsq")
	# 自动关闭单据
	this.View.InvokeFormOperation("Close");
```

原文链接：https://vip.kingdee.com/article/238668613153336320
