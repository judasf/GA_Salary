<%@ WebHandler Language="C#" Class="UserTransfer" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Reflection;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
/// <summary>
/// 人事调动操作
/// </summary>
public class UserTransfer : IHttpHandler, IRequiresSessionState
{
    HttpRequest Request;
    HttpResponse Response;
    HttpSessionState Session;
    HttpServerUtility Server;
    HttpCookie Cookie;
    /// <summary>
    /// 当前登陆身份证号
    /// </summary>
    string thisUserName;
    /// <summary>
    /// 登录用户姓名
    /// </summary>
    string RealName;
    /// <summary>
    /// 登录用户roleid
    /// </summary>
    int roleid;
    public void ProcessRequest(HttpContext context)
    {
        //不让浏览器缓存
        context.Response.Buffer = true;
        context.Response.ExpiresAbsolute = DateTime.Now.AddDays(-1);
        context.Response.AddHeader("pragma", "no-cache");
        context.Response.AddHeader("cache-control", "");
        context.Response.CacheControl = "no-cache";
        context.Response.ContentType = "text/plain";

        Request = context.Request;
        Response = context.Response;
        Session = context.Session;
        Server = context.Server;
        //判断登陆状态
        if (!Request.IsAuthenticated)
        {
            Response.Write("{\"success\":false,\"msg\":\"登陆超时，请重新登陆后再进行操作！\",\"total\":-1,\"rows\":[]}");
            return;
        }
        else
        {
            UserDetail ud = new UserDetail();
            thisUserName = ud.LoginUser.UserName;
            RealName = SqlHelper.ExecuteScalar(SqlHelper.GetConnection(), CommandType.Text, "Select realname from empinfo where username='" + thisUserName + "'").ToString();
            roleid = ud.LoginUser.RoleId;
        }
        string method = HttpContext.Current.Request.PathInfo.Substring(1);
        if (method.Length != 0)
        {
            MethodInfo methodInfo = this.GetType().GetMethod(method);
            if (methodInfo != null)
            {
                methodInfo.Invoke(this, null);
            }
            else
                Response.Write("{\"success\":false,\"msg\":\"Method Not Matched !\"}");
        }
        else
        {
            Response.Write("{\"success\":false,\"msg\":\"Method not Found !\"}");
        }
    }
    /// <summary>
    /// 设置人事调动查询条件
    /// </summary>
    /// <returns></returns>
    public string SetQueryConditionForUserTransfer()
    {
        string queryStr = "";
        //设置查询条件
        List<string> list = new List<string>();
        //按身份证
        if (!string.IsNullOrEmpty(Request.Form["userName"]))
            list.Add(" userName like'%" + Request.Form["userName"] + "%'");
        //按姓名
        if (!string.IsNullOrEmpty(Request.Form["realName"]))
            list.Add(" realName like'%" + Request.Form["realName"] + "%'");
        //按进度
        if (!string.IsNullOrEmpty(Request.Form["status"]))
            list.Add(" status =" + Request.Form["status"]);
        //部门管理员只看自己申请
        if (roleid == 2)
            list.Add(" applyuser='" + RealName + "' ");
        if (list.Count > 0)
            queryStr = string.Join(" and ", list.ToArray());
        return queryStr;
    }
    /// <summary>
    /// 获取UserTransfer 数据page:1 rows:10 sort:id order:asc
    /// </summary>
    public void GetUserTransfer()
    {
        int total = 0;
        string where = SetQueryConditionForUserTransfer();
        string tableName = " usertransfer a left join department b on a.newdeptid=b.deptid ";
        string fieldStr = "a.*,b.deptname as newdept";
        DataSet ds = SqlHelper.GetPagination(tableName, fieldStr, Request.Form["sort"].ToString(), Request.Form["order"].ToString(), where, Convert.ToInt32(Request.Form["rows"]), Convert.ToInt32(Request.Form["page"]), out total);
        Response.Write(JsonConvert.GetJsonFromDataTable(ds, total));
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    /// <summary>
    /// 通过id获取UserTransfer信息
    /// </summary>
    public void GetUserTransferByID()
    {
        int id = Convert.ToInt32(Request.Form["id"]);
        SqlParameter paras = new SqlParameter("@id", SqlDbType.Int);
        paras.Value = id;
        string sql = "SELECT * from usertransfer WHERE id=@id";
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        Response.Write(JsonConvert.GetJsonFromDataTable(ds));
    }

    /// <summary>
    /// 调动审核
    /// </summary>
    public void AuditUserTransferByID()
    {
        int id = 0;
        int.TryParse(Request.Form["id"], out id);
        string deptid = "";
        string username = "";
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, "Select username,newdeptid from UserTransfer where id =@id", new SqlParameter("@id", id));
        if (ds.Tables[0].Rows.Count == 1)
        {
            username = ds.Tables[0].Rows[0][0].ToString();
            deptid = ds.Tables[0].Rows[0][1].ToString();
        }
        SqlParameter[] paras = new SqlParameter[] {
        new SqlParameter("@id",id),
        new SqlParameter("@username",username),
        new SqlParameter("@deptid", deptid) };
        string sql = "Update empinfo set deptid=@deptid where username=@username;";
        sql += "update UserTransfer set status=1 where id=@id;";
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        if (result == 2)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"执行出错\"}");
    }
    /// <summary>
    /// 通过id获取删除UserTransfer信息
    /// </summary>
    public void RemoveUserTransferByID()
    {
        int id = 0;
        int.TryParse(Request.Form["id"], out id);

        SqlParameter paras = new SqlParameter("@id", SqlDbType.Int);
        paras.Value = id;
        string sql = "DELETE FROM UserTransfer WHERE id=@id";
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"执行出错\"}");
    }
}