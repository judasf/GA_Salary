<%@ WebHandler Language="C#" Class="UserInfo" %>

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
/// 用户信息操作
/// </summary>
public class UserInfo : IHttpHandler, IRequiresSessionState
{
    HttpRequest Request;
    HttpResponse Response;
    HttpSessionState Session;
    HttpServerUtility Server;
    HttpCookie Cookie;
    /// <summary>
    /// 当前登陆用户名
    /// </summary>
    string thisUserName;
    /// <summary>
    /// 登录用户部门编号
    /// </summary>
    int DeptID;
    /// <summary>
    /// 登录角色
    /// </summary>
    int RoleID;
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
            DeptID = ud.LoginUser.DeptId;
            RoleID = ud.LoginUser.RoleId;
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
    /// 设置用户管理查询条件
    /// </summary>
    /// <returns></returns>
    public string SetQueryConditionForUserInfo()
    {
        string queryStr = "";
        //设置查询条件
        List<string> list = new List<string>();
        if (!string.IsNullOrEmpty(Request.Form["userName"]))
            list.Add(" userName like'%" + Request.Form["userName"] + "%'");
        if (!string.IsNullOrEmpty(Request.Form["realName"]))
            list.Add(" realName like'%" + Request.Form["realName"] + "%'");
        if (!string.IsNullOrEmpty(Request.Form["roleId"]))
            list.Add(" a.roleId =" + Request.Form["roleId"]);
        if (!string.IsNullOrEmpty(Request.Form["deptId"]))
            list.Add(" a.deptId =" + Request.Form["deptId"]);
        //部门管理员只显示本部门人员
        if (RoleID == 2)
            list.Add(" a.deptid= " + DeptID.ToString());
        //不显示工资管理员和人事管理员
        list.Add(" a.roleid<>1");
        list.Add(" a.roleid<>3");

        if (list.Count > 0)
            queryStr = string.Join(" and ", list.ToArray());
        return queryStr;
    }
    /// <summary>
    /// 获取UserInfo 数据page:1 rows:10 sort:id order:asc
    /// </summary>
    public void GetUserInfo()
    {
        int total = 0;
        string where = SetQueryConditionForUserInfo();
        string tableName = "empinfo a  left join roleinfo b on a.roleid=b.roleid  left join department c on a.deptid=c.deptid";
        string fieldStr = "UID,UserName,realname,deptname,RoleName,a.RoleID,c.deptid";
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
    /// 通过uId获取UserInfo信息
    /// </summary>
    public void GetUserInfoByID()
    {
        int uid = Convert.ToInt32(Request.Form["UID"]);
        SqlParameter paras = new SqlParameter("@id", SqlDbType.Int);
        paras.Value = uid;
        string sql = "SELECT UID,UserName,realname,deptname,RoleName,a.RoleID,c.deptid FROM empinfo a  left join roleinfo b on a.roleid=b.roleid  left join department c on a.deptid=c.deptid WHERE UID=@id";
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        Response.Write(JsonConvert.GetJsonFromDataTable(ds));
    }
    /// <summary>
    /// 保存UserInfo信息
    /// </summary>
    public void SaveUserInfo()
    {
        string userName = Convert.ToString(Request.Form["userName"]);
        string realName = Convert.ToString(Request.Form["realName"]);
        int roleId = Convert.ToInt32(Request.Form["roleId"]);
        int deptId = Convert.ToInt32(Request.Form["deptId"]);
        //string userPwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile("888888", "MD5");
        string userPwd = "123456";
        SqlParameter[] paras = new SqlParameter[] {
            new SqlParameter("@userName",SqlDbType.NVarChar),
            new SqlParameter("@roleId",SqlDbType.Int),
            new SqlParameter("@deptId",SqlDbType.Int),
            new SqlParameter("@userPwd",SqlDbType.NVarChar),
            new SqlParameter("@realName",SqlDbType.NVarChar)
        };
        paras[0].Value = userName;
        paras[1].Value = roleId;
        paras[2].Value = deptId;
        paras[3].Value = userPwd;
        paras[4].Value = realName;
        //判断身份证号是否存在
        StringBuilder sql = new StringBuilder("if not exists(select * from empinfo where username=@userName)");
        sql.Append(" INSERT INTO empinfo values(@userName,@userPwd,@realName,@roleId,@deptId); ");
        /*
        StringBuilder sql = new StringBuilder("if not exists(select * from userinfo where username=@userName)");
        sql.Append(" begin ");
        sql.Append(" if not exists(select * from empinfo where username=@username) ");
        sql.Append(" begin ");
        //登录表信息不存在，新增登录信息和用户信息
        sql.Append(" INSERT INTO UserInfo VALUES(@userName,@realName,@deptId,@roleId); ");
        sql.Append(" INSERT INTO empinfo values(@userName,@userPwd,@roleId); ");
        sql.Append(" end  else  begin ");
        //登录表信息存在，更新登录信息和新增用户信息
        sql.Append(" INSERT INTO UserInfo VALUES(@userName,@realName,@deptId,@roleId); ");
        sql.Append("  Update empinfo set roleid=@roleId where username = @userName ");
        sql.Append(" end ");

        sql.Append(" end ");
        */
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql.ToString(), paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"该身份证号已存在！\"}");
    }
    /// <summary>
    /// 更新用户信息
    /// </summary>
    public void UpdateUserInfo()
    {
        int uid = Convert.ToInt32(Request.Form["uid"]);
        string userName = Convert.ToString(Request.Form["userName"]);
        string realName = Convert.ToString(Request.Form["realName"]);
        int roleId = Convert.ToInt32(Request.Form["roleId"]);
        int deptId = Convert.ToInt32(Request.Form["deptId"]);
        SqlParameter[] paras = new SqlParameter[] {
            new SqlParameter("@uid",SqlDbType.Int),
            new SqlParameter("@userName",SqlDbType.NVarChar),
            new SqlParameter("@realName",SqlDbType.NVarChar),
            new SqlParameter("@roleId",SqlDbType.Int),
            new SqlParameter("@deptId",SqlDbType.Int)
        };
        paras[0].Value = uid;
        paras[1].Value = userName;
        paras[2].Value = realName;
        paras[3].Value = roleId;
        paras[4].Value = deptId;

        string sql = "UPDATE empinfo set roleid=@roleId,deptid=@deptId,realname=@realName  where username=@userName;";
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"执行错误\"}");
    }
    /// <summary>
    /// 通过uid获取删除UserInfo信息
    /// </summary>
    public void RemoveUserInfoByID()
    {
        int uid = 0;
        int.TryParse(Request.Form["uid"], out uid);

        SqlParameter paras = new SqlParameter("@id", SqlDbType.Int);
        paras.Value = uid;
        string sql = "DELETE FROM empinfo WHERE uid=@id";
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"执行出错\"}");
    }
    /// <summary>
    /// 通过uid恢复用户密码
    /// </summary>
    public void ResetPwdByID()
    {
        int uid = 0;
        int.TryParse(Request.Form["uid"], out uid);
        string userPwd = "123456";
        //string userPwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile("888888", "MD5");
        SqlParameter[] paras = new SqlParameter[]{
            new SqlParameter("@id", SqlDbType.Int),
            new SqlParameter("@userPwd", SqlDbType.VarChar)
        };
        paras[0].Value = uid;
        paras[1].Value = userPwd;
        string sql = "update empinfo set UserPwd=@userPwd WHERE uid=@id";
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"执行出错\"}");
    }
    /// <summary>
    /// 修改密码
    /// </summary>
    public void EditPasswd()
    {
        int uid = 0;
        int.TryParse(Request.Form["uid"], out uid);
        //string oldPwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Convert.ToString(Request.Form["oldPwd"]), "MD5");
        //string pwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Convert.ToString(Request.Form["pwd"]), "MD5");
        //string rePwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Convert.ToString(Request.Form["rePwd"]), "MD5");
        string oldPwd = Request.Form["oldPwd"];
        string pwd = Request.Form["pwd"];
        string rePwd = Request.Form["rePwd"];
        if (pwd != rePwd)
        {
            Response.Write("{\"success\":false,\"msg\":\"两次密码输入不一致！\"}");
            return;
        }
        SqlParameter[] paras = new SqlParameter[] {
            new SqlParameter("@uid",SqlDbType.Int),
            new SqlParameter("@oldPwd",SqlDbType.VarChar),
            new SqlParameter("@pwd",SqlDbType.NVarChar)
        };
        paras[0].Value = uid;
        paras[1].Value = oldPwd;
        paras[2].Value = pwd;
        StringBuilder sql = new StringBuilder();
        sql.Append("if exists(select * from empinfo  where uid=@uid and userpwd=@oldPwd)");
        sql.Append("update empinfo set userpwd=@pwd where uid =@uid");
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql.ToString(), paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"修改成功！\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"原密码不正确！\"}");

    }
    /// <summary>
    /// 导出用户信息
    /// </summary>
    public void ExportUserInfo()
    {
        string where = SetQueryConditionForUserInfo();
        if (where != "")
            where = " where " + where;
        StringBuilder sql = new StringBuilder();
        sql.Append("select uid,RoleName,UserName ");
        sql.Append(" from userinfo a join roleinfo b on a.roleid=b.roleid  ");
        sql.Append(where);
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql.ToString());
        DataTable dt = ds.Tables[0];
        dt.Columns[0].ColumnName = "用户编号";
        dt.Columns[1].ColumnName = "角色名称";
        dt.Columns[2].ColumnName = "用户名";
        MyXls.CreateXls(dt, "用户信息表.xls", "");
        Response.Flush();
        Response.End();
    }
    /// <summary>
    /// 批量设置人员部门
    /// </summary>
    public void SetUserDepartment()
    {
        string ids = Convert.ToString(Request.Form["ids"]);
        string deptid = Convert.ToString(Request.Form["deptId"]);
        if (ids.Length == 0)
        {
            Response.Write("{\"success\":false,\"msg\":\"未选择人员！\"}");
            return;
        }
        string[] arrId = ids.Split(new char[] { ',' });
        StringBuilder sql = new StringBuilder();
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@deptid", deptid));
        int i = 0;
        foreach (string id in arrId)
        {
            paras.Add(new SqlParameter("@id" + i.ToString(), id));
            sql.Append("Update  empinfo set deptid=@deptid WHERE uid=@id" + i.ToString() + ";");
            i++;
        }
        //使用事务提交操作
        using (SqlConnection conn = SqlHelper.GetConnection())
        {
            conn.Open();
            using (SqlTransaction trans = conn.BeginTransaction())
            {
                try
                {
                    SqlHelper.ExecuteNonQuery(trans, CommandType.Text, sql.ToString(), paras.ToArray());
                    trans.Commit();
                    Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
                }
                catch
                {
                    trans.Rollback();
                    Response.Write("{\"success\":false,\"msg\":\"执行出错\"}");
                    throw;
                }
            }
        }
    }
    /// <summary>
    /// 人事调动
    /// </summary>
    public void UserTransfer()
    {
        string userName = Convert.ToString(Request.Form["userName"]);
        string realName = Convert.ToString(Request.Form["realName"]);
        string deptName = Convert.ToString(Request.Form["deptName"]);
        int deptId = Convert.ToInt32(Request.Form["deptId"]);
        SqlParameter[] paras = new SqlParameter[] {
            new SqlParameter("@userName",SqlDbType.NVarChar),
            new SqlParameter("@deptId",SqlDbType.Int),
            new SqlParameter("@realName",SqlDbType.NVarChar),
            new SqlParameter("@deptName",SqlDbType.NVarChar),
            new SqlParameter("@applyDate",SqlDbType.NVarChar),
            new SqlParameter("@applyUser",SqlDbType.NVarChar),
        };
        paras[0].Value = userName;
        paras[1].Value = deptId;
        paras[2].Value = realName;
        paras[3].Value = deptName;
        paras[4].Value = DateTime.Now.ToString("yyyy-MM-dd");
        //获得登录用户姓名
        paras[5].Value = SqlHelper.ExecuteScalar(SqlHelper.GetConnection(), CommandType.Text, "Select realname from empinfo where username=@username", new SqlParameter("@username", thisUserName)).ToString();

        string sql = " INSERT INTO UserTransfer values(@applyDate,@userName,@realName,@deptName,@deptId,@applyUser,0)";
        int result = SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.Text, sql.ToString(), paras);
        if (result == 1)
            Response.Write("{\"success\":true,\"msg\":\"执行成功\"}");
        else
            Response.Write("{\"success\":false,\"msg\":\"执行失败！\"}");
    }
}