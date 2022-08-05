---
title: "单据列表插件示例"
date: Fri, 05 Aug 2022 09:27:57 +0800
#description: "vba导出pdf或者png"
author: CQ周玉立
avatar: /me/pk.jpg
cover: /images/pexels-jhovani-morales-12320052.jpg
images:
  - /images/pexels-jhovani-morales-12320052.jpg
draft: false
tags: ["金蝶云星空", "BOS", "Python"]
categories: ["BOS"]
---
## **往期回顾：**

**【Python插件入门】第1篇：****[Python插件入门讲解](https://vip.kingdee.com/article/330000931540780032?productLineId=1)**

**【Python插件入门】第2篇：****[基本开发过程介绍](https://vip.kingdee.com/article/332534862269551872?productLineId=1)**

**【Python插件入门】第3篇：****[插件中如何进行数据操作](https://vip.kingdee.com/article/335071759478985984?productLineId=1)**

**【Python插件入门】第4篇：**[***\*单据表单插件\****](https://vip.kingdee.com/article/338117169206442496?productLineId=1)



  前面讲了单据表单插件，相信大家对插件事件有了一定的掌握，今天讲一下单据列表插件。

## 一、列表插件简介

  上一篇讲表单插件时，提到单据列表是不会触发表单插件的，于是我们需要用列表插件来处理列表相关的一些功能。

  列表插件也是Web服务层插件，**需要依赖于单据列表界面(ListView)才能触发**，可应用于单据列表、基础资料列表中。

  在C#插件开发时，列表插件的基类是AbstractListPlugIn，列表插件和表单插件都是界面类的插件，他们都需要依赖于界面触发，他们有一个共同的父类AbstractDynamicFormPlugIn，所以有些表单插件的用法在列表插件中也同样可以用。

## 二、列表插件重要成员介绍

  列表插件中同样有this.Context，这个在上一篇表单插件中介绍了，用法类似，不再过多介绍，这里主要介绍一下列表插件特殊的一些成员属性。

- **ListView :列表视图层对象,**列表插件除了View之外，还有ListView,通过ListView可以提供一些列表特有的功能。

```python
  this.ListView.BillBusinessInfo.GetForm().Id;#当前列表对应的单据标识
  this.ListView .OpenParameter;#列表入口参数
  this.ListView.OpenParameter.HideListMenu = True;#隐藏列表菜单
  this.ListView.OpenParameter.IsShowFilter = True;#打开列表自动弹出过滤框,默认为False
  this.ListView.OpenParameter.IsShowQuickFilter=False;#是否显示快捷过滤
  this.ListView.OpenParameter.FilterSchemeId;#当前过滤方案ID

  this.ListView.OpenParameter.IsTrackBillList();#是否上下查列表

  #获取自定义参数，可获取发布主控台的参数，例如,将不同单据类型发布成不同列表

  this.ListView.OpenParameter.GetCustomParameter("参数标识");
  this.ListView.SelectedRowsInfo;#当前列表上被选中的行记录，复选框勾选的记录集合
  this.ListView.CurrentSelectedRowInfo;#当前列表上当前选择行数据，即焦点行
  this.ListView.CurrentPageRowsInfo;#当前列表页所有单据的行信息

  #******************************************************************************************
  grid=this.View.GetControl[EntryGrid]("FList");#获取列表表格控件对象
  selectedRowIndexs=List[int]();
  selectedRowIndexs.Add(1);
  selectedRowIndexs.Add(3);
  grid.SelectRows(selectedRowIndexs.ToArray());
  grid.SetRowHeight(80);#设置行高
```
- **ListModel :列表数据模型，**从这里可以获取列表的数据
```python
  this.ListModel;#获取列表数据模型
  selectedRowsInfo = this.ListView.SelectedRowsInfo;
  this.ListModel.GetData(selectedRowsInfo);#获取选中的数据
  selectedRowsInfo.GetPrimaryKeyValues();#获取选中行所有单据ID，字符串数组
  selectedRowsInfo.GetEntryPrimaryKeyValues();#获取所有选中行所有明细ID,字符串数组
  this.ListModel.FieldKeyMap;#列表上显示的字段,其字段名 FieldName 和字段标识Key的对应关系
  this.ListModel.FilterParameter;#列表过滤参数对象
  this.ListModel.FilterParameter.CustomFilter;#列表过滤框实体数据包
  this.ListModel.FilterParameter.FilterRows;#列表条件过滤行数据
  this.ListModel.FilterParameter.FilterString;#列表条件过滤数据系统自动转换出的条件表达式
  this.ListModel.GlobalParameter;#单据参数配置中配置的单据全局参数
  this.ListModel.ParameterData;#用户参数实体数据包,选项菜单界面的配置数据
  this.ListModel.Header;#列表表头对象
  this.ListModel.Header.GetChilds();#列表所有的列头集合
  this.ListModel.Limit;#当前列表每页行数
  this.ListModel.StartRow;#开始行索引，从0开始
  this.ListModel.Refresh();#刷新列表
  this.ListModel.RefreshByFilter();#根据过滤条件，重新取数，刷新列表
```

## **三、新建一个列表插件**

- **注意：这里提供一个引用比较全的Python列表插件示例模板，在附件中下载示例代码，复制到BOS里面注册！**
- **Python列表插件注册方法：**如下图所示，以采购订单为例，其他单据类似

## 四、列表插件常用事件介绍

  Python插件中如何使用事件，看[第4篇](https://vip.kingdee.com/article/338117169206442496?productLineId=1)中的介绍。

- ***\*列表插件中的常用事件用法介绍：\*****下面介绍一些列表插件中的常用事件*

\#列表插件过滤事件,加载列表时会触发
\#用法1:对列表过条件进行干预,此用法最广
\#用法2:修改快捷过滤和过滤框的条件过滤,案例:[动态构建下拉列表-年份](https://vip.kingdee.com/article/301688378930570752?productLineId=1)

```python
def PrepareFilterParameter(e):
  custfilterObj=e.CustomFilter;#过滤框实体数据包
  filterStr=e.FilterString;#过滤框条件过滤表达式
  sortStr=e.SortString#排序字段表达式
  statusFilterStr=e.StatusFilterString;#状态字段过滤表达式
  #msg=("{0}").format(statusFilterStr);
  #this.View.ShowMessage(msg);
  myFilterStr=("FBillNo like '%{0}%' ").format("1");#单据编号包含1
  e.AppendQueryFilter(myFilterStr);#追加过滤条件

#列表菜单点击事件,列表菜单点击开始时触发
#此事件也是很常用的,可以在此事件中取消菜单的点击事件
#使用时一定要判断菜单标识!!!
def BarItemClick(e):
  key=e.BarItemKey.ToUpperInvariant();
  if(key=="TestBtn".ToUpperInvariant()):
    #e.Cancel=True;#取消菜单的点击，可以阻止后续功能的触发,可完成一些简单校验
    #msg=("菜单[{0}]点击被取消啦！").format(key);
    #this.View.ShowMessage(msg);
    return;

#列表菜单点击后事件,列表菜单点击完成后触发
#使用时一定要判断菜单标识!!!
#自定义菜单功能实现建议在此事件中完成
#应用案例:[列表插件实现单据批改](https://vip.kingdee.com/article/157162374296835584?productLineId=1)
def AfterBarItemClick(e):
  key=e.BarItemKey.ToUpperInvariant();
  if(key<>"TestBtn".ToUpperInvariant()):
    return;
  msg=("菜单[{0}]点击完成啦！").format(key);
  #this.View.ShowMessage(msg);
  selectedRowsInfo=this.ListView.SelectedRowsInfo;
  billIDs=selectedRowsInfo.GetPrimaryKeyValues();
  entryIDs=selectedRowsInfo.GetEntryPrimaryKeyValues();
  msg=("选中了[{0}]个单据,[{1}]条明细！").format(billIDs.Length,entryIDs.Length);
  this.View.ShowMessage(msg);

#列表双击事件
def ListRowDoubleClick(e):
  row=e.Row;#双击的行号
  colKey=e.ColKey;#双击单元格列标识,这里取到的是列表显示字段名，不能直接用来取单元格的值,可用来做单元格判断
  currentPageRowsInfo = this.ListView.CurrentPageRowsInfo;#列表当前页的数据
  startRow = this.ListModel.StartRow;#当前页开始序号
  num = row - startRow;#双击行所在当前页的行序号
  listSelectedRow = currentPageRowsInfo[num - 1];#当前双击行数据
  FID=listSelectedRow.PrimaryKeyValue;#双击行单据ID
  entryId=listSelectedRow.EntryPrimaryKeyValue;#双击行明细ID
  #通过QueryBuilderParemeter取数，可以获取当前单元格的值,这里顺便演示一下这种取数方法吧*****************
  queryParam=QueryBuilderParemeter();
  queryParam.FormId=this.View.BillBusinessInfo.GetForm().Id;
  queryParam.BusinessInfo=this.View.BillBusinessInfo;
  #billId=SelectorItemInfo(this.View.BillBusinessInfo.GetForm().PkFieldName);#单据内码
  #queryParam.SelectItems.Add(billId);
  #billNo=SelectorItemInfo("FBillNo");#单据编号
  #queryParam.SelectItems.Add(billNo);
  #supplierId=**SelectorItemInfo**("FSupplierId");#供应商内码
  #queryParam.SelectItems.Add(supplierId);
  #supplierName=Selector**Ref**ItemInfo("**FSupplierId.FName**");#取基础资料属性字段写法不一样,要注意
  #supplierName.PropertyName="**FSupplierId_FName**";估计后台是SQL取数，字段名不能有".",要重命名
  #queryParam.SelectItems.Add(supplierName);
  #以上是通过QueryBuilderParemeter取数示例,下面就是取当前双击单元格的*************************************
  fldKey=colKey;
  if("." in colKey):#说明是基础资料的属性
    colItem=SelectorRefItemInfo(colKey);
    fldKey=colKey.Replace(".","_");
    colItem.PropertyName=fldKey;
    queryParam.SelectItems.Add(colItem);
  else:
    queryParam.SelectItems.Add(SelectorItemInfo(colKey));
  entity=this.View.BillBusinessInfo.GetEntity(listSelectedRow.EntryEntityKey);
  if(entity<>None):#列表显示了单据体
    queryParam.FilterClauseWihtKey=("{0}_{1}={2}").format(entity.Key,entity.EntryPkFieldName,entryId);
  else:#列表只显示了单据头
    queryParam.FilterClauseWihtKey=("{0}={1}").format(this.View.BillBusinessInfo.GetForm().PkFieldName,FID);
  dataRows=QueryServiceHelper.GetDynamicObjectCollection(this.Context, queryParam);#获取数据结果数据包
  colValue="";
  if(dataRows.Count>0):
    colValue=("{0}").format(dataRows[0][fldKey]);
  msg=("双击了第{0}行的[{1}]").format(row,colValue);
  this.View.ShowMessage(msg);
  e.Cancel=True;#取消双击事件,否则双击会打开单据,也可以在BOS中取消列表双击事件绑定的操作

#列表单元格超链接点击事件
#该事件中数据处理方式和上面的列表双击事件中几乎一致,这里不再重复讲解
def EntryButtonCellClick(e):
  row=e.Row;#点击超链接所在序号
  fldKey=e.FieldKey;#超链接所在列字段标识
  msg=("点击了第{0}行的[{1}]").format(row,fldKey);
  this.View.ShowMessage(msg);
  e.Cancel=True;#取消事件,单据编号会自动超链接打开单据

#列表条件格式化事件
#可在此事件中根据不同的条件判断设置颜色,BOS中也可以配置，这里可以实现更灵活的条件判断
def OnFormatRowConditions(args):
  if (args.DataRow.ColumnContains("FMaterialId_Ref")):
    #注意！！！这里根据特别演示基础资料属性字段判断设置颜色，因为【列表条件格式化】不支持配置基础资料属性字段作为条件字段
    matObj=args.DataRow.DynamicObject["FMaterialId_Ref"];#物料字段实体数据包，可以取到引用属性中添加了的属性字段
    matNum=("{0}").format(matObj["Number"])
    if(matNum[0:1]=="1"):#物料编码是1开头的显示颜色,这里是实体数据包取值，别忘了是用绑定实体属性标识
      fc=FormatCondition();
      fc.ForeColor="#FFFF9B98";#前景色
      #fc.BackColor="#FFFF9B98";#背景色
      args.FormatConditions.Add(fc);
  if(args.DataRow.ColumnContains("FDate")):
    #这里是普通字段判断设置颜色，首先需要判断列表是否显示了这个字段，否则没显示该字段时会报错，而且只有显示了这个字段才能判断设置颜色
    dateStr=str(args.DataRow["FDate"]);#创建人Id
    date=DateTime.Parse(dateStr).ToString("yyyy-MM-dd");
    #this.View.ShowMessage(date);
    if(date==DateTime.Now.ToString("yyyy-MM-dd")):#单据日期=今天的单据显示颜色
      fc=FormatCondition();
      #fc.ForeColor="#FFFF9B98";#前景色
      fc.BackColor="#0000FF";#背景色
      args.FormatConditions.Add(fc);



#单据界面执行单据操作前触发，例如，保存,提交,审核等，使用时一定要判断操作代码
#与表单插件类似，不同的是，列表里面是批量处理，通常需要获取勾选的所有单据,参考前面事件中的介绍
def BeforeDoOperation(e):
  opCode=e.Operation.FormOperation.Operation.ToUpperInvariant();#触发操作代码大写,例如保存:SAVE
  if(opCode=="DELETE"):
    e.Cancel=True;#可以取消触发操作
    this.View.ShowWarnningMessage("取消删除！");
#单据界面执行单据操作完成后触发，例如，保存,提交,审核等，使用时一定要判断操作代码
#与表单插件类似，不同的是，列表里面是批量处理，通常需要获取勾选的所有单据,参考前面事件中的介绍
def AfterDoOperation(e):
  opCode=e.Operation.Operation.ToUpperInvariant();#触发操作代码大写,例如保存:SAVE
  this.View.ShowMessage(str(opCode));
```


好了，列表插件的 常用事件就介绍到这里，了解这些事情也基本能满足常见需求了。![img](https://vipfront.s3.cn-north-1.amazonaws.com.cn/emotion/define/55.gif)



## 五、列表插件读取单据数据

  对于列表插件开发，通常是对单据进行批量处理，列表插件中读取单据数据的方法也不同，这里简单介绍一下。

  在列表插件中是不能直接读取到完整的单据数据包的，需要变通获取，一般来讲是读取勾选的数据，在列表插件的成员中可以读取到勾选的数据行，但是字段信息不全，所以思路都是根据勾选的构建过滤条件，再去查询单据。

- ***\*首先,我们再来回忆一下列表插件读取数据要用到的几个成员：\****
```python
  currentSelectedRow=this.ListView.CurrentSelectedRowInfo;#当前列表上当前选择行数据，即焦点行，单行数据
  selectedRowsInfo=this.ListView.SelectedRowsInfo;#列表勾选的数据集合
  billIDs=selectedRowsInfo.GetPrimaryKeyValues();#可以用来构建单据过滤条件查询单据
  entryIDs=selectedRowsInfo.GetEntryPrimaryKeyValues();
  datas = this.ListModel.GetData(selectedRowsInfo);#根据勾选的数据集获取数据包,DynamicObjectCollection类型
  if (datas.Count <= 0):#根据这个数据包集合来判断列表是否有勾选的数据行
    this.View.ShowWarnningMessage("未选择任何行！");
    return;
  #有时候也需要根据列表的分页数据来获取
   currentPageRowsInfo = this.ListView.CurrentPageRowsInfo;#列表当前页的数据
   startRow = this.ListModel.StartRow;#当前页开始序号
```
- ***\*在列表插件中，一般都是\*\*\*\*基于以上成员变量来读取单据数据，读取数据的方法有下面几种\*\*\*\*：\****

  **①通过QueryBuilderParemeter取数方法来读取单据数据,参考前面列表双击事件中的介绍，效率较高,推荐！*****\*
  \****

  **②直接从selectedRowsInfo数据包中获取字段值,参考OnFormatRowConditions事件中的示例代码。*****\*
  \****

  ​    注意！这种方法只能获取当前列表显示出来的字段，以及单据编号、内码等一些关键字段信息。

​    可以通过循环的方式逐行获取字段值，示例代码如下:
```python
  for row in selectedRowsInfo:
    dr=row.DataRow;
    billNo=row.BillNo;#单据编号
    billId=row.PrimaryKeyValue;#单据ID
    entryId=row.EntryPrimaryKeyValue;#明细ID，显示了单据体才会有值
    entityKey=str(row.EntryEntityKey);#当前显示的单据体标识,可用来判断entryId是属于哪个单据体的
    #其他字段要先判断是否显示
    if(dr.ColumnContains("FMaterialId_Id")):#物料Id
      matId=dr.DynamicObject["FMaterialId_Id"];
    if(dr.ColumnContains("FMaterialId_Ref")):#物料数据包
      #可以从这里读取基础资料属性字段,基础资料的取值方式可以参考这里
      matObj=dr.DynamicObject["FMaterialId_Ref"];
      matNum=matObj["Number"];#物料编码
      matName=matObj["Name"];#物料名称
    if(dr.ColumnContains("FDate")):#日期,普通字段参考这里
      date=dr.DynamicObject["FDate"];
```
  **③或者通过数据包datas中获取数据，方法其实与第②种从selectedRowsInfo中取数类似。**

  **datas是一个DynamicObjectCollection**类型的数据集，是不是很熟悉了呢，学到这里，解析这个应该问题不大了！

  datas和selectedRowsInfo中的字段标识一样，也是只能取到列表显示的字段，并且取数方法也类似。
```python
  for row in datas:
    billNo=row["FBILLNO"];#单据编号
    billId=row["FID"];#单据ID
    #其他字段建议先判断是否存在
    if(row.DynamicObjectType.Properties.ContainsKey("FMaterialId_Id")):#物料Id
      matId=row["FMaterialId_Id"];
    if(row.DynamicObjectType.Properties.ContainsKey("FMaterialId_Ref")):#物料数据包
      #可以从这里读取基础资料属性字段,基础资料的取值方式可以参考这里
      matObj=row["FMaterialId_Ref"];
      matNum=matObj["Number"];#物料编码
      matName=matObj["Name"];#物料名称
    if(row.DynamicObjectType.Properties.ContainsKey("FDATE")):#日期,普通字段参考这里
      date=row["FDate"];
```
  **④基于取到的单据内码ID和单据明细ID，拼接SQL，直接从数据库查询数据**



列表插件示例代码：

```python
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from Kingdee.BOS.Core.List import*
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Core.SqlBuilder import *
from Kingdee.BOS.Core.Metadata import *
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *

#列表插件过滤事件,加载列表时会触发
#用法1:对列表过条件进行干预,此用法最广
#用法2:修改快捷过滤和过滤框的条件过滤,案例:动态构建下拉列表-年份
def PrepareFilterParameter(e):
	custfilterObj=e.CustomFilter;#过滤框实体数据包
	filterStr=e.FilterString;#过滤框条件过滤表达式
	sortStr=e.SortString#排序字段表达式
	statusFilterStr=e.StatusFilterString;#状态字段过滤表达式
	#msg=("{0}").format(statusFilterStr);
	#this.View.ShowMessage(msg);
	#myFilterStr=("FBillNo like '%{0}%' ").format("1");#单据编号包含1
	#e.AppendQueryFilter(myFilterStr);#追加过滤条件

#列表菜单点击事件,列表菜单点击开始时触发
#此事件也是很常用的,可以在此事件中取消菜单的点击事件
#使用时一定要判断菜单标识!!!
def BarItemClick(e):
	key=e.BarItemKey.ToUpperInvariant();
	if(key=="TestBtn".ToUpperInvariant()):
		#e.Cancel=True;#取消菜单的点击，可以阻止后续功能的触发,可完成一些简单校验
		#msg=("菜单[{0}]点击被取消啦！").format(key);
		#this.View.ShowMessage(msg);
		return;
	
#列表菜单点击后事件,列表菜单点击完成后触发
#使用时一定要判断菜单标识!!!
#自定义菜单功能实现建议在此事件中完成
#应用案例:列表插件实现单据批改
def AfterBarItemClick(e):
	key=e.BarItemKey.ToUpperInvariant();
	if(key<>"TestBtn".ToUpperInvariant()):
		return;
	msg=("菜单[{0}]点击完成啦！").format(key);
	#this.View.ShowMessage(msg);
	selectedRowsInfo=this.ListView.SelectedRowsInfo;#列表勾选的数据集
	billIDs=selectedRowsInfo.GetPrimaryKeyValues();
	entryIDs=selectedRowsInfo.GetEntryPrimaryKeyValues();
	datas = this.ListModel.GetData(selectedRowsInfo);#根据勾选的数据集获取数据包
	if (datas.Count <= 0):
		this.View.ShowWarnningMessage("未选择任何行！");
		return;
	msg=("选中了[{0}]个单据,[{1}]条明细！").format(billIDs.Length,entryIDs.Length);
	s="";
	#下面是方法③读取所有选中行的字段数据示例
	for row in datas:
		billNo=row["FBILLNO"];#单据编号
		billId=row["FID"];#单据ID
		s=("{0}\r\n{1}--{2}").format(s,billNo,billId);
		#其他字段建议先判断是否存在
		if(row.DynamicObjectType.Properties.ContainsKey("FMaterialId_Id")):#物料Id
			matId=row["FMaterialId_Id"];
			s=("{0}--{1}").format(s,matId);
		if(row.DynamicObjectType.Properties.ContainsKey("FMaterialId_Ref")):#物料数据包
			#可以从这里读取基础资料属性字段,基础资料的取值方式可以参考这里
			matObj=row["FMaterialId_Ref"];
			matNum=matObj["Number"];#物料编码
			matName=matObj["Name"];#物料名称
			s=("{0}--{1}--{2}").format(s,matNum,matName);
		if(row.DynamicObjectType.Properties.ContainsKey("FDATE")):#日期,普通字段参考这里
			date=row["FDate"];
			s=("{0}--{1}").format(s,date);
	msg=("提示：{0}").format(s);
	this.View.ShowMessage(msg);

#列表双击事件
def ListRowDoubleClick(e):
	row=e.Row;#双击的行号
	colKey=e.ColKey;#双击单元格所在列字段标识,不能直接用来取单元格的值,可用来做单元格判断
	currentPageRowsInfo = this.ListView.CurrentPageRowsInfo;#列表当前页的数据
	startRow = this.ListModel.StartRow;#当前页开始序号
	num = row - startRow;#双击行所在当前页的行序号
	listSelectedRow = currentPageRowsInfo[num - 1];#当前双击行数据
	FID=listSelectedRow.PrimaryKeyValue;#双击行单据ID
	entryId=listSelectedRow.EntryPrimaryKeyValue;#双击行明细ID
	#通过QueryBuilderParemeter取数，可以获取当前单元格的值,这里顺便演示一下这种取数方法吧**************************
	queryParam=QueryBuilderParemeter();
	queryParam.FormId=this.View.BillBusinessInfo.GetForm().Id;
	queryParam.BusinessInfo=this.View.BillBusinessInfo;
	#billId=SelectorItemInfo(this.View.BillBusinessInfo.GetForm().PkFieldName);#单据内码
	#queryParam.SelectItems.Add(billId);
	#billNo=SelectorItemInfo("FBillNo");#单据编号
	#queryParam.SelectItems.Add(billNo);
	#supplierId=SelectorItemInfo("FSupplierId");#供应商内码
	#queryParam.SelectItems.Add(supplierId);
	#supplierName=SelectorRefItemInfo("FSupplierId.FName");#取基础资料属性字段写法不一样,要注意
	#supplierName.PropertyName="FSupplierId_FName";#后台是SQL取数，字段名不能有".",要重命名
	#queryParam.SelectItems.Add(supplierName);
	#以上是通过QueryBuilderParemeter取数示例,下面就是取当前双击单元格的值******************************************
	fldKey=colKey;
	if("." in colKey):#说明是基础资料的属性
		colItem=SelectorRefItemInfo(colKey);
		fldKey=colKey.Replace(".","_");
		colItem.PropertyName=fldKey;
		queryParam.SelectItems.Add(colItem);
	else:
		queryParam.SelectItems.Add(SelectorItemInfo(colKey));
	entity=this.View.BillBusinessInfo.GetEntity(listSelectedRow.EntryEntityKey);
	if(entity<>None):#列表显示了单据体
		queryParam.FilterClauseWihtKey=("{0}_{1}={2}").format(entity.Key,entity.EntryPkFieldName,entryId);
	else:#列表只显示了单据头
		queryParam.FilterClauseWihtKey=("{0}={1}").format(this.View.BillBusinessInfo.GetForm().PkFieldName,FID);
	dataRows=QueryServiceHelper.GetDynamicObjectCollection(this.Context, queryParam);#获取数据结果数据包
	colValue="";
	if(dataRows.Count>0):
		colValue=("{0}").format(dataRows[0][fldKey]);
	msg=("双击了第{0}行的[{1}]").format(row,colValue);
	this.View.ShowMessage(msg);
	e.Cancel=True;#取消双击事件,否则双击会打开单据,也可以在BOS中取消列表双击事件绑定的操作

#列表单元格超链接点击事件
#该事件中数据处理方式和上面的列表双击事件中几乎一致,这里不再重复讲解
def EntryButtonCellClick(e):
	row=e.Row;#点击超链接所在序号
	fldKey=e.FieldKey;#超链接所在列字段标识
	msg=("点击了第{0}行的[{1}]").format(row,fldKey);
	this.View.ShowMessage(msg);
	e.Cancel=True;#取消事件,单据编号会自动超链接打开单据

#列表条件格式化事件
#可在此事件中根据不同的条件判断设置颜色,BOS中也可以配置，这里可以实现更灵活的条件判断
def OnFormatRowConditions(args):
	if (args.DataRow.ColumnContains("FMaterialId_Ref")):
		#注意！！！这里根据特别演示基础资料属性字段判断设置颜色，因为【列表条件格式化】不支持配置基础资料属性字段作为条件字段
		matObj=args.DataRow.DynamicObject["FMaterialId_Ref"];#物料字段实体数据包，可以取到引用属性中添加了的属性字段
		matNum=("{0}").format(matObj["Number"])
		if(matNum[0:1]=="1"):#物料编码是1开头的显示颜色,这里是实体数据包取值，别忘了是用绑定实体属性标识
			fc=FormatCondition();
			fc.ForeColor="#FFFF9B98";#前景色
			#fc.BackColor="#FFFF9B98";#背景色
			args.FormatConditions.Add(fc);
	if(args.DataRow.ColumnContains("FDate")):
		#这里是普通字段判断设置颜色，首先需要判断列表是否显示了这个字段，否则没显示该字段时会报错，而且只有显示了这个字段才能判断设置颜色
		dateStr=str(args.DataRow["FDate"]);#创建人Id
		date=DateTime.Parse(dateStr).ToString("yyyy-MM-dd");
		#this.View.ShowMessage(date);
		if(date==DateTime.Now.ToString("yyyy-MM-dd")):#单据日期=今天的单据显示颜色
			fc=FormatCondition();
			#fc.ForeColor="#FFFF9B98";#前景色
			fc.BackColor="#0000FF";#背景色
			args.FormatConditions.Add(fc);

#单据界面执行单据操作前触发，例如，保存,提交,审核等，使用时一定要判断操作代码
#与表单插件类似，不同的是，列表里面是批量处理，通常需要获取勾选的所有单据,参考前面事件中的介绍
def BeforeDoOperation(e):
	opCode=e.Operation.FormOperation.Operation.ToUpperInvariant();#触发操作代码大写,例如保存:SAVE
	if(opCode=="DELETE"):
		e.Cancel=True;#可以取消触发操作
		this.View.ShowWarnningMessage("取消删除！");
#单据界面执行单据操作完成后触发，例如，保存,提交,审核等，使用时一定要判断操作代码
#与表单插件类似，不同的是，列表里面是批量处理，通常需要获取勾选的所有单据,参考前面事件中的介绍
def AfterDoOperation(e):
	opCode=e.Operation.Operation.ToUpperInvariant();#触发操作代码大写,例如保存:SAVE
	this.View.ShowMessage(str(opCode));
			
```

作者：CQ周玉立

来源：金蝶云社区

原文链接：https://vip.kingdee.com/article/340915204772775936?productLineId=1
