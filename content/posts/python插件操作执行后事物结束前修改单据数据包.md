---
title: "Python插件---操作执行后事物结束前修改单据数据包"
date: Mon, 6 Mar 2023 10:29:48 +0800
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
## 二开案例.服务插件.操作执行后事物结束前修改单据数据包

【应用场景】在单据的某个操作执行后，且该操作的外围事务尚未结束前，修改单据的数据包并在当前事务保护下完成数据库操作。

【案例演示】采购订单执行审核操作后，将采购日期设置为审核日期。

【实现步骤】

<1>编写服务插件，代码如下。

```c#
using Kingdee.BOS.App.Core;
using Kingdee.BOS.Core.DynamicForm.PlugIn;
using Kingdee.BOS.Core.DynamicForm.PlugIn.Args;
using Kingdee.BOS.Util;
using System.ComponentModel;

namespace Jac.XkDemo.BOS.App.PlugIn
{
  /// <summary>
  /// 【服务插件】操作执行后事物结束前修改单据数据包
  /// </summary>
  [HotUpdate]
  [Description("【服务插件】操作执行后事物结束前修改单据数据包")]
  public class UpdateFieldValueInTransactionOperationServicePlugIn :AbstractOperationServicePlugIn

  {
​    /// <summary>
​    /// 操作事物后事件（**事务内触发**）
​    /// </summary>
​    /// <param name="e"></param>
​    /// <remarks>
​    /// 1. 此事件在操作执行代码之后，操作的内部逻辑已经执行完毕
​    /// 2. 此事件在操作事务提交之前
​    /// 3. 此事件中的数据库处理，受操作的事务保护
​    /// 4. 通常此事件，可以用来做同步数据，如同步生成其他单据，而且需要受事务保护
​    /// </remarks>
​    public override void EndOperationTransaction(EndOperationTransactionArgs e)
​    {
​      base.EndOperationTransaction(e);
​      // 保存8提交9审核1反审核26
​      if (this.FormOperation.OperationId == 1)
​      //if (this.FormOperation.Operation.EqualsIgnoreCase("Audit"))
​      {
​        foreach (var dataEntity in e.DataEntitys)
​        {
​          // 审核后设置采购日期等于审核日期
​          dataEntity["Date"] = dataEntity["ApproveDate"];
​        }
​        // 保存变更后的数据
​        new BusinessDataWriter(Context).Save(e.DataEntitys);
​      }
​    }
  }
}
```


作者：Jack

来源：金蝶云社区

原文链接：https://vip.kingdee.com/article/114026264071335936?productLineId=1&isKnowledge=2

著作权归作者所有。未经允许禁止转载，如需转载请联系作者获得授权。

```python
import clr

clr.AddReference('mscorlib')
clr.AddReference('Kingdee.BOS.App.Core')
from Kingdee.BOS.App.Core import *
from Newtonsoft.Json import JsonConvert
from Newtonsoft.Json.Linq import *

def OnPreparePropertys(e):
    e.FieldKeys.Add("FApplicationDate");
    #e.FieldKeys.Add("字段标识");#这里使用的是字段标识，后面从数据包取值用的是绑定实体属性


def EndOperationTransaction(e):
    if this.FormOperation.OperationId == 1:
        for dataEntity in e.DataEntitys:
            #审核后设置采购日期等于审核日期        		
        	#	msg=JsonConvert.SerializeObject(dataEntity);
		#	raise Exception(msg);
            dataEntity["ApplicationDate"] = dataEntity["ApproveDate"];
            BusinessDataWriter(this.Context).Save(e.DataEntitys);
```