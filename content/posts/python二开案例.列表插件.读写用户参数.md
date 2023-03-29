---
title: "Python插件---列表插件.读写用户参数"
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
## 二开案例.列表插件.读写用户参数

#### C#代码

【应用场景】使用列表插件读写用户参数。

【案例演示】采购订单，列表界面，在列表插件中读写用户参数。

原文链接：https://vip.kingdee.com/article/93756677874226688?productLineId=1&isKnowledge=2

```c#
using Kingdee.BOS.Core;
using Kingdee.BOS.Core.DynamicForm.PlugIn.Args;
using Kingdee.BOS.Core.List.PlugIn;
using Kingdee.BOS.ServiceHelper;
using Kingdee.BOS.Util;
using Kingdee.BOS.Web.List;
using System.ComponentModel;

namespace Jac.XkDemo.BOS.Business.PlugIn
{
    /// <summary>
    /// 【列表插件】读写用户参数
    /// </summary>
    [Description("【列表插件】读写用户参数"), HotUpdate]
    public class ReadAndWriteUserParameterListPlugIn : AbstractListPlugIn
    {
        public override void BarItemClick(BarItemClickEventArgs e)
        {
            base.BarItemClick(e);
            if (e.BarItemKey.EqualsIgnoreCase("tbReadUserParameter"))
            {
                var auxMustInput = ReadUserParameter("AuxMustInput");
                // var auxMustInput = ReadUserParameter2("AuxMustInput"); // 另一种读取用户参数的方法
                this.View.ShowMessage("用户参数【辅助属性必录】：" + auxMustInput);
                return;
            }
            if (e.BarItemKey.EqualsIgnoreCase("tbWriteUserParameter"))
            {
                var isOk = WriteUserParameter("AuxMustInput", true);
                this.View.ShowMessage(isOk ? "用户参数保存成功" : "用户参数保存失败");
                return;
            }
        }
        /// <summary>
        /// 读取用户参数（直接从数据库读取）
        /// </summary>
        /// <param name="parameterName">用户参数的实体属性名</param>
        /// <returns></returns>
        private object ReadUserParameter(string parameterName)
        {
            // 获取用户参数的业务对象标识
            var formId = this.View.BillBusinessInfo.GetForm().ParameterObjectId;
            if (formId == null || formId.Trim().Length == 0)
            {
                formId = FormIdConst.BOS_BillUserParameter;
            }
            var formMetadata = FormMetaDataCache.GetCachedFormMetaData(this.Context, formId);
            // 读取用户参数包
            var parameterData = UserParamterServiceHelper.Load(this.Context, formMetadata.BusinessInfo, this.Context.UserId, this.View.BillBusinessInfo.GetForm().Id, KeyConst.USERPARAMETER_KEY);
            // 从用户参数包中获取某一个参数
            if (parameterData != null && parameterData.DynamicObjectType.Properties.Contains(parameterName))
            {
                return parameterData[parameterName];
            }
            return null;
        }
        /// <summary>
        /// 读取用户参数（从Model中读取）
        /// </summary>
        /// <param name="parameterName">用户参数的实体属性名</param>
        /// <returns></returns>
        private object ReadUserParameter2(string parameterName)
        {
            // 获取列表视图
            var listView = (ListView) this.View;
            // 从用户参数包中获取某一个参数
            if (listView.Model.ParameterData != null && listView.Model.ParameterData.DynamicObjectType.Properties.Contains(parameterName))
            {
                return listView.Model.ParameterData[parameterName];
            }
            return null;
        }
        /// <summary>
        /// 保存用户参数
        /// </summary>
        /// <param name="parameterName"></param>
        /// <param name="parameterValue"></param>
        /// <returns></returns>
        private bool WriteUserParameter(string parameterName, object parameterValue)
        {
            // 获取用户参数的业务对象标识
            var formId = this.View.BillBusinessInfo.GetForm().ParameterObjectId;
            if (formId == null || formId.Trim().Length == 0)

            {
                formId = FormIdConst.BOS_BillUserParameter;
            }
            var formMetadata = FormMetaDataCache.GetCachedFormMetaData(this.Context, formId);
            // 读取用户参数包
            var parameterData = UserParamterServiceHelper.Load(this.Context, formMetadata.BusinessInfo, this.Context.UserId, this.View.BillBusinessInfo.GetForm().Id, KeyConst.USERPARAMETER_KEY);
            // 从用户参数包中获取某一个参数
            if (parameterData != null && parameterData.DynamicObjectType.Properties.Contains(parameterName))
            {
                // 保存用户参数
                parameterData[parameterName] = parameterValue;

                return UserParamterServiceHelper.Save(this.Context, formMetadata.BusinessInfo, parameterData, this.View.BillBusinessInfo.GetForm().Id, this.Context.UserId, KeyConst.USERPARAMETER_KEY);
            }
            return false;
        }
    }
}
/*
-- 查询用户参数
SELECT * FROM T_BAS_USERPARAMETER 
*/

//原文链接：https://vip.kingdee.com/article/93756677874226688?productLineId=1&isKnowledge=2


```


作者：Jack

来源：金蝶云社区

原文链接：https://vip.kingdee.com/article/114026264071335936?productLineId=1&isKnowledge=2

著作权归作者所有。未经允许禁止转载，如需转载请联系作者获得授权。

#### Python 代码

```python
#引入clr运行库
# -*- coding: utf-8 -*-
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#clr.AddReference('Kingdee.BOS.KDSReportEntity')
#clr.AddReference('Kingdee.BOS.App.KDSService')
clr.AddReference('Newtonsoft.Json')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Util import *
#from Kingdee.BOS.Web.List import *
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from System.ComponentModel import *
from Kingdee.BOS.ServiceHelper import *
from Kingdee.BOS.JSON import *
from Newtonsoft.Json.Linq import *

def BarItemClick(e):
	if (e.BarItemKey == "tbReadUserParameter"):
		auxMustInput = ReadUserParameter("AuxMustInput");
		#// var auxMustInput = ReadUserParameter2("AuxMustInput"); // 另一种读取用户参数的方法
		this.View.ShowMessage("用户参数【辅助属性必录】：" + str(auxMustInput));
		return;
             
	if (e.BarItemKey == "tbWriteUserParameter"):
		isOk = WriteUserParameter("AuxMustInput", True);
		this.View.ShowMessage( "用户参数保存成功"  if isOk else "用户参数保存失败");
		return;
def  ReadUserParameter(parameterName):
	#// 获取用户参数的业务对象标识
	formId = this.View.BillBusinessInfo.GetForm().ParameterObjectId;
	if (formId == None or formId.Trim().Length == 0):
		formId = FormIdConst.BOS_BillUserParameter;
	formMetadata = FormMetaDataCache.GetCachedFormMetaData(this.Context, formId);

            #// 读取用户参数包
	parameterData = UserParamterServiceHelper.Load(this.Context, formMetadata.BusinessInfo, this.Context.UserId, this.View.BillBusinessInfo.GetForm().Id, KeyConst.USERPARAMETER_KEY);

            #// 从用户参数包中获取某一个参数

	if (parameterData != None and parameterData.DynamicObjectType.Properties.Contains(parameterName)):
		return parameterData[parameterName];
	return ;
def  WriteUserParameter(parameterName, parameterValue):
            #// 获取用户参数的业务对象标识

		formId = this.View.BillBusinessInfo.GetForm().ParameterObjectId;
		if (formId == None or formId.Trim().Length == 0):
			formId = FormIdConst.BOS_BillUserParameter;
		formMetadata = FormMetaDataCache.GetCachedFormMetaData(this.Context, formId);

            #// 读取用户参数包
		parameterData = UserParamterServiceHelper.Load(this.Context, formMetadata.BusinessInfo, this.Context.UserId, this.View.BillBusinessInfo.GetForm().Id, KeyConst.USERPARAMETER_KEY);
            #// 从用户参数包中获取某一个参数
		if (parameterData != None and parameterData.DynamicObjectType.Properties.Contains(parameterName)):
                #// 保存用户参数
			parameterData[parameterName] = parameterValue;
			return UserParamterServiceHelper.Save(this.Context, formMetadata.BusinessInfo, parameterData, this.View.BillBusinessInfo.GetForm().Id, this.Context.UserId, KeyConst.USERPARAMETER_KEY);
		return false;

#https://vip.kingdee.com/article/93756677874226688?productLineId=1&isKnowledge=2


```