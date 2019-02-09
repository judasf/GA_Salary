﻿<%@ WebHandler Language="C#" Class="salary" %>

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
/// 工资管理
/// </summary>
public class salary : IHttpHandler, IRequiresSessionState
{
    HttpRequest Request;
    HttpResponse Response;
    HttpSessionState Session;
    HttpServerUtility Server;
    HttpCookie Cookie;


    /// <summary>
    /// 当前登陆用户名
    /// </summary>
    string userName;
    /// <summary>
    /// 部门编号
    /// </summary>
    int deptId;
    /// <summary>
    /// 角色编号
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
            userName = ud.LoginUser.UserName;
            deptId = ud.LoginUser.DeptId;
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
    /// 获取工资信息
    /// </summary>
    public void GetSalary()
    {
        string sdate = Convert.ToString(Request.Form["sdate"]);
        if (sdate.Length != 7)
        {
            Response.Write("{\"success\":false,\"msg\":\"工资月份有误！\"}");
            return;
        }
        string tbname = "salaryinfo" + sdate.Replace("-", "");
        //判断当月工资表是否存在
        DataSet dsshow = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, "SELECT * FROM sysobjects where name = '" + tbname + "' AND type = 'U'");
        if (dsshow.Tables[0].Rows.Count == 0)
        {
            Response.Write("{\"total\":0,\"msg\":\"无数据！\"}");
            return;
        }
        string where = "";
        if (roleid == 0 || roleid ==2)
            where = " where [身份证号码]='" + userName + "'";
        string sql = "select * from " + tbname + where;
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql);
        Response.Write(JsonConvert.GetJsonFromDataTable(ds, ds.Tables[0].Rows.Count, true));
    }
    /// <summary>
    /// 个人工资导出
    /// </summary>
    public void ExportSalaryDetail()
    {
        string sdate = Convert.ToString(Request.Form["sdate"]);
        if (sdate.Length != 7)
        {
            Response.Write("{\"success\":false,\"msg\":\"工资月份有误！\"}");
            return;
        }
        string tbname = "salaryinfo" + sdate.Replace("-", "");
        //判断当月工资表是否存在
        DataSet dsshow = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, "SELECT * FROM sysobjects where name = '" + tbname + "' AND type = 'U'");
        if (dsshow.Tables[0].Rows.Count == 0)
        {
            Response.Write("{\"total\":0,\"msg\":\"无数据！\"}");
            return;
        }
         string where = "";
        if (roleid == 0 || roleid ==2)
            where = " where [身份证号码]='" + userName + "'";
        string sql = "select * from " + tbname + where;
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql.ToString());
        DataTable dt = ds.Tables[0];
        MyXls.CreateXls(dt, sdate + "工资明细.xls", "1,3");
        Response.Flush();
        Response.End();
    }
    /// <summary>
    /// 导入上传的明细
    /// </summary>
    public void ImportResourcesInfo()
    {
        string reportPath = "";
        string smonth = Convert.ToString(Request.Form["smonth"]);
        if (smonth.Length != 7)
        {
            Response.Write("{\"success\":false,\"msg\":\"工资月份有误！\"}");
            return;
        }
        string tbname = "salaryinfo" + smonth.Replace("-", "");
        //判断当月工资表是否存在
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, "SELECT * FROM sysobjects where name = '" + tbname + "' AND type = 'U'");
        if (ds.Tables[0].Rows.Count == 1)
        {
            Response.Write("{\"success\":false,\"msg\":\"当月工资表已导入！\"}");
            return;
        }
        if (!string.IsNullOrEmpty(Request.Form["report"]))
            reportPath = Server.MapPath("~") + Request.Form["report"].ToString();
        int checkFile = MyXls.ChkSheet(reportPath, "A");
        if (checkFile == -1)
        {
            Response.Write("{\"success\":false,\"msg\":\"上传文件不存在，请检查！\"}");
            return;
        }
        if (checkFile == 0)
        {
            Response.Write("{\"success\":false,\"msg\":\"请检查excel文件中单元表的名字是否为A！\"}");
            return;
        }
        //验证要导入的列在单元表中是否存在
        List<string> columnsName = new List<string>();
        columnsName.Add("身份证号码");
        List<int> columnsExists = MyXls.ChkSheetColumns(reportPath, "A", columnsName);
        if (columnsExists.Contains(0))
        {
            Response.Write("{\"success\":false,\"msg\":\"请检查excel文件内容格式是否正确！\"}");
            return;
        }
        SqlParameter[] paras = new SqlParameter[]{
            new SqlParameter("@filePath",reportPath),
            new SqlParameter("@tableName",tbname)
        };
        SqlHelper.ExecuteNonQuery(SqlHelper.GetConnection(), CommandType.StoredProcedure, "dbo.ImportSalaryFromExcel", paras);
        Response.Write("{\"success\":true,\"msg\":\"数据导入成功！\"}");
    }
    #region 部门管理员操作
    /// <summary>
    /// 获取部门工资信息
    /// </summary>
    public void GetDeptSalary()
    {
        string sdate = Convert.ToString(Request.Form["sdate"]);
        if (sdate.Length != 7)
        {
            Response.Write("{\"success\":false,\"msg\":\"工资月份有误！\"}");
            return;
        }
        string tbname = "salaryinfo" + sdate.Replace("-", "");
        //判断当月工资表是否存在
        DataSet dsshow = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, "SELECT * FROM sysobjects where name = '" + tbname + "' AND type = 'U'");
        if (dsshow.Tables[0].Rows.Count == 0)
        {
            Response.Write("{\"total\":0,\"msg\":\"无数据！\"}");
            return;
        }
        string sql = "select c.deptname as [部门名称],b.* FROM dbo.empinfo  a  LEFT JOIN   " + tbname + " b ON a.username=b.身份证号码 LEFT JOIN dbo.Department c ON a.deptid=c.DeptID WHERE a.deptid=" + deptId;
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql);
        Response.Write(JsonConvert.GetJsonFromDataTable(ds, ds.Tables[0].Rows.Count, true));
    }
    /// <summary>
    /// 部门管理员工资导出
    /// </summary>
    public void ExportDeptSalaryDetail()
    {
        string sdate = Convert.ToString(Request.Form["sdate"]);
        if (sdate.Length != 7)
        {
            Response.Write("{\"success\":false,\"msg\":\"工资月份有误！\"}");
            return;
        }
        string tbname = "salaryinfo" + sdate.Replace("-", "");
        //判断当月工资表是否存在
        DataSet dsshow = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, "SELECT * FROM sysobjects where name = '" + tbname + "' AND type = 'U'");
        if (dsshow.Tables[0].Rows.Count == 0)
        {
            Response.Write("{\"total\":0,\"msg\":\"无数据！\"}");
            return;
        }
        string sql = "select c.deptname as [部门名称],b.* FROM dbo.empinfo  a  LEFT JOIN   " + tbname + " b ON a.username=b.身份证号码 LEFT JOIN dbo.Department c ON a.deptid=c.DeptID WHERE a.deptid=" + deptId;
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql.ToString());
        DataTable dt = ds.Tables[0];
        MyXls.CreateXls(dt, sdate + "部门工资明细.xls", "2,4");
        Response.Flush();
        Response.End();
    }
    #endregion

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}