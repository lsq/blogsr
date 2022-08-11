---
title: "Python插件常用事件方法"
date: Mon, 20 Dec 2021 08:47:46 +0800
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
## Python插件常用事件方法

### 常用事件方法

1. 获取单据体总行数

   ```python
   rows=this.Model.GetEntryRowCount("单据体的标识");
   ```

2. 获取基础资料

   1. 获取单据体某行物料

      ```python
      baseObj=this.Model.GetValue("FMaterialID",行);
      ```
      
   2. 获取单据头基础资料仍然是这个语法，把行去掉即可，如

      ```python
      baseObj=this.Model.GetValue("FCutomerID");
      ```

      获取基础资料时要注意，需要判断是否为空。比如当新建一个单据还没有进行任何录入时，你获取单据上某个基础资料，可能会在运行时提示：
      'NoneType' object is unsubscriptable
      这是因为该基础资料字段还是NULL状态，对象没有创建成功，所以为NoneType，大概意思就是 x = None 然后你使用了x[0]，就会出现这个错误。
      所以需要在脚本里进行判断。

3. 半断对象是否为空

   ```python
   if baseObj is None
   ```

4. BeforeSave事件

   ```python
   def BeforeSave(e):
   	this.View.ShowMessage("单据保存前触发的事件");
   ```
   然后做张单据，保存。你会发现事件已触发。

### 单据体常用操作

1. 新增新行：
   
   ```   python
   this.Model.CreateNewEntryRow（string key）       //key为单据体标识
   
2. 删除行：

   ```python
   this.Model.DeleteEntryRow（string key, int row） //key为单据体标识
   ```

3. 获取当前行Index

   ```python
   this.Model.GetEntryCurrentRowIndex(string key) //key为单据体标识
   ```

4. 获取单据体行数量

   ```python
   this.Model.GetEntryRowCount(string key)
   ```

5. 获取单据体数据

   ```c#
   var entity = this.View.BusinessInfo.GetEntity(key) //key为单据体标识
   var entityData = this.Model.GetEntityDataObject(entity)
   //注：
   //**子单据体**通过这种方式获取数据，只能获取到当前选中单据体行对应的子单据体数据
   //若要获取所有子单据体的数据，需要通过单据体数据获得，如下
   var entity = this.View.BusinessInfo.GetEntity(key)   //key为单据体标识
   var entityData = this.Model.GetEntityDataObject(entity)
   var subEntityData =  entityData.Where(e => e[subEntityProp] != null)
                      .SelectMany(e => (e[subEntityProp] as DynamicObjectCollection)	
   		  //subEntityProp 为**子单据体** ORM实体名
   ```

	```python
	from System import DateTime
	from Kingdee.BOS.Core import *
	def BeforeSave(e):	
    counts = this.Model.GetEntryRowCount("FPAYBILLENTRY") ---单据明细的ID	
    for i in range(counts):		
        x = this.Model.GetValue("FCOSTID",i)		
        if  x is not None: 			
            this.Model.SetValue("FCOMMENT",str(this.Model.GetValue("FCOSTID",i)["NAME"]),i)
	```
	
6. 获取单据体对应字段数据

   - 通过GetValue获取

   ```python
   this.Model.GetValue(key,row) //key为字段标识，row是所处行index
   ```
   - 通过获取的单据体数据获得，参考第5点
   
   ```python
   entityData[row][key] //key为绑定实体属性，row是所处行index
   ```
   
   - AfterBindData 控件绑定数据后触发，根据其他条件设置控件的可见性、可用性等样式
   
   ```c#
   public override void AfterBindData(EventArgs e)
   {
       base.AfterBindData(e):
       //设置可见性 - 隐藏“旧物料编码”字段
       this.View.StyleManager.SetVisible("FOldNumber", null, false);
       //设置光标锁定
       Control ControlFBARCODE = this.View.GetControl("FBARCODE"); //获取控件
       ControlFBARCODE.SetEnterNavLock(true); //应用刷条码业务场景，一直回车光标锁定
       Control ControlFNumber = this.View.GetControl("FNumber"); //获取控件
       ControlFNumber.SetEnabled("", false);
       ControlFNumber.ControlAppearance.BackColor = "#E90b19";
       ControlFnumber.SetCustomPropertyValue("backcolor", "115,208,241"); //背景
   }
   ```
   
     [原文链接](https://vip.kingdee.com/article/213329000347951360)
   

### 列表的插件常用方法

引用：
```c#
Kingdee.BOS.Core.dll；
```

使用：

```c#
using Kingdee.BOS;
using Kingdee.BOS.Core.List;
using Kingdee.BOS.Core.List.PlugIn;
```

常用方法：

1. 选择行

   ```c#
   ListSelectedRowCollection selectRows = this.ListView.SelectedRowsInfo
   ```

2. 选择的第几行

   ```c#
   selectRows.GetRowKeys()
   ```

3. 获取单据行ID

   ```c#
   selectRows.GetPKEntryIdValues()
   List<KeyValuePair<object,object>> rows= selectRows.GetPKEntryIdValues()
   ```

4. 获取行选择信息

   ```c#
   this.ListModel.GetData(selectRows)
   Kingdee.BOS.Orm.DataEntity.DynamicObjectCollection
   ```

5. 刷新

   ```c#
   Refresh()
   ```

6. 获取单据编号

   ```c#
   this.ListView.SelectedRowsInfo[0].BillNo
   ```

7. 获取选择单据体信息

   ```c#
   this.ListView.SelectedRowsInfo[0].DataRow
   ```

   

### 示例

#### 字段锁定

```python
import clr
clr.AddReference('mscorlib')
clr.AddReference('Kingdee.BOS.Core')
from System import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *

def  AfterBindData(e):
	this.View.GetFieldEditor("F_ora_PRQty", 0).Enabled = False # 计划属性--PR下达数量锁定，参考官方教程
    #this.View.GetFieldEditor("F_JD_Number1", rowIndex).SetEnabled("", false);这种方法是一个一个单元格进行锁定的，要遍历这一行所有的字段，然后进行锁定；另外在该语句后不能用updateView这个方法，因为这个方法会把model里的字段属性重新刷到View上，而model里之前应该是不锁定这些单元格的。也就是如果要使用updateView，就要在updateView以后再对单元格进行锁定才能看到效果。
	#原文链接：https://vip.kingdee.com/article/81318303133493248?productLineId=1
```

[4.5、表单插件，锁定、隐藏，字段，this.View.GetControl()](https://vip.kingdee.com/article/65480895016288768?productLineId=1)

判断单据是否新增、复制新增

```python
import clr
clr.AddReference('mscorlib')
clr.AddReference('Kingdee.BOS.Core')
from System import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *


def OnLoad(e):
	id = str(this.View.Model.DataObject[0])
	#this.View.ShowMessage("新增success!--" + str(id))
	if id == '' or id == '0':
		this.View.ShowMessage("新增success!")
		
def  CreateNewData(e):
	IsNewData = True
	if IsNewData :
		this.View.ShowMessage("新增成功！")
		
def  AfterCopyData(e):
	IsCopyData = True
	if IsCopyData :
		this.View.ShowMessage("Copy 成功！")
```

#### 字段值更新

```python
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.DataEntity')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.App.Core')
clr.AddReference('Kingdee.BOS.ServiceHelper')
#导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.DependencyRules import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *
from Kingdee.BOS.Core.DynamicForm import *
from Kingdee.BOS.Core.Metadata.EntityElement import *
from Kingdee.BOS.Core.Metadata.FieldElement import *
from Kingdee.BOS.Orm.DataEntity import *

