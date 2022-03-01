---
title: "Python列表动态创建列"
date: Tue, 01 Mar 2022 14:39:38 +0800
#description: "vba导出pdf或者png"
author: lsq
avatar: /me/pk.jpg
cover: /images/pexels-magda-ehlers-2602522.jpg
images:
  - /images/pexels-magda-ehlers-2602522.jpg
draft: false
tags: ["金蝶云星空", "BOS", "Python"]
categories: ["BOS"]
---
## [Python列表动态创建列](https://vip.kingdee.com/article/180718498895968768?cid=286138114425812480)

### 应用场景

列表界面上不依赖过滤方案指定的显示隐藏列配置，通过插件的方式动态的创建列并动态的给列赋值。

### 案例演示
打开采购订单列表，此时，动态列已经创建成功。

```python
# 二开案例.列表插件.列表动态创建列： https://vip.kingdee.com/article/180718498895968768

# 列表动态创建列(Python实现)
import clr 
clr.AddReference("System")
clr.AddReference("System.Core")
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")

from System import *
from Kingdee.BOS import *
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Core.List.PlugIn.Args import *
from Kingdee.BOS.Util import *
from Kingdee.BOS import LocaleValue
from System import StringComparison

def CreateListHeader(e):
    header = e.ListHeader.AddChild() 
    header.Caption = LocaleValue("动态列1")
    header.Key = "FDynamicColumn1"
    header.FieldName = "FDynamicColumn1" 
    header.ColType = SqlStorageType.Sqlnvarchar 
    header.Width = 200 
    header.Visible = True 
    #header.ColIndex = e.ListHeader.GetChilds().Max(o => o.ColIndex) + 1
    maxCol = max(e.ListHeader.GetChilds(), key = lambda x: x.ColIndex)
    header.ColIndex = maxCol.ColIndex + 1

    header = e.ListHeader.AddChild() 
    header.Key = "FDynamicColumn2" 
    header.FieldName = "FDynamicColumn2" 
    header.Caption = LocaleValue("动态列2") 
    header.ColType = SqlStorageType.Sqlnvarchar 
    header.Width = 300 
    header.Visible = True 
    #header.ColIndex = e.ListHeader.GetChilds().Max(o => o.ColIndex) + 1 
    maxCol = max(e.ListHeader.GetChilds(), key = lambda x: x.ColIndex)
    header.ColIndex = maxCol.ColIndex + 1

def FormatCellValue(e):
    if e.Header.Key.Equals("FDynamicColumn1", StringComparison.OrdinalIgnoreCase):
        e.FormateValue = '''{0}=>{1}'''.format(e.Header.Caption, str(DateTime.Now))
    elif e.Header.Key.Equals("FDynamicColumn2", StringComparison.OrdinalIgnoreCase):
        e.FormateValue = '''{0}=>{1}'''.format(e.Header.Caption, Guid.NewGuid())
```