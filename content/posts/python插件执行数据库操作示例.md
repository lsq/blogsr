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
