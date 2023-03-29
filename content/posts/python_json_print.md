```python
#引入clr运行库
import clr
#添加对cloud插件开发的常用组件的引用
clr.AddReference('System')
clr.AddReference('mscorlib')
clr.AddReference('System.Data')
clr.AddReference('Kingdee.BOS')
clr.AddReference('Kingdee.BOS.Core')
clr.AddReference('Kingdee.BOS.App')
clr.AddReference('Kingdee.BOS.ServiceHelper')
clr.AddReference('Kingdee.BOS.WebApi.Client')
clr.AddReference('Newtonsoft.Json')
# 导入cloud基础库中的常用实体对象（分命名空间导入，不会递归导入）
from Kingdee.BOS import *
from Kingdee.BOS.Core import *
from Kingdee.BOS.Core.Bill import *
from Kingdee.BOS.Core.DynamicForm import *
from Kingdee.BOS.Core.DynamicForm.PlugIn import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.ControlModel import *
from Kingdee.BOS.Core.DynamicForm.PlugIn.Args import *
from Kingdee.BOS.Core.List import*
from Kingdee.BOS.Core.List.PlugIn import *
from Kingdee.BOS.Core.SqlBuilder import *
from Kingdee.BOS.Core.Metadata import *
from System import *
from System.Data import *
from Kingdee.BOS.App.Data import *
from System.Collections.Generic import List
from Kingdee.BOS.ServiceHelper import *
from Kingdee.BOS.Util import *
from Newtonsoft.Json import JsonConvert #SerializeObject
from Newtonsoft.Json.Linq import * #SerializeObject
from Kingdee.BOS.WebApi.Client import *

def OnAfterPrint(e):
	djbs = this.ListView.BillBusinessInfo.GetForm().Id.ToString(); #单据标识
	djnm = this.ListView.BillBusinessInfo.GetForm().Name.ToString();  #单据名
	dysj = TimeServiceHelper.GetSystemDateTime(this.Context).ToString();  #打印时间
	dyname = this.Context.UserName.ToString();  #打印人
	userid = str(this.Context.UserId);   #得到当前登陆用户ID
	yhsql = "SELECT COUNT(*) FROM T_SEC_USER as a INNER JOIN T_SEC_USERORG as zz on a.FUSERID = zz.FUSERID ";
	yhsql = yhsql + " INNER JOIN T_SEC_USERROLEMAP as gx on zz.FENTITYID = gx.FENTITYID ";
	yhsql = yhsql + " INNER JOIN T_SEC_ROLE_L as jsl on gx.FROLEID = jsl.FROLEID "
	yhsql = yhsql + " where jsl.FNAME like '%制造%' and a.FUSERID = " + userid;
	dz = DBUtils.ExecuteScalar(this.Context,yhsql,None);
	zzbs = 0;  #制造标识
	if dz > 0:
		zzbs = 1;
	rows = e.NoteIDPairs.Count;   #打印主表行数
	#zj = DBServiceHelper.GetSequenceInt32(this.Context,"Z_wjdz_t_Cust100186", rows);  #生成主键数组
	hctj = JSON.JSONArray();
	for i in range(0, rows, 1):
		zdnm = e.NoteIDPairs[i].Key;  #主单内码
		sql = str.Format("/*dialect*/ SELECT top(1) FBILLNO FROM T_PRD_PPBOM where Fid = {0}",zdnm);
		zdjbm = DBUtils.ExecuteScalar(this.Context,sql,None);  #主单据编码
		dymbbs = e.NoteIDPairs[i].Value.ToString();  #打印标识内码
		sql = str.Format("/*dialect*/ SELECT top(1) FNAME FROM T_META_OBJECTTYPE_L where Fid = N'{0}'",dymbbs);
		dymbmc = DBUtils.ExecuteScalar(this.Context,sql,None).ToString();  #打印模板名称
		njo = JSON.JSONObject();
		#njo["FID"] = zj[i];  #主键   实际测试，用API批量插入数量不需要生成主键
		njo["F_wjdz_Djm"] = djnm; #单据名
		njo["F_wjdz_Djbh"] = zdjbm; #主单据编码
		njo["F_wjdz_Dymbm"] = dymbmc;  #打印模板名称
		njo["F_wjdz_Djnm"] = zdnm;  #主单内码
		njo["F_wjdz_Dyr"] = dyname; #打印人
		njo["F_wjdz_Dysj"] = dysj; #打印时间
		njo["F_wjdz_Djbs"] = djbs;  #单据标识
		njo["F_wjdz_Dymbbs"] = dymbbs;  #打印模板标识内码
		njo["F_wjdz_Zzbs"] = zzbs;  #制造标识
		hctj.Add(njo);
	gxjson = JSON.JSONObject();
	gxjson["Model"] = hctj;
	url = "http://127.0.0.1/k3cloud/";
	appId="211349_W6dq6zuo0PkZ690LWdTPQYzq2IXd7qKp";
	appSecret="4bc1fc34ae474d53a46bdd26d01f3bbc";
	DBId=this.Context.DBId;
	user= this.Context.UserName;
	loginFlag=0;
	if str(loginFlag) == "0":
		loginFlag=1;
		client=K3CloudApiClient(url);
		loginResult=client.LoginByAppSecret(DBId,user,appId,appSecret,2052);
		loginResultObj=JObject.Parse(loginResult);
		iResult=("{0}").format(loginResultObj["LoginResultType"]);
		if (iResult == "1"):
			jg = client.BatchSave("wjdz_mbdyjl",gxjson.ToString());
			fhjg = JsonConvert.DeserializeObject(jg);  #返回信息变成josn
			if fhjg["Result"]["ResponseStatus"]["IsSuccess"].ToString() == "False":
				this.View.ShowErrMessage(JsonConvert.SerializeObject(fhjg["Result"]["ResponseStatus"]["Errors"]));
	#this.View.ShowMessage(gxjson.ToString());

```

