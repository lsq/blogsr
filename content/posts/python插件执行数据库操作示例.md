---
title: "Python插件执行数据库操作示例"
date: Mon, 21 Dec 2021 08:47:46 +0800
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

###  操作数据库示例 1

```python
import clr
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("Kingdee.BOS.App")
from Kingdee.BOS.App.Data import *
from Kingdee.BOS import *
from System import *
def BarItemClick(e):
	if e.BarItemKey == "tbHello":
		this.View.ShowMessage("操作开始");
		DBUtils.Execute(this.Context, "UPDATE t_PUR_POOrder SET F_ORA_REMARKS='aha数据被修改了--' where FBILLNO='PO20211214001' ",None,False);
         # UPDATE T_TABLE SET D = A + B -C WHERE ID=11
		#this.View.InvokeFormOperation("Refresh")
         # 操作数据库成功后，重新刷新单据获取数据
		this.View.Refresh()
```

### 操作数据库示例2

#### 应用场景

销售出库单，点击按钮，执行数据库，更新全部单据，[备注信息](https://vip.kingdee.com/article/66914031969567232)

#### 实现步骤

```c#
//点击按钮事件
public override void BarItemClick(BOS.Core.DynamicForm.PlugIn.Args.BarItemClickEventArg
s e)
{
base.BarItemClick(e);
//当点击YDIE_tbTest按钮,触发
if(e.BarItemKey == "YDIE_tbTest")
{
//执行sql语句返回Int，表示影响了多少行
int x = DBUtils.Execute(this.Context, "/*dialect*/update T_SAL_OUTSTOCKENTRY set FNOTE ='测
试'");
//弹窗显示
this.View.ShowMessage(x.ToString());
}
}
```

### 操作数据库示例3

#### 应用场景

生产用料清单上添加自定义字段---欠料数量，计算逻辑为欠料数量=未领数量+作业不良退料数量-补料数量

#### 实现步骤

```python
import clr
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("Kingdee.BOS.App")
from Kingdee.BOS.App.Data import *
from Kingdee.BOS import *
from System import *
def BarItemClick(e):
	if (e.BarItemKey.Equals("tbHello",StringComparison.OrdinalIgnoreCase)):
		#this.View.ShowMessage("操作开始");
        # 注意数据库的分库分表
		#sql= "UPDATE T_PRD_PPBOMENTRY_Q SET F_MAXEYE_WLSL=FNOPICKEDQTY-FREPICKEDQTY+FPRCDEFECTRETURNQTY"
		n = DBUtils.Execute(this.Context,"/*dialect*/ update T_PRD_PPBOMENTRY_Q set F_MAXEYE_WLSL=FNOPICKEDQTY-FREPICKEDQTY+FPRCDEFECTRETURNQTY")
		#DBUtils.Execute(this.Context,sql)
		this.View.ShowMessage("操作成功--影响数据条数：" + n.ToString())
		#this.View.ShowMessage("操作成功--影响数据条数：")
		this.View.Refresh()
```

```python
# 打开单据自动计算欠料数量
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
from Kingdee.BOS.Core import *
def BeforeBindData(e):
	rows=this.Model.GetEntryRowCount("FEntity");#获取单据体行数
	for i in range(0,rows,1):
		if this.Model.GetValue("FIssueType",i) != '7':
			a = this.Model.GetValue("FNoPickedQty",i) - this.Model.GetValue("FRePickedQty",i) + this.Model.GetValue("FProcessDefectReturnQty",i);
			this.Model.SetValue("F_maxeye_Wlsl",a,i);
			this.View.UpdateView("FA_DEPRADJUSTENTRY");
```

### Python保存自动调用提交审核

#### 应用场景

其他入库单保存后，自动提交审核

#### 实现步骤

```python
import clr
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference('Kingdee.BOS.ServiceHelper')
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Contracts import *
from Kingdee.BOS.App import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from System import *
from System.Data import *
from System.Text import *
from System.Collections import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *
def EndOperationTransaction(e):
    idList = List[object]()
    for billObj in e.DataEntitys:
        BillId = str(billObj["Id"])
        idList.Add(BillId)
    pkArray = idList.ToArray()
    formID = this.BusinessInfo.GetForm().Id
    meta = MetaDataServiceHelper.Load(this.Context, formID)
    submitOption = None
    subResult=BusinessDataServiceHelper.Submit(this.Context,meta.BusinessInfo,pkArray,"Submit",submitOption)
    if (subResult.IsSuccess == True):
        auditOption = None
        auditResult = BusinessDataServiceHelper.Audit(this.Context,meta.BusinessInfo,pkArray,auditOption)
```



### 操作成功后执行SQL

#### 应用场景

单据上的菜单绑定了某种操作，当点击该菜单时，会触发绑定在该菜单上的操作，当操作执行成功后，执行一段SQL。

#### 案例演示

采购订单，审核菜单，绑定了审核操作，点击审核菜单触发审核操作并执行成功后，执行一段SQL。

#### 实现步骤

```c#
using Kingdee.BOS.App.Data;
using Kingdee.BOS.Core.DynamicForm.PlugIn;
using Kingdee.BOS.Core.DynamicForm.PlugIn.Args;
using Kingdee.BOS.Util;
using System.ComponentModel;
namespace Jac.XkDemo.BOS.Business.PlugIn
{
 /// <summary>
 /// 【表单插件】操作成功后执行SQL
 /// </summary>
 [Description("【表单插件】操作成功后执行SQL"), HotUpdate]
 public class RunSqlAfterOperationFormPlugIn : AbstractDynamicFormPlugIn
 {
 /// <summary>
 /// 表单操作执行后事件
 /// </summary>
 /// <param name="e"></param>
 public override void AfterDoOperation(AfterDoOperationEventArgs e)
 {
 base.AfterDoOperation(e);
 // 新增：6，修改：5，删除：3，保存：8，提交：9，撤销：87，审核：1，反审核：26
if (e.Operation.OperationId == 1 && e.OperationResult.IsSuccess)
 {
var sql = string.Format("UPDATE T_SEC_USER SET FDESCRIPTION=N'哈哈哈' WHERE
FUSERID={0}", this.Context.UserId);
DBUtils.Execute(this.Context, sql);
 this.View.ShowMessage("审核操作执行成功，SQL已执行，SQL脚本：" + sql);
 }
 }
 }
}
```

[AfterDoOperation](https://vip.kingdee.com/article/194808387228614144)

### [审核成功后自动关闭当前窗体](https://vip.kingdee.com/article/175566954026221824)

#### 应用场景

单据审核成功后，自动关闭当前窗体

#### 案例演示

采购订单编辑界面，单据审核成功后，自动关闭当前窗体。

```python
import clr
clr.AddReference("mscorlib")
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
from System import *
from Kingdee.BOS.Core.Bill.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.Args import *
def AfterDoOperation(e):
 # 新增：6，修改：5，删除：3，保存：8，提交：9，撤销：87，审核：1，反审核：26
 if (e.Operation.OperationId == 1) and (e.OperationResult.IsSuccess):
 this.View.Close()
```

### [表单插件执行SQL](https://vip.kingdee.com/article/84693901407538432)

#### 应用场景

在表单插件事件中，执行SQL语句

#### 案例演示

采购订单，新增菜单【查询SQL】和【执行SQL】。

#### 实现步骤

```python
import clr
clr.AddReference('Kingdee.BOS.App')
from Kingdee.BOS.App.Data import *
def BarItemClick(e):
 if e.BarItemKey=="tbExecuteScalar":
 # 查询当前登录用户信息
    sql = "SELECT FNAME FROM T_SEC_USER WHERE FUSERID="+this.Context.UserId.ToString();
    userName = DBUtils.ExecuteScalar(this.Context,sql,None);
    this.View.ShowMessage(userName);
 elif e.BarItemKey=="tbExecute":
 # 修改当前登录用户的描述
    sql = "UPDATE T_SEC_USER SET FDESCRIPTION=N'哈哈哈' WHERE
    FUSERID="+this.Context.UserId.ToString();
    count = DBUtils.Execute(this.Context,sql);
    this.View.ShowMessage("更新成功，SQL："+sql+"，受影响行数："+count.ToString());
```

【知识点】

如果SQL语句不符合KSQL规范，在SQL语句的起始位置增加`/*dialect*/`申明。

例如：`sql = "/*dialect*/ SELECT FNAME FROM T_SEC_USER WHERE FUSERID=1"`

【答疑】

 保存Python插件时，会提示错误信息：“Could not add reference to assembly Kingdee.BOS.App”， 老有同学问，哎呀，报错了，会不会有问题呢？ 统一答复如下： 此错误提示可不必理会，因为我们只是在BOSIDE上进行Python插件的注册，而这段Python代码最终是在 服务端运行，BOSIDE属于客户端软件，BOSIDE所在目录下肯定不会包含服务端的组件，其提示缺少服务 端的组件是正常的，而在应用服务器上是包含了所有的组件的，所以等真正到了运行时，此Python插件不 会缺少任何平台组件，可以正常运行的

### [Python 表单插件 执行SQL](https://vip.kingdee.com/article/119856062978967040)

```python
#【Python】【表单插件】执行SQL
import clr
clr.AddReference("mscorlib")
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("Kingdee.BOS.App")
clr.AddReference("System.Data")
from Kingdee.BOS import *
from Kingdee.BOS.App.Data import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.Args import *
from Kingdee.BOS.Util import *
from System import *
from System.Collections.Generic import *
from System.Data import *

def BarItemClick(e):
	if (e.BarItemKey.Equals("tbExecuteStoreProcedure", StringComparison.OrdinalIgnoreCase)):
		# 执行存储过程
		procedureName = "P_Pur_Order"
		sqlParameterList = List[SqlParam]()
		sqlParameterList.Add(SqlParam("@P1", KDDbType.AnsiString, "CGDD"))
		p2= SqlParam("@P2", KDDbType.AnsiString, "", ParameterDirection.InputOutput)
		p2.Size = 200
		sqlParameterList.Add(p2)
		sqlParameterList.Add(SqlParam("@ReturnValue", KDDbType.Decimal, 0, ParameterDirection.ReturnValue))
		returnParameterList = DBUtils.ExecuteStoreProcedure(this.Context, procedureName, sqlParameterList)
		#msg = string.Join(";", returnParameterList.Select(o => o.Name + ":" + o.Value))
		msg = "返回结果：" + ";".join((o.Name + ":" + o.Value.ToString()) for o in returnParameterList)
		this.View.ShowMessage(msg)
		return
	if (e.BarItemKey.Equals("tbExecute", StringComparison.OrdinalIgnoreCase)):
		# 执行SQL并返回受影响行数
		sql = "UPDATE T_PUR_POORDER SET FCHANGEREASON=N'货物破损' WHERE FBILLNO=@BillNo"
		sqlParameterList = List[SqlParam]()
		sqlParameterList.Add(SqlParam("@BillNo", KDDbType.AnsiString, "CGDD000519"))
		returnValue = DBUtils.Execute(this.Context, sql, sqlParameterList)
		msg = "受影响行数：" + returnValue.ToString()
		this.View.ShowMessage(msg)
		return
	if (e.BarItemKey.Equals("tbExecuteDataSet", StringComparison.OrdinalIgnoreCase)):
		# 执行SQL并返回DataSet
		sql = "SELECT * FROM T_PUR_POORDER WHERE FBILLNO LIKE @BillNo"
		sqlParameterList = List[SqlParam]()
		sqlParameterList.Add(SqlParam("@BillNo", KDDbType.AnsiString, "%CGDD%"))
		ds = DBUtils.ExecuteDataSet(this.Context, sql, sqlParameterList)
		idList = List[String]()
		for row in ds.Tables[0].Rows:
		    idList.Add(row["FID"].ToString())
		msg = "满足条件的订单内码集合：" + ",".join(o for o in idList)
		this.View.ShowMessage(msg)
		return
	if (e.BarItemKey.Equals("tbExecuteReader", StringComparison.OrdinalIgnoreCase)):
		# 执行SQL并返回DataReader
		sql = "SELECT * FROM T_PUR_POORDER WHERE FBILLNO LIKE @BillNo"
		sqlParameterList = List[SqlParam]()
		sqlParameterList.Add(SqlParam("@BillNo", KDDbType.AnsiString, "%CGDD%"))
		reader = DBUtils.ExecuteReader(this.Context, sql, sqlParameterList)
		idList = List[String]()
		while reader.Read():
		    idList.Add(reader["FID"].ToString())
		reader.Close()
		msg = "满足条件的订单内码集合：" + ",".join(o for o in idList)
		this.View.ShowMessage(msg)
		return
	if (e.BarItemKey.Equals("tbExecuteScalar", StringComparison.OrdinalIgnoreCase)):
		# 执行SQL并返回首行首列的值
		sql = "SELECT COUNT(*) FROM T_PUR_POORDER WHERE FBILLNO LIKE @BillNo"
		sqlParam = SqlParam("@BillNo", KDDbType.AnsiString, "%CGDD%");
		orderCount = DBUtils.ExecuteScalar(this.Context, sql, 0, sqlParam)
		msg = "满足条件的订单数量：" + orderCount.ToString();
		this.View.ShowMessage(msg)
		return
```

### 跨表单反写

#### 应用场景

物料下达PR上限，超过上限保存错误提示，并且在关闭、反关闭已下达PR相应减少、增加PR数量。

#### 实现步骤

一、BOS打开采购申请单，注册表单Python插件，代码如下：

```python
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("Kingdee.BOS.App")
#【Python】【表单插件】执行SQL
clr.AddReference("mscorlib")
clr.AddReference("System.Data")
from Kingdee.BOS import *
from Kingdee.BOS.App.Data import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.Args import *
from Kingdee.BOS.Util import *
from Kingdee.BOS.Core.Metadata import *
from Kingdee.BOS.Core.Metadata.EntityElement import *
from Kingdee.BOS.Core.Validation import *
from Kingdee.BOS.Log import Logger
from System import *
#from System import DateTime
from System.Collections.Generic import *
from System.Data import *

def BeforeSave(e):
	rows=this.Model.GetEntryRowCount("FEntity");#获取单据体行数
	#proPertiesList=''
	for i in range(0, rows, 1):
		rqOrg = this.Model.GetValue("FREQUIREORGID",i)["Id"]
		rqMaterialId =  this.Model.GetValue("FMATERIALID",i)["Id"]
		approQty =  this.Model.GetValue("FBASEUNITQTY",i)
		#this.View.ShowMessage(str(rqMaterialId))
		#rqOrg = dyobjectOrg["FNumber"]
        # 获取属性列表
		#for q in dyobjectOrg.DynamicObjectType.Properties:
		#		proPertiesList = proPertiesList + ',' + str(q.Name);
				#this.View.ShowMessage(str((proPertiesList)))
		#		this.View.ShowMessage(str(dyobjectOrg["Id"]))
		#sqlM = ("""/*dialect*/SELECT F_ORA_PRCONTROL FROM T_BD_MATERIALBASE WHERE FUSEORGID={0}  AND FMATERIALID={1} """).format(rqOrg,rqMaterialId)
		#dsM = DBUtils.ExecuteDataSet(this.Context, sqlM)
		#this.View.ShowMessage(str(type(dsM.Tables[0].Rows)))
		#if dsM.Tables[0].Rows[0]["F_ORA_PRCONTROL"]:
		sql = ("""/*dialect*/SELECT a.FNUMBER, b.F_ORA_PRCONTROL, b.F_ORA_PRLIMITS, b.F_ORA_PRQTY FROM T_BD_MATERIAL a INNER JOIN T_BD_MATERIALPLAN b ON a.FMATERIALID=b.FMATERIALID  WHERE a.FUSEORGID={0}  AND a.FMATERIALID={1} """).format(rqOrg,rqMaterialId)
		ds = DBUtils.ExecuteDataSet(this.Context, sql)
		prMeNum =ds.Tables[0].Rows[0]["FNUMBER"]
		prControl = ds.Tables[0].Rows[0]["F_ORA_PRCONTROL"]
		prLimits = ds.Tables[0].Rows[0]["F_ORA_PRLIMITS"]
		prQty = ds.Tables[0].Rows[0]["F_ORA_PRQTY"]
		if prControl == '1':
			if (approQty + prQty > prLimits):
				this.View.ShowErrMessage("物料: " +str(prMeNum) +"采购上限是:" + str(prLimits)+"已下达PR数量:" + str(prQty)+",请检查PR数量")
				e.Cancel = True
		#nsql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET  F_ORA_PRQTY= {0}    WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(999,rqOrg,rqMaterialId)
		#DBUtils.Execute(this.Context, nsql)
		#this.View.ShowMessage(str(type(ds.Tables[0].Rows)))
		#this.View.ShowMessage(str(type(ds.Tables[0].Rows[0])))
		# 提取字段值
		# this.View.ShowMessage(str(prLimits) + '/' + str(prQty))
		
		#dataSet = DBUtils.Execute(this.Context,"/*dialect*/ update T_PRD_PPBOMENTRY_Q set F_MAXEYE_WLSL=FNOPICKEDQTY-FREPICKEDQTY+FPRCDEFECTRETURNQTY")
		#if this.Model.GetValue("FIssueType",i) != '7':
		#	a = this.Model.GetValue("FNoPickedQty",i) - this.Model.GetValue("FRePickedQty",i) + this.Model.GetValue("FProcessDefectReturnQty",i);
		#	this.Model.SetValue("F_maxeye_Wlsl",a,i);
		#	n = DBUtils.Execute(this.Context,"/*dialect*/ update T_PRD_PPBOMENTRY_Q set F_MAXEYE_WLSL=FNOPICKEDQTY-FREPICKEDQTY+FPRCDEFECTRETURNQTY")
		#	this.View.UpdateView("FA_DEPRADJUSTENTRY");
#保存后事件
#def AfterSave(e):
# 操作事件
def AfterDoOperation(e):
	# 新增：6，修改：5，删除：3，保存：8，提交：9，撤销：87，审核：1，反审核：26
   if (e.Operation.OperationId == 1) and (e.OperationResult.IsSuccess):
	rows=this.Model.GetEntryRowCount("FEntity");#获取单据体行数
	for i in range(0, rows, 1):
		rqOrg = this.Model.GetValue("FREQUIREORGID",i)["Id"]
		rqMaterialId =  this.Model.GetValue("FMATERIALID",i)["Id"]
		approQty =  this.Model.GetValue("FBASEUNITQTY",i)
		#this.View.ShowMessage(str(approQty))
		sql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET  F_ORA_PRQTY=F_ORA_PRQTY + {0}    WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(approQty,rqOrg,rqMaterialId)
		DBUtils.Execute(this.Context, sql)
   if (e.Operation.OperationId == 26) and (e.OperationResult.IsSuccess):
      rows=this.Model.GetEntryRowCount("FEntity");#获取单据体行数
      for i in range(0, rows, 1):
		rqOrg = this.Model.GetValue("FREQUIREORGID",i)["Id"]
		rqMaterialId =  this.Model.GetValue("FMATERIALID",i)["Id"]
		approQty =  this.Model.GetValue("FBASEUNITQTY",i)
		#this.View.ShowMessage(str(approQty))
		sql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET  F_ORA_PRQTY=F_ORA_PRQTY - {0}    WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(approQty,rqOrg,rqMaterialId)
		DBUtils.Execute(this.Context, sql)
def BarItemClick(e):
	#if (e.BarItemKey.Equals("tbBillClose", StringComparison.OrdinalIgnoreCase)):
	#tbBillUnClose
	if (e.BarItemKey.Equals("tbBillClose", StringComparison.OrdinalIgnoreCase)):
		rows=this.Model.GetEntryRowCount("FEntity");#获取单据体行数
      		for i in range(0, rows, 1):
			rqOrg = this.Model.GetValue("FREQUIREORGID",i)["Id"]
			rqMaterialId =  this.Model.GetValue("FMATERIALID",i)["Id"]
			approQty =  this.Model.GetValue("FBASEUNITQTY",i)
			#this.View.ShowMessage(str(approQty))
			sql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET F_ORA_PRQTY=F_ORA_PRQTY - {0}    WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(approQty,rqOrg,rqMaterialId)
			DBUtils.Execute(this.Context, sql)
	if (e.BarItemKey.Equals("tbBillUnClose", StringComparison.OrdinalIgnoreCase)):
		rows=this.Model.GetEntryRowCount("FEntity");#获取单据体行数
      		for i in range(0, rows, 1):
			rqOrg = this.Model.GetValue("FREQUIREORGID",i)["Id"]
			rqMaterialId =  this.Model.GetValue("FMATERIALID",i)["Id"]
			approQty =  this.Model.GetValue("FBASEUNITQTY",i)
			#this.View.ShowMessage(str(approQty))
			sql = ("""/*dialect*/SELECT a.FNUMBER, b.F_ORA_PRCONTROL, b.F_ORA_PRLIMITS, b.F_ORA_PRQTY FROM T_BD_MATERIAL a INNER JOIN T_BD_MATERIALPLAN b ON a.FMATERIALID=b.FMATERIALID  WHERE a.FUSEORGID={0}  AND a.FMATERIALID={1} """).format(rqOrg,rqMaterialId)
			ds = DBUtils.ExecuteDataSet(this.Context, sql)
			prMeNum =ds.Tables[0].Rows[0]["FNUMBER"]
			prControl = ds.Tables[0].Rows[0]["F_ORA_PRCONTROL"]
			prLimits = ds.Tables[0].Rows[0]["F_ORA_PRLIMITS"]
			prQty = ds.Tables[0].Rows[0]["F_ORA_PRQTY"]
			if prControl == '1':
				if (approQty + prQty > prLimits):
					#this.View.ShowErrMessage("物料: " +str(prMeNum) +"采购上限是:" + str(prLimits)+"已下达PR数量:" + str(prQty)+",请检查PR数量")
					#e.Cancel = True					
					raise Exception("物料: " +str(prMeNum) +"采购上限是:" + str(prLimits)+"已下达PR数量:" + str(prQty)+",请检查PR数量")
			addsql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET F_ORA_PRQTY = F_ORA_PRQTY + {0}  WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(approQty,rqOrg,rqMaterialId)
			DBUtils.Execute(this.Context, addsql)			
```

### 下拉列表根据场景增减枚举值

#### 应用场景

生产订单加工类型有多种时，根据生产订单的单据类型（组织委托加工/返工），选择各单据类型下特有加工类型。

单据类型切换后绑定数据。因为单据类型切换会使得整个页面刷新重建，因为抓取单据类型变更事件不能 使用DataChanged事件，可以使用AfterBindData事件。具体可参考：[二开案例.表单插件.单据类型切换后绑定数据](https://vip.kingdee.com/article/236811714744663808?productLineId=1)

[实施过程中动态控制枚举项加载的方法](https://vip.kingdee.com/article/2849?productLineId=1)

[二开案例.单据插件.设置单据类型可选项](https://vip.kingdee.com/article/203929343053833472?productLineId=1)

#### 实现步骤

BOS打开生产订单注册表单插件，代码如下：

```python
import clr
clr.AddReference("Kingdee.Bos")
from Kingdee.BOS import LocaleValue
from Kingdee.BOS.Core.Metadata import EnumItem
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import ComboFieldEditor
from System.Collections.Generic import *
from System import DateTime

def OnLoad(e):
    if DateTime.Today.Year <= 2202:
        #billTypeField = this.Model.BusinessInfo.GetBillTypeField()
        #billTypeField = this.Model.GetValue("FBillType")
        proPertiesList = ''
        billTypeField = this.View.Model.GetValue("FBillType")
        if billTypeField is not  None:
              for q in billTypeField.DynamicObjectType.Properties:
                    proPertiesList = proPertiesList + ',' + str(q.Name);
          #this.View.ShowMessage(str((proPertiesList)))
            #this.View.ShowMessage(billTypeField["Name"].ToString())
        #this.View.ShowMessage(str(type(billTypeField.["Name"].ToString())))
        
        # ,Id,MultiLanguageText,Name,Number 
        #this.View.ShowMessage(billTypeField["Number"].ToString())
        billTypeNumber = billTypeField["Number"].ToString()
        
        comboField = this.View.BusinessInfo.GetField("F_ora_Combo")
        enumObject = comboField.EnumObject
        
        itemList = enumObject["Items"]
        
        newList = List[EnumItem]()
       
        hasSpaceItem = 0
        isMustInput = bool(comboField.IsMustInput())
        if not isMustInput:
            spaceItem = EnumItem()
            spaceItem.Seq = hasSpaceItem
            spaceItem.Value = ""
            spaceItem.Caption = LocaleValue("", this.View.Context.UserLocale.LCID)
            newList.Add(spaceItem)
            hasSpaceItem += 1
        for item in itemList:
            if billTypeNumber == "SCDD07_SYS":
                if str(item["Value"]) == '2' or str(item["Value"]) == '3':
                    continue
                else:
                    newItem = EnumItem()
                    newItem.Seq = int(item["Seq"]) + hasSpaceItem
                    newItem.Value = str(item["Value"])
                    newItem.Caption = item["Caption"]
                    newList.Add(newItem)
            if billTypeNumber == "SCDD02_SYS":
                if str(item["Value"]) == '1' or str(item["Value"]) == '4' or str(item["Value"]) == '5':
                    continue
                else:
                    newItem = EnumItem()
                    newItem.Seq = int(item["Seq"]) + hasSpaceItem
                    newItem.Value = str(item["Value"])
                    newItem.Caption = item["Caption"]
                    newList.Add(newItem)
        # 获取fieldEditor来设置下拉的选项列表
        fieldEditor = this.View.GetControl("F_ora_Combo")
        fieldEditor.SetComboItems(newList)
 
def BeforeSave(e):
    if DateTime.Today.Year <= 2202:
        processingChargeType = this.Model.GetValue("F_ora_Combo")
        #this.View.ShowMessage(str(processingChargeType))
        #this.View.ShowMessage("|" +str(processingChargeType) + "|")
        if processingChargeType.strip() ==  '':
        #this.View.ShowMessage(str(type(processingChargeType)))
        #	this.View.ShowMessage("|" +str(processingChargeType) + "|")
        #else:
            raise Exception("加工类型必填，不能为空！")
            e.Cancel = True
#def DataChanged(e):
#	billTypeField = this.Model.BusinessInfo.GetBillTypeField()
 #	if billTypeField == None:
 #		return
 #	if (e.Field.Key == billTypeField.Key):
 ##		billTypeObjs = this.Model.GetValue(billTypeField.Key)
 #		if (billTypeObjs is not None):
 #			this.View.OpenParameter.SetCustomParameter("jac_defalutBillTypeId",billTypeObjs[0].ToString())
```
### 列表显示过滤行


```python
#引入clr运行库
import clr
import sys
# 导入clr时这个模块最好也一起导入，这样就可以用AddReference方法
import System
clr.AddReference('System')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.DataEntity')
#添加对cloud插件开发的常用组件的引用
from System import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.Args import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from Kingdee.BOS.Core.List import *
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Core.List.PlugIn.Args import *
from Kingdee.BOS.Core.Report import *
from Kingdee.BOS.Core.Report.PlugIn import *
from Kingdee.BOS.Util import *
from Kingdee.BOS.Util import *
from Kingdee.BOS.Core.SqlBuilder import *
from Kingdee.BOS.Orm.DataEntity import *

def PreOpenForm(e):
	e.OpenParameter.SetCustomParameter("showFilterRow", "True");
```

### 列表提交校验

#### 应用场景

当表单插件校验生效，列表插件不生效的情况下，需要在”保存“和”提交“操作列表注册服务插件。

### Reference

[Python添加生产订单批改字段校验](https://vip.kingdee.com/article/289754414091464448?productLineId=1)

[Python继承AbstractValidator实现校验器案例](https://vip.kingdee.com/article/270943780554196480?productLineId=1)

[python日期字段范围校验](https://vip.kingdee.com/article/266283188564255488?productLineId=1)

[Python保存添加校验器](https://vip.kingdee.com/article/264491804915899392?productLineId=1)

[Python插件实现直接保存二开字段(忽略标准保存校验)](https://vip.kingdee.com/article/207528508652713728?productLineId=1)

[二开案例.列表插件.执行操作的校验器](https://vip.kingdee.com/article/239320890406941952?productLineId=1)

[二开案例.列表插件.调用表单操作](https://vip.kingdee.com/article/104242911042083584?productLineId=1)

[二开案例.列表插件.列表调用保存操作](https://vip.kingdee.com/article/139314926954577664?productLineId=1)

 [Python保存添加校验器](https://vip.kingdee.com/article/266197335942436096?productLineId=1)

[二开案例.单据插件.执行操作的校验器](https://vip.kingdee.com/article/238316028416101376?productLineId=1)

[二开案例.服务插件.保存操作强制校验](https://vip.kingdee.com/article/288758032665223424?productLineId=1)

[二开案例.服务插件.校验器使用内置交互界面显示自定义数据源](https://vip.kingdee.com/article/130349586652598272?productLineId=1)

[操作服务插件，校验器，OnAddValidators，单据头，必录](https://vip.kingdee.com/article/69949660194215936?productLineId=1)

[操作服务插件，校验器，OnAddValidators，单据体，是否允许审核](https://vip.kingdee.com/article/70073980974954496?productLineId=1)

[操作服务插件，校验OnAddValidators，OnPreparePropertys加载](https://vip.kingdee.com/article/69937467385663232?productLineId=1)

#### 实现步骤

BOS操作列表，“提交”-->“其他控制”-->“服务插件”

```python
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("Kingdee.BOS.App")
#【Python】【表单插件】执行SQL
clr.AddReference("mscorlib")
clr.AddReference("System.Data")
from Kingdee.BOS import *
from Kingdee.BOS.App.Data import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.Args import *
from Kingdee.BOS.Util import *
from Kingdee.BOS.Core.Metadata import *
from Kingdee.BOS.Core.Metadata.EntityElement import *
from Kingdee.BOS.Core.Validation import *
from Kingdee.BOS.Log import Logger
from System import *
#from System import DateTime
from System.Collections.Generic import *
from System.Data import *


def OnPreparePropertys(e):
	e.FieldKeys.Add("FBaseReqQty")
	e.FieldKeys.Add("FREQUIREORGID")
	e.FieldKeys.Add("FMaterialId")
def OnAddValidators(e):
	validateBillDate=ValidateBillDate() 
	validateBillDate.EntityKey="FBillHead"
	validateBillDate.EntityKey="FEntity"
	validateBillDate.AlwaysValidate=True
	e.Validators.Add(validateBillDate)
class ValidateBillDate(AbstractValidator):
	def Validate(self,dataEntities,validateContext,ctx):
		for bill in dataEntities:
			#atreeEntity=bill["ReqEntry"]
			#treeEntity=bill["Entity"]
			approQty = bill.DataEntity["BaseReqQty"];
			#billdate=bill.DataEntity["Date"]
			#minDate=DateTime.Now.AddDays(-30)
			#maxDate=DateTime.Now.AddDays(+30)
			#for item in atreeEntity:
			  
			  #for row in item:	
			  # for p in item.DynamicObjectType.Properties:
				#proQty = item["aApproveQty"]				
			#if(101  > 100 ):
			rqOrg = bill.DataEntity["RequireOrgId"]["Id"]
			#rqOrgId = rqOrg["Id"]
			#rqMaterialId =  this.Model.GetValue("FMATERIALID",i)["Id"]
			rqMaterialId = bill.DataEntity["MaterialId"]["Id"]
			#approQty =  this.Model.GetValue("FBASEUNITQTY",i)
			#this.View.ShowMessage(str(approQty))
			sql = ("""/*dialect*/SELECT a.FNUMBER, b.F_ORA_PRCONTROL, b.F_ORA_PRLIMITS, b.F_ORA_PRQTY FROM T_BD_MATERIAL a INNER JOIN T_BD_MATERIALPLAN b ON a.FMATERIALID=b.FMATERIALID  WHERE a.FUSEORGID={0}  AND a.FMATERIALID={1} """).format(rqOrg,rqMaterialId)
			ds = DBUtils.ExecuteDataSet(this.Context, sql)
			prMeNum =ds.Tables[0].Rows[0]["FNUMBER"]
			prControl = ds.Tables[0].Rows[0]["F_ORA_PRCONTROL"]
			prLimits = ds.Tables[0].Rows[0]["F_ORA_PRLIMITS"]
			prQty = ds.Tables[0].Rows[0]["F_ORA_PRQTY"]
			
			billId=str(bill["Id"])
			#errorInf = str(treeEntity)
			if prControl == '1':
				if (approQty + prQty > prLimits):
					#this.View.ShowErrMessage("物料: " +str(prMeNum) +"采购上限是:" + str(prLimits)+"已下达PR数量:" + str(prQty)+",请检查PR数量")
					#e.Cancel = True					
			#		raise Exception("物料: " +str(prMeNum) +"采购上限是:" + str(prLimits)+"已下达PR数量:" + str(prQty)+",请检查PR数量")
					# 出错的字段key，可以为空/
					# 出错的字段key，可以为空/
					# 出错的数据包在全部数据包中的顺序/
					# 出错的数据行在全部数据行中的顺序，如果校验基于单据头，此为0/
					# 错误编码，可以任意设定一个字符，主要用于追查错误来源
					# 错误的详细提示信息
					# 错误的简明提示信息
					# 错误级别：警告、错误...
					errorInfo=ValidationErrorInfo("",billId,bill.DataEntityIndex,bill.RowIndex,billId, "物料: " +str(prMeNum) +"采购上限是:" + str(prLimits)+"已下达PR数量:" + str(prQty)+",请检查PR数量","",ErrorLevel.Error)
					validateContext.AddError(None,errorInfo)
				else:
					addsql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET F_ORA_PRQTY = F_ORA_PRQTY + {0}  WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(approQty,rqOrg,rqMaterialId)
					DBUtils.Execute(this.Context, addsql)				
			else:
				addsql = ("""/*dialect*/UPDATE T_BD_MATERIALPLAN SET F_ORA_PRQTY = F_ORA_PRQTY + {0}  WHERE FUSEORGID={1}  AND FMATERIALID={2} """).format(approQty,rqOrg,rqMaterialId)
				DBUtils.Execute(this.Context, addsql)				
```

