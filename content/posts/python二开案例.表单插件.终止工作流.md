---
title: "Python插件---表单插件.终止工作流"
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
## 二开案例.表单插件.终止工作流

#### C#代码

【应用场景】通过插件的方式，对已启动流程的单据，执行终止流程操作（仅终止流程，不执行反审核操作）。

【案例演示】打开采购订单编辑界面，先提交流程，再点击test菜单，流程被结束，单据状态则仍然是审核中，效果如下图。

原文链接：https://vip.kingdee.com/article/421613234215665408?productLineId=1&isKnowledge=2

```c#
using Kingdee.BOS;
using Kingdee.BOS.Core.Bill.PlugIn;
using Kingdee.BOS.Core.DynamicForm;
using Kingdee.BOS.Core.DynamicForm.PlugIn.Args;
using Kingdee.BOS.Core.Metadata.FormElement;
using Kingdee.BOS.Orm;
using Kingdee.BOS.ServiceHelper;
using Kingdee.BOS.Util;
using Kingdee.BOS.Workflow.Models.EnumStatus;
using Kingdee.BOS.Workflow.ServiceHelper;
using System.ComponentModel;
using System.Linq;
namespace Jac.XkDemo.BOS.Business.PlugIn
{
    /// <summary>
    /// 【单据插件】终止流程
    /// </summary>
    [Description("【单据插件】终止流程"), HotUpdate]
    public class AbortProcInstBillPlugIn : AbstractBillPlugIn
    {
        public override void BarItemClick(BarItemClickEventArgs e)
        {
            base.BarItemClick(e);
            if (e.BarItemKey == "test")
            {
                var result = AbortProcInst(this.Context, this.View.BillBusinessInfo.GetForm().Id, new object[] { this.Model.DataObject[0].ToString() });
                this.View.ShowOperateResult(result.OperateResult);
            }
        }
        /// <summary>
        /// 终止流程（仅终止流程，不执行反审核操作）
        /// </summary>
        /// <param name="ctx">上下文</param>
        /// <param name="formId">业务对象标识</param>
        /// <param name="pkids">单据内码集合</param>
        /// <returns>返回操作结果</returns>
        private static IOperationResult AbortProcInst(Context ctx, string formId, object[] pkids)
        {
            var formMetadata = FormMetaDataCache.GetCachedFormMetaData(ctx, formId);
            var abortOp = formMetadata.BusinessInfo.GetForm().FormOperations.FirstOrDefault(p => p.OperationId == FormOperation.Operation_AbortProcInst);
            var operationNumber = abortOp == null ? string.Empty : abortOp.Operation;
            // 获取单据上尚未完成的流程实例的内码
            var dic = ProcManageServiceHelper.GetUnCompletedProcInstIds(ctx, formId, pkids);
            var existIds = dic.Where(m => !string.IsNullOrWhiteSpace(m.Value)).ToList();
            if (existIds.Count == 0)
            {
                var resultError = new OperationResult();
                resultError.IsSuccess = false;
                resultError.OperateResult.Add(new OperateResult
                {
                    SuccessStatus = false,
                    MessageType = MessageType.FatalError,
                    Message = "单据没有关联工作流实例，不需要终止！"
                });
                return resultError;
            }
            var option = OperateOption.Create();
            option.SetVariableValue("abortDisposition", "");
            option.SetVariableValue("procOperationType", ProcOperationType.Abort);
            option.SetVariableValue("ProcInstIds", existIds.Select(m => m.Value).ToArray());// 必填
            var result = BusinessDataServiceHelper.AbortProcInst(ctx, formMetadata.BusinessInfo, pkids, operationNumber, option);
            return result;
        }
    }
}
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
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Core.Metadata.EntityElement import *
from Kingdee.BOS.Core.Metadata.ControlElement import *;

#<1>此案例仅简单演示如何通过修改元数据的方式动态创建按钮，因为涉及到运行时修改元数据，具有一定的风险性（元数据缓存问题），非必要不推荐。

#<2>界面有本地缓存，需清空本地缓存后，动态创建的元素才会显示。
#作者：Jack
#来源：金蝶云社区
#原文链接：https://vip.kingdee.com/article/400656742037723136?productLineId=1&isKnowledge=2
#
global ButtonKey
ButtonKey="F_Jac_Button"; 
def OnSetLayoutInfo(e):
    global ButtonKey
    layoutInfo = this.View.LayoutInfo;
    button = ButtonAppearance();
    button.Key = ButtonKey;
    #raise Exception(JsonConvert.SerializeObject(layoutInfo.GetAppearance(button.Key)))
    if (layoutInfo.GetAppearance(button.Key) == None):
       #raise Exception("haha:" + JsonConvert.SerializeObject(layoutInfo.GetAppearance(button.Key)))
       #raise Exception(button.Key)
       layoutInfo.Add(button);
       # 不同表单的Container属性不同
       #button.Container = "FHEADBASEPAGE"; # 采购订单
       button.Container = 'FTABREQUISITIONBASE'
       button.Left = LocaleValue("800", this.Context.UserLocale.LCID);
       button.Top = LocaleValue("500", this.Context.UserLocale.LCID);
       button.Width = LocaleValue("200", this.Context.UserLocale.LCID);
       button.Caption = LocaleValue("动态按钮测试", this.Context.UserLocale.LCID);
       button.Id = "6b0ee640209f4277a813674d646eee3b";
       button.ShowTitle = 1
       button.ZOrderIndex = 14
       button.Tabindex = 10
       button.Visible = 2147483647
       e.LayoutInfo = layoutInfo;
       e.BillLayoutInfo = e.LayoutInfo
def BeforeDoOperation(e):
	if e.Operation.FormOperation.OperationId == 9:
		#raise Exception(str(e.Operation.FormOperation.OperationId))
		e.Option.SetVariableValue("lsq", "happy")
		e.Option.SetVariableValue("ypj", "liu!")
#相应的服务插件代码如下：
#def BeforeExecuteOperationTransaction(e):
#	if (this.FormOperation.OperationId == 9) :
#		#raise Exception("haha,lsq")
#		if this.Option.ContainsVariable("lsq") and this.Option.ContainsVariable("ypj"):
#			OpResult = OperationResult()
#			#raise Exception(str(this.Option.GetVariables()["lsq"]) + ", " + str(this.Option.GetVariables()["ypj"]))
def ButtonClick(e):
    global ButtonKey
    if (e.Key.Equals(ButtonKey, StringComparison.OrdinalIgnoreCase)):
		this.View.ShowMessage("动态创建的按钮被点击啦！");

# https://vip.kingdee.com/questions/369806352660577280?productLineId=1
def BarItemClick(e):
        
        global ButtonKey
        layoutInfo = this.View.LayoutInfo;
        
        if e.BarItemKey == "test":
    		#raise Exception(JsonConvert.SerializeObject(this.Model.DataObject))
    		#F_ora_AttachList
    		#raise Exception("haha:" + JsonConvert.SerializeObject(layoutInfo.GetAppearance("F_ora_AttachList")))
    		#raise Exception("haha:" + JsonConvert.SerializeObject(layoutInfo.GetAppearance(ButtonKey)))
		# Array.CreateInstance(type, len(tempList));
		#原文链接：https://vip.kingdee.com/link/s/lHQTI
		#tempList = filter(lambda x:x["FBomLevel"] == 1, e.DataObjects);
		#Array.CreateInstance(e.DataObjects[0].GetType(), len(tempList));
		#rasie Exception()
		tempList = list();
		tempList.append(this.Model.DataObject[0].ToString())
		# <type 'Array[Int64]'>
		pkIds = Array.CreateInstance(this.Model.DataObject[0].ToString().GetType(),len(tempList))
		#raise Exception(str(type(pkIds)))		
		for index in range(len(pkIds)):
			pkIds[index] = str(tempList[index])
		#raise Exception(str(type(pkIds)))		
		result = AbortProcInst(this.Context, this.View.BillBusinessInfo.GetForm().Id, pkIds);
		this.View.ShowOperateResult(result.OperateResult);
       
        #/// <summary>
        #/// 终止流程（仅终止流程，不执行反审核操作）
        #/// <param name="ctx">上下文</param>
        #/// <param name="formId">业务对象标识</param>
        #/// <param name="pkids">单据内码集合</param>
        #/// <returns>返回操作结果</returns>
def AbortProcInst(ctx, formId,  pkids):
    formMetadata = FormMetaDataCache.GetCachedFormMetaData(ctx, formId);
    #p = formMetadata.BusinessInfo.GetForm().FormOperations.FirstOrDefault
    p = formMetadata.BusinessInfo.GetForm().FormOperations
    # <type 'List[FormOperation]'> 
    #raise Exception(str(type(p)))
    #raise Exception("/".join(str(i) for i in p))
    #abortOp = ( p.OperationId == FormOperation.Operation_AbortProcInst);
    for OpId in p:
    	if OpId.OperationId == FormOperation.Operation_AbortProcInst:
    		abortOp = OpId
    operationNumber = "" if abortOp == None  else abortOp.Operation;
    #// 获取单据上尚未完成的流程实例的内码
    #raise Exception(str(type(pkids)))
    dic = ProcManageServiceHelper.GetUnCompletedProcInstIds(ctx, formId, pkids);
    #existIds = dic.Where(m => !string.IsNullOrWhiteSpace(m.Value)).ToList();
    existIds = List[str]();
    for  m in dic:
		if str(m.Value) <> None and str(m.Value) <> "":
			existIds.Add(m.Value)
    if (len(existIds) == 0):    	
    	resultError = OperationResult();
    	resultError.IsSuccess = False;
    	nOpResult = OperateResult()
    	nOpResult.SuccessStatus = False
    	nOpResult.MessageType = MessageType.FatalError
    	nOpResult.Message = "单据没有关联工作流实例，不需要终止！"
    	resultError.OperateResult.Add(nOpResult)
    	return resultError;            
    option = OperateOption.Create();
    option.SetVariableValue("abortDisposition", "");
    option.SetVariableValue("procOperationType", ProcOperationType.Abort);
    #raise Exception(str(type(existIds)))
    option.SetVariableValue("ProcInstIds", existIds.ToArray()); # 必填
    result = BusinessDataServiceHelper.AbortProcInst(ctx, formMetadata.BusinessInfo, pkids, operationNumber, option);
    return result;

```