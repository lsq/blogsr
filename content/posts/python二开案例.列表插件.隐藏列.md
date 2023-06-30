---
title: "Python插件---列表插件.隐藏列"
date: Wed, 29 Mar 2023 10:29:48 +0800
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
## 二开案例.列表插件.隐藏列

#### C#代码

【应用场景】使用列表插件对列表的列是否显示隐藏进行干预。

注意：通过此方案隐藏列是针对所有过滤方案生效。

【案例演示】采购订单，列表查询，使用列表插件隐藏单据编号和采购日期列。

原文链接：https://vip.kingdee.com/article/152738343620017920?channel_level=%E9%87%91%E8%9D%B6%E4%BA%91%E7%A4%BE%E5%8C%BA%7C%E6%90%9C%E7%B4%A2%7C%E7%BB%BC%E5%90%88&productLineId=1&isKnowledge=2

```c#
using Kingdee.BOS.Core.List.PlugIn;

using Kingdee.BOS.Core.List.PlugIn.Args;

using Kingdee.BOS.JSON;

using Kingdee.BOS.Util;

using System;

using System.Collections.Generic;

using System.ComponentModel;



namespace Jac.XkDemo.BOS.Business.PlugIn

{

    /// <summary>

    /// 【列表插件】使用ListCreateColumns事件隐藏列

    /// </summary>

    [Description("【列表插件】使用ListCreateColumns事件隐藏列"), HotUpdate]

    public class HideColumnByListCreateListPlugIn : AbstractListPlugIn

    {

        public override void ListCreateColumns(ListCreateColumnsEventArgs e)

        {

            base.ListCreateColumns(e);

            // 采购订单列表始终不显示单据编号列和采购日期列

            var needHideColumns = new HashSet<string>(new[] { "FBillNo", "FDate" }, StringComparer.OrdinalIgnoreCase);

            foreach (JSONObject co in e.Columns)

            {

                var columnName = co.Get("dataIndex").ToString();

                if (needHideColumns.Contains(columnName))

                {

                    co.Put("visible", false);

                }

            }

        }

    }

}
作者：Jack
来源：金蝶云社区
原文链接：https://vip.kingdee.com/article/152738343620017920?channel_level=%E9%87%91%E8%9D%B6%E4%BA%91%E7%A4%BE%E5%8C%BA%7C%E6%90%9C%E7%B4%A2%7C%E7%BB%BC%E5%90%88&productLineId=1&isKnowledge=2
著作权归作者所有。未经允许禁止转载，如需转载请联系作者获得授权。

```


作者：Jack

来源：金蝶云社区

原文链接：[二开案例.单据插件.终止流程 (kingdee.com)](https://vip.kingdee.com/article/421613234215665408?productLineId=1&isKnowledge=2)

著作权归作者所有。未经允许禁止转载，如需转载请联系作者获得授权。

#### Python 代码

```python
import clr #line:2
clr .AddReference ("Kingdee.BOS")#line:4
clr .AddReference ("Kingdee.BOS.Core")#line:5
clr .AddReference ("Kingdee.BOS.App")#line:6
clr.AddReference('Kingdee.BOS.DataEntity')
clr.AddReference('Kingdee.BOS.ServiceHelper')
clr .AddReference ("mscorlib")#line:8
clr .AddReference ("System.Data")#line:9
clr.AddReference('System')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference("System.Core")
clr.AddReference('Newtonsoft.Json')
clr.AddReference('Kingdee.BOS.Workflow.Models')
clr.AddReference('Kingdee.BOS.Workflow.ServiceHelper')

from Kingdee .BOS import *#line:10
from Kingdee .BOS .App .Data import *#line:11
from Kingdee .BOS .Core import *#line:12
from Kingdee.BOS.Core.DynamicForm import *
from Kingdee .BOS .Core .DynamicForm .PlugIn import *#line:13
from Kingdee .BOS .Core .DynamicForm .PlugIn .Args import *#line:14
from Kingdee .BOS .Util import *#line:15
from Kingdee .BOS .Core .Metadata import *#line:16
from Kingdee .BOS .Core .Metadata .EntityElement import *#line:17
from Kingdee .BOS .Core .Validation import *#line:18
from Kingdee .BOS .Log import Logger #line:19
from System import *#line:20
#from System .Collections .Generic import *#line:22
from System .Data import *#line:23
from System.ComponentModel import *;
from System.Linq import *;
from System.Diagnostics import *
from Newtonsoft.Json import JsonConvert
from Newtonsoft.Json.Linq import *
from Kingdee.BOS.Core.List.PlugIn import *;
from Kingdee.BOS.Core.List.PlugIn.Args import *;
from Kingdee.BOS.JSON import *;
from Kingdee.BOS.Core.Bill.PlugIn import *;
#from Kingdee.BOS.Core.Metadata import *
from Kingdee.BOS.Core.Metadata.FormElement import *;
from Kingdee.BOS.Core.Metadata import *
from Kingdee.BOS.Orm import *;
#from Kingdee.BOS.Orm.DataEntity import*
from Kingdee.BOS.Workflow.Models.EnumStatus import *;
from Kingdee.BOS.Workflow.ServiceHelper import *;
#from System.Data import *
from System.Text import *
from System.Collections import *
from System.Collections.Generic import *
#from Kingdee.BOS.App.Data import *
from Kingdee.BOS.Orm.Metadata.DataEntity import * 
from Kingdee.BOS.Orm.DataEntity import *
from Kingdee.BOS.Core.Metadata.ConvertElement.PlugIn import * 
from Kingdee.BOS.Core.Metadata.ConvertElement.PlugIn.Args import * 
#from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.ServiceHelper import * 
from Kingdee.BOS.Core.Metadata.EntityElement import *

def ListCreateColumns(e):	
  needHideColumns = [ "FBillNo", "FDate" ];
  for co in (e.Columns):
  	#1=1
  	columnName = co.Get("dataIndex").ToString();
  	if (columnName in needHideColumns):
	  co.Put("visible", False);
```