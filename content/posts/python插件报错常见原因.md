---
title: "Python插件常见报错原因"
date: Mon, 12 Dec 2022 10:29:48 +0800
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
## Python表单插件报错

#### 常用引用
```python
import clr
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.DataEntity')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.ServiceHelper')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference('Kingdee.BOS')
clr.AddReference('System.Data')
clr.AddReference('System')
clr.AddReference("System.Core")
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Log")

from System import *
from System.Data import *
from System.Text import *
from System.Linq import *
from System.Collections import *
from System.Collections.Generic import *
from Kingdee.BOS.JSON import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Const import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.List import *
from Kingdee.BOS.Log import *
from Kingdee.BOS.App.Data import *
from Kingdee.BOS.Orm.Metadata.DataEntity import * 
from Kingdee.BOS.Orm.DataEntity import *
from Kingdee.BOS.Core.Metadata.ConvertElement.PlugIn import * 
from Kingdee.BOS.Core.Metadata.ConvertElement.PlugIn.Args import * 
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.ServiceHelper import * 
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Core.Metadata.EntityElement import *
```

#### C#与Python代码转换

##### str() 与 ToString()
C#中ToString()对应python的str()，但是当返回python的None时，ToString()方法会报错，需要改用str()，或者判断是否为None.

##### list() 与 List<T>()
Python中list()对应C#中的List<T>()，使用的时候需要改写，例如：

C#写法是：`List<LockStockArg> lst=new List<LockStockArg>();`

Python写法就应该是：`lst=List[LockStockArg]();`

**按照这样的方法实例化对象时候，lst.Add(lockStockArgs)就不会报错了**

##### 字符串、字典{}包含
1. 字典包含key：obj.ContainsKey("MoEntryId")
1. string.Contains("key")
1. 


### Reference

原文链接：https://vip.kingdee.com/article/95847781369345280