def DataChanged(e):
	fldKey=e.Field.Key.ToUpperInvariant();#字段标识大写
	if(fldKey == "F_MAXEYE_GIVEAWAY" ):#注意:示例代码是不等于，实际应使用等于进行判断
		row=e.Row;#字段所在的行号,从0开始，单据头字段为0
		oldValue=e.OldValue;#更新前字段值
		newValue=e.NewValue;#更新后的字段值
		msg=("第[{0}]行字段[{1}]从[{2}]更新成了[{3}]").format(row,fldKey,oldValue,newValue);
		if newValue == 1:
			this.View.Model.SetItemValueByNumber("FSTOCKSTATUSID","KCZT01_USR",row); # 基础资料赋值用法
		else:
			this.View.Model.SetItemValueByNumber("FSTOCKSTATUSID","KCZT01_SYS",row); # 基础资料赋值用法
		this.View.ShowMessage(msg);
```

#### 表单插件表单信息框提示

```python
def BarItemClick(e):
#if条件判断，当点击YDIE_ tbGetSetValue这个按钮时候触发
	if (e.BarItemKey == "tbGetValue"):
		opResult = OperationResult();
		ropResult = OperateResult()
		proPertiesList = ''
		
		ropResult.Name = "hello，lsq，操作成功，信息提示成功"
		opResult.OperateResult.Add(ropResult)
		#for p in dir(ropResult.OperateResult):
		#	proPertiesList = proPertiesList + ',' + str(p);
		#this.View.ShowMessage(str(type(opResult.OperateResult)))
		#this.View.ShowMessage(proPertiesList)
		this.View.ShowOperateResult(opResult.OperateResult)
```
