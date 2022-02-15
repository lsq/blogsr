---
title: "Python列表插件查询行内码(保存提交审核操作)"
date: Tue, 15 Feb 2022 15:36:04 +0800
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
## Python列表插件查询行内码

### 应用场景

功能实现需要插件干预，不方便部署C#插件，且业务逻辑较为简单的业务场景。
### 案例演示---实现步骤

```python
import clr
clr.AddReference("System")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("mscorlib")
clr.AddReference("Kingdee.BOS")
clr.AddReference("Kingdee.BOS.Core")
clr.AddReference("Kingdee.BOS.ServiceHelper")
clr.AddReference('Kingdee.BOS.App')
from Kingdee.BOS.Core.List.PlugIn.Args import *
from Kingdee.BOS.Core.Metadata import *
from System import *
from Kingdee.BOS.ServiceHelper import *
from Kingdee.BOS.App.Data import *
def BarItemClick(e):
	if e.BarItemKey == 'tbGetListSelectedRows':
		fentryid = ''
		fid=''
		a = this.ListView.SelectedRowsInfo
		for i in range(len(a)):
			# 单据体内码
			fentryid = fentryid + ',' + str(a[i].EntryPrimaryKeyValue)
			#单据头内码
			#fid = fentryid + ',' + str(a[i].PrimaryKeyValue)
			fid = fid + ',' + str(a[i].PrimaryKeyValue)
			#formMetadata = 	BusinessDataServiceHelper.loadSingle(fentryid)
		this.View.ShowMessage(str(fentryid)+"/"+str(fid))
```

### 列表更新字段值

#### 应用场景

[物料列表反审核按钮清空物料基础资料中的复选框字段值【python插件】](https://vip.kingdee.com/article/217593193079030528)

#### 实现步骤

```python
#物料列表反审核插件【反审核成功更新物料页签中的复选框字段】
from clr import AddReference
AddReference("Kingdee.BOS.App")
from Kingdee.BOS.App.Data import DBUtils
#按钮点击事件
def BarItemClick(e):
	if e.BarItemKey == "tbReject":
		Data = this.Model.GetData(this.View.SelectedRowsInfo)
		num = 0 
		for i in Data:
			sql = "update T_BD_MATERIAL set 【复选框类型字段名】= 0 where FMATERIALID = {0}".format(str(i['FMATERIALID']))
			returnData = DBUtils.Execute(this.Context,sql)
			num += 1
		this.View.ShowMessage("有%s行数据受影响"%num)
```

### 拆分表查询分录ID

#### 应用场景

生产物料清单需要查询指定行分录ID

#### 实现代码

```python
import clr
clr.AddReference('Kingdee.BOS.App')
from Kingdee.BOS.App.Data import *
def BarItemClick(e):
 if e.BarItemKey=="tbHello":
 # 查询当前登录用户信息
    sql = "SELECT FSEQ FROM  T_PRD_PPBOMENTRY WHERE  FREPLACEGROUP=25 and FMOBILLNO='MO20220119001' and FMOENTRYSEQ=1";
    seq = DBUtils.ExecuteScalar(this.Context,sql,None);
    sqln = "SELECT FID FROM  T_PRD_PPBOMENTRY WHERE  FREPLACEGROUP=25 and FMOBILLNO='MO20220119001' and FMOENTRYSEQ=1";
    fid = DBUtils.ExecuteScalar(this.Context,sqln,None);
    sqlm = "SELECT FENTRYID FROM  T_PRD_PPBOMENTRY WHERE  FREPLACEGROUP=25 and FMOBILLNO='MO20220119001' and FMOENTRYSEQ=1";
    entryid = DBUtils.ExecuteScalar(this.Context,sqlm,None);
    sqlq = "SELECT FISSUETYPE  FROM  T_PRD_PPBOMENTRY_C WHERE FENTRYID =  " + entryid.ToString();
    issuetype = DBUtils.ExecuteScalar(this.Context,sqlq,None);
    sqlp = "SELECT FNOPICKEDQTY FROM T_PRD_PPBOMENTRY_Q WHERE FENTRYID=" + entryid.ToString();
    nopickedqty = DBUtils.ExecuteScalar(this.Context,sqlp,None);
    this.View.ShowMessage(seq.ToString() +"/" + fid.ToString()+"/" + entryid.ToString() +"/" + issuetype.ToString() +"/" + nopickedqty.ToString());
 
```

### [Python脚本实现保存自动提交审核](https://vip.kingdee.com/article/157179291166940672)

#### 代码实现一

```python
#参考代码如下：
##****************************保存服务插件*******************
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Bill import *
#from Kingdee.BOS.Orm import *
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
def OnPreparePropertys(e):	    
    e.FieldKeys.Add("F_IsAutoAudit");#复选框字段标识
def EndOperationTransaction(e):	    
    idList =List[object]();	    
    for billObj in e.DataEntitys:		        
        BillId = str(billObj["Id"]);		        
        F_IsAutoAudit = str(billObj["F_IsAutoAudit"]);		        
        if (F_IsAutoAudit == "1" or F_IsAutoAudit == "True"):			            
            idList.Add(BillId);	    
    if(idList.Count <= 0):		        
        return;	    
    pkArray = idList.ToArray();    
    formID=this.BusinessInfo.GetForm().Id;    
    meta = MetaDataServiceHelper.Load(this.Context, formID);	    
    submitOption = None;	    
    subResult = BusinessDataServiceHelper.Submit(this.Context,meta.BusinessInfo,pkArray,"Submit",submitOption);	    
    if (subResult.IsSuccess == True):		        
        auditOption = None;		        
        auditResult = BusinessDataServiceHelper.Audit(this.Context,meta.BusinessInfo,pkArray,auditOption);

```
代码参考二
```python
#参考代码:
##****************************保存服务插件*******************
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.DataEntity')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Contracts import *
from Kingdee.BOS.Orm.DataEntity import *
from Kingdee.BOS.DataEntity import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *#参考代码:
##****************************保存服务插件*******************
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.DataEntity')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Contracts import *
from Kingdee.BOS.Orm.DataEntity import *
from Kingdee.BOS.DataEntity import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *

def BarItemClick(e):
	if e.BarItemKey == 'tb_list':
    	pkIds = List[object]();
    	debugStr=''
    	selectedRowsInfo = this.ListView.SelectedRowsInfo;
		datas = this.ListModel.GetData(selectedRowsInfo);
		if (datas.Count <= 0):
			return;
		listEntryId=List[str]();
		for row in selectedRowsInfo:
			selectEntryId=str(row.EntryPrimaryKeyValue);
			selectPkId=str(row.PrimaryKeyValue)
			entityKey=str(row.EntryEntityKey);
			if(selectEntryId=="" or selectEntryId==None or entityKey<>"FEntity"):#判断是否显示了需要查询的单据体
				this.View.ShowWarnningMessage("请在过滤里面显示单据体[FEntity]!");
				return;
			#listEntryId.Add(selectEntryId + '/' + entityKey);
			listEntryId.Add(selectEntryId);
			pkIds.Add(selectPkId)
		rowIndexs = str.Join(",", listEntryId.ToArray());# 选 中 行 的 单 据 体 明 细 Id 集 合 字 符 串 ( 格 式为:1001,1002,1003,...)
		#this.View.ShowMessage(str((rowIndexs)))
		billObjects=BusinessDataServiceHelper.Load(this.Context, pkIds.ToArray(), this.View.BillBusinessInfo.GetDynamicObjectType());
		for billObj in billObjects:
			for entryObj in billObj["ReqEntry"]:
				#this.View.ShowMessage(str(entryObj["Id"]))
				if str(entryObj["Id"]) in listEntryId:
					entryObj["ReqQty"] = 1000
					debugStr = str(entryObj["Id"]) + '/' + str(entryObj["ReqQty"])
		this.View.ShowMessage(str((debugStr)))
		saveRslt = BusinessDataServiceHelper.Save(this.Context, this.View.BillBusinessInfo, billObjects, None, "Save")
    		#for billObj in e.DataEntitys:
        	#	billId=billObj["Id"];
        	#	pkIds.Add(billId);
    		#formID=this.BusinessInfo.GetForm().Id;
    		#meta = MetaDataServiceHelper.Load(this.Context, formID);
    		#billObjects=BusinessDataServiceHelper.Load(this.Context, pkIds.ToArray(), meta.BusinessInfo.GetDynamicObjectType());
    		#saveRslt=BusinessDataServiceHelper.Save(this.Context, meta.BusinessInfo,billObjects , None,"Save");
    	if (saveRslt.IsSuccess == False):
        	ss=saveRslt.ValidationErrors[0].Message;
        	raise Exception(("保存出错:{0}").format(ss))
```
代码参考三

如果你是load出的单据数据包，应该是一个集合，也就是你代码里面的billObjects 。 如果要通过数据包获取单据里面的字段信息或者单据体的话，用实体标识就可以了。 你可以把单据数据包理解成一个类似于 JSON对象的结构，一层一层解析而已。 具体数据模型参考https://vip.kingdee.com/article/35736及https://vip.kingdee.com/article/45021帖子内容

获取单据头字段：
```python
 billObj=billObjects[0];
 billNo=billObj["字段实体属性标识"]; 
```
获取单据体 ： 
```python
entity=billObj["单据体ORM实体标识"]; 
```
循环获取单据体里面的每一行： 
```python
for r in entity: 
fld1=r["单据体字段实体属性标识"]; 
```
同样的，和JSON类似，也可以修改数据包里面的数据, 修改完之后调用```BusinessDataServiceHelper.Save```方法就可以了： 
```python
billObj["字段实体属性标识"]="XXX"; 
```
修改单据体字段： 
```python
for r in entity: 
r["单据体字段实体属性标识"]="XXX";
```
```python
#参考代码:
##****************************保存服务插件*******************
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.DataEntity')
clr.AddReference('Kingdee.BOS.Contracts')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Contracts import *
from Kingdee.BOS.Orm.DataEntity import *
from Kingdee.BOS.DataEntity import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *

#作者：Jack
#来源：金蝶云社区
#原文链接：https://vip.kingdee.com/article/139314926954577664
#著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
def BarItemClick(e):
	if e.BarItemKey == 'tb_list':
         pkIds = List[object]()
		#fentryid = ''
		fids=''
		proPertiesList=''
		if (this.ListView.SelectedRowsInfo == None or this.ListView.SelectedRowsInfo.Count == 0):
           		 this.View.ShowMessage("没有选择任何数据，请先选择！")
           		 return
		a = this.ListView.SelectedRowsInfo #获取选中行
		#this.View.ShowMessage(str(type(a)))
		for i in range(len(a)):
			# 单据体内码
			#fentryid = fentryid + ',' + str(a[i].EntryPrimaryKeyValue)
			#单据头内码
			#fid = fentryid + ',' + str(a[i].PrimaryKeyValue)
			#fid =  str(a[i].PrimaryKeyValue)
			#formMetadata = 	MetaDataServiceHelper.Load(this.Context,
			#BusinessDataServiceHelper.loadSingle(fentryid)
			fid = a[i].PrimaryKeyValue
			fids = fids + '/' + str(fid)
			pkIds.Add(fid)
		#this.View.ShowMessage(fids) # 调试
		# 二开案例.列表插件.列表调用保存操作
        # https://vip.kingdee.com/article/139314926954577664
        # https://vip.kingdee.com/article/238671226909305344
        # foreach (var dataObject in dataObjects)
            #{
                #// 修改采购订单的变更原因
                #dataObject["ChangeReason"] = "666";
            #}
         formID=this.View.BillBusinessInfo.GetForm().Id;
		meta = MetaDataServiceHelper.Load(this.Context, formID);
		billObjects=BusinessDataServiceHelper.Load(this.Context, pkIds.ToArray(), meta.BusinessInfo.GetDynamicObjectType());
		#saveRslt=BusinessDataServiceHelper.Save(this.Context, meta.BusinessInfo,billObjects , None,"Save");
		#formId = this.BusinessInfo.GetForm().Id
		#meta = MetaDataServiceHelper.Load(this.Context, formId);
		# 下面也生效
		#billObjects = BusinessDataServiceHelper.Load(this.Context, pkIds.ToArray(),this.View.BillBusinessInfo.GetDynamicObjectType())
		#this.View.ShowMessage(str(type(billObjects)))
		
		billNo =''
		#for j in billObjects:
			#purQeqEntryDatas = j.GetValue(CONST_PUR_REQUISITION.CONST_FEntity.ENTITY_ORM_ReqEntry)
			#purBiz = j.BusinessInfo()
			#entity = purBiz.GetEntity("FEntity")
			#entityData = entity
			#this.View.ShowMessage(str(type(entity)))
			#for entryData  in purQeqEntryDatas:
			#	billNo = billNo + ',' + str(entryData.GetDynamicValue(CONST_PUR_REQUISITION.CONST_FEntity.ORM_ReqQty))
				
		for j in billObjects:
		#	#this.View.ShowMessage(str(type(j)))
			for q in j.DynamicObjectType.Properties:
				proPertiesList = proPertiesList + ',' + str(q.Name);
				#if (str(q.Name) == 'BillNo'):
				if (str(q.Name) == 'ReqEntry'):
					#billNo = str(type(j.ReqEntry))
					for purData in j.ReqEntry:
						billNo = billNo + '/' +str(type(purData))
						#purData[]
						# https://vip.kingdee.com/article/35736?islogin=true
						#https://vip.kingdee.com/article/45021
						for proList in purData.DynamicObjectType.Properties:
							#billNo = billNo +','+  str(proList.Name)
							if (str(proList.Name) == 'Id'):
								purData["ReqQty"] = 1000
								billNo = billNo + ',' + proList.GetValue(purData).ToString() + ';' + purData["ReqQty"].ToString()
			#BusinessDataServiceHelper.Save(this.Context, this.View.BillBusinessInfo, j)
		#	j["ReqQty"] = 666
			#for q in
		# https://vip.kingdee.com/article/33705			
		this.View.ShowMessage(str((billNo)))
		#this.View.ShowMessage(str((proPertiesList)))
		#https://vip.kingdee.com/article/158234477305916928
		#saveRslt = BusinessDataServiceHelper.Save(this.Context, this.View.BillBusinessInfo, billObjects, None, "Save")
		#saveRslt = BusinessDataServiceHelper.Save(this.Context, this.View.BillBusinessInfo, billObjects, None, "Save")
		saveRslt=BusinessDataServiceHelper.Save(this.Context, meta.BusinessInfo,billObjects , None,"Save");
		#raise Exception("问题出问题了，请打开单据检查单据字段")
		if (saveRslt == True):
          		this.View.ShowMessage("保存成功！")
         else:
           		this.View.ShowMessage("出错，保存不成功！")
```

### 参考

[Python实现列表对暂存的单据批量保存](https://vip.kingdee.com/article/158234477305916928)

[二开案例.列表插件.列表调用保存操作](https://vip.kingdee.com/article/139314926954577664)

[二开案例.Python插件.抛异常](https://vip.kingdee.com/article/84697663127624960)

[二开案例.Python插件.表单插件执行SQL](https://vip.kingdee.com/article/84693901407538432)

[二开案例.表单插件.执行SQL](https://vip.kingdee.com/article/119856062978967040)

[表单插件，获取单据体FENTRYID内码，GetEntryPKValue](https://vip.kingdee.com/article/65753630238150656)

[列表插件，获取单据体分录，FID内码](https://vip.kingdee.com/article/67375800848337920)





