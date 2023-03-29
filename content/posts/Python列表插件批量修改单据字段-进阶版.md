---
title: "列表插件批量修改单据字段"
date: Wed, 23 Nov 2022 15:28:51 +0800
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
前面分享了：**[Python实现单据批改(单据头字段)](https://vip.kingdee.com/article/157162374296835584)，**有小伙伴问我：想批改明细字段怎么办呢？![img](https://vipfront.s3.cn-north-1.amazonaws.com.cn/emotion/define/64.gif)

我这里分享一下用**Python列表插件如何批量更新明细字段。![img](https://vipfront.s3.cn-north-1.amazonaws.com.cn/emotion/define/16.gif)**

对于明细字段的批量更新，我觉得根据批量更新明细字段**值来源不同**，主要分为两种场景：

**1.明细字段的值来源于系统中，不需要用户手动录入，只需要根据单据上的字段即可关联过来批量更新。**

例如，在物料里面新增了一个字段属性，需要批量更新历史单据，从明细物料关联过来，在列表对勾选的单据批量更新。

**2.明细字段的值来源于用户录入，需要像批改表头字段一样，弹出界面，让用户录入，后批量修改勾选的单据。**

此场景，由于不同场景，需要录入的字段类型不同，弹出的界面需要自定义设计，所以此功能只能定制化处理，无法通用。注意：此方案是采用SQL直接更新数据库字段，没有校验控制，且不会触发单据字段值更新、实体服务规则，谨慎使用！

**对于列表更新明细字段的关键问题是：需要获取到勾选的明细行ID**

下面针对以上两种场景分享一下Python列表插件如何处理，不说太多，请看示例代码：
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
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *



def BarItemClick(e):
	btnKey = e.BarItemKey.ToUpper();
    if(btnKey=="BTNTTT"):#列表自定义菜单按钮大写

    #若需要加校验条件，可参考此代码处理
    #if(勾选的单据都允许修改(条件逻辑自行添加)):

		#this.View.ShowWarnningMessage("单据编号[XXX]第[x]行不允许修改，请重新勾选数据！");

		      #e.Cancel=True;

		      #return;

		  selectedRowsInfo = this.ListView.SelectedRowsInfo;

		  datas = this.ListModel.GetData(selectedRowsInfo);#这句代码似乎选中的数据行超过1000多行，会报错，请做处理！

		  if (datas.Count <= 0):

			    return;

		  listEntryId=List[str]();

		  for row in selectedRowsInfo:

			    selectEntryId=str(row.EntryPrimaryKeyValue);

			    entityKey=str(row.EntryEntityKey);

#列表一定要显示出需要更新的明细字段所在的单据体，不然无法获取明细行ID

			    if(selectEntryId=="" or selectEntryId==None or entityKey<>"FEntity"):

				      this.View.ShowWarnningMessage("请在过滤里面显示单据体[FEntity]!");

				      return;

			    listEntryId.Add(selectEntryId);

  rowIndexs = str.Join(",", listEntryId.ToArray());#将获取到的明细行ID构造成逗号隔开的字符串，

  #this.View.ShowMessage("当前选中行：" + rowIndexs);

  **#场景1：下面就可以根据获取到的明细行ID构建SQL，更新明细字段(自行根据实际情况处理)**

			  updateSql=("/*dialect*/update BHU_GZFFCFD001_ENTRY set F_YXXYSWD='XXX' where FENTRYID in ({0})").format(rowIndexs );

			  x=DBServiceHelper.Execute(this.Context,updateSql);
```
  **#场景2：弹出用户录入界面，让用户录入字段更新值，然后再更新字段**

  **#需要自己在BOS开发动态表单，然后返回录入值，在回调方法更新单据明细字段，\**(自行根据实际情况处理)\****

  ***\*#Python弹出动态表单，回调获取子页面返回值\*******\*参考我另一篇文章：[点击菜单弹出动态表单传递参数到子页面](https://vip.kingdee.com/article/291523970094684160)\****

  ***\*#动态表单子页面需要编写表单插件将用户录入的字段值返回父页面,可参考：[子页面关闭返回数据到父页面](https://vip.kingdee.com/article/291524092769768448?fromAction=POST_ARTICLE)\****

  **#动态表单关闭返回到父页面，获取到用户录入值后，*****\*再结合场景1的方法，更新明细字段。\****

  ***\*#当然，也可以把获取到的明细ID传入子页面，在动态表单插件\*******\*中处理直接更新单据！\****





------

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
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *

def BarItemClick(e):
	btnKey = e.BarItemKey.ToUpper();
	if(btnKey=="BTNTTT"):
		#e.Cancel = True;
		selectedRowsInfo = this.ListView.SelectedRowsInfo;
		datas = this.ListModel.GetData(selectedRowsInfo);
		if (datas.Count <= 0):
			return;
		listEntryId=List[str]();
		for row in selectedRowsInfo:
			selectEntryId=str(row.EntryPrimaryKeyValue);
			entityKey=str(row.EntryEntityKey);
			if(selectEntryId=="" or selectEntryId==None or entityKey<>"FEntity"):
				this.View.ShowWarnningMessage("请在过滤里面显示单据体[FEntity]!");
				return;
			listEntryId.Add(selectEntryId);
		rowIndexs = str.Join(",", listEntryId.ToArray());
		
```



【温馨提示![img](https://vipfront.s3.cn-north-1.amazonaws.com.cn/emotion/define/62.gif)



作者：CQ周玉立



原文链接：https://vip.kingdee.com/article/291170608069603584?productLineId=1

