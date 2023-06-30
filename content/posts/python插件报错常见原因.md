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
clr.AddReference('Newtonsoft.Json')

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
from Newtonsoft.Json import JsonConvert
from Newtonsoft.Json.Linq import *
```

#### C#与Python代码转换

##### str() 与 ToString()
C#中ToString()对应python的str()，但是当返回python的None时，ToString()方法会报错，需要改用str()，或者判断是否为None.

##### list() 与 List<T>()
Python中list()对应C#中的List<T>()，使用的时候需要改写，例如：

C#写法是：`List<LockStockArg> lst=new List<LockStockArg>();`

Python写法就应该是：`lst=List[LockStockArg]();`

**按照这样的方法实例化对象时候，lst.Add(lockStockArgs)就不会报错了**

- **模板类：**把"<T>"改成"[T]"，例如,C#中:var lst=new List<sting>()。Python插件中写成:lst=List\[str\]();
- **反射代理：**C#插件中有时会用到反射代理类。在Python插件中将反射代理的类直接实例化进行使用。例如：

  **C#代码中：**

  IViewService viewService1 = Kingdee.BOS.Contracts.ServiceFactory.GetService<**IViewService**>(this.Context);

  **Python插件中写成**：viewService1 =**ViewService();当然，还需要引入\**ViewService\**类的命名空间。**
  
- list转数组，需要用到ToArray()方法，前提是，不要用Python的list，要用C#的List\[T\]()，否则构造的数据调用插件的一些方法是不被识别的

原文链接：https://vip.kingdee.com/article/332534862269551872?productLineId=1



##### 字符串、字典{}包含
1. 字典包含key：obj.ContainsKey("MoEntryId")
1. string.Contains("key")
1. 


### Reference

原文链接：https://vip.kingdee.com/article/95847781369345280
