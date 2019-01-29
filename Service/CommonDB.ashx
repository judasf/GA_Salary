<%@ WebHandler Language="C#" Class="CommonDB" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Reflection;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
/// <summary>
/// 数据操作类
/// </summary>
public class CommonDB : IHttpHandler, IRequiresSessionState
{
    HttpRequest Request;
    HttpResponse Response;
    HttpSessionState Session;
    HttpServerUtility Server;
    //HttpCookie Cookie;
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
        string method = HttpContext.Current.Request.PathInfo.Substring(1);
        if(method.Length != 0)
        {
            MethodInfo methodInfo = this.GetType().GetMethod(method);
            if(methodInfo != null)
            {
                methodInfo.Invoke(this, null);
            }
            else
                Response.Write("{\"flag\":\"0\",\"msg\":\"method not match!\"}");
        }
        else
        {
            Response.Write("{\"flag\":\"0\",\"msg\":\"method not found!\"}");
        }
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    public void login()
    {
        string result = "";
        string userNum = Convert.ToString(Request.Form["userName"]);
        //string userPwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Convert.ToString(Request.Form["userPwd"]), "MD5");
        string userPwd = Convert.ToString(Request.Form["userPwd"]);
        SqlParameter[] paras = new SqlParameter[] {
           new SqlParameter("@username",userNum),
           new SqlParameter("@userpwd",userPwd)
       };
        string sql = "select * from empinfo  where  username=@username and userpwd=@userpwd";
        DataSet ds = SqlHelper.ExecuteDataset(SqlHelper.GetConnection(), CommandType.Text, sql, paras);
        if(ds.Tables[0].Rows.Count > 0)
        {
            DataRow row = ds.Tables[0].Rows[0];
            UserInfo user = new UserInfo();
            user.UID = Convert.ToInt32(row["uid"]);
            user.UserName = Convert.ToString(row["username"]);
            user.RoleId = Convert.ToInt32(row["RoleId"]);
            int deptid=0;
            int.TryParse(row["deptid"].ToString(),out deptid);
            user.DeptId = deptid;
            //user.RoleName = Convert.ToString(row["RoleName"]);
            // 1. 把需要保存的用户数据转成一个字符串。
            //josn格式序列化UserInfo类
            string userStr = Newtonsoft.Json.JsonConvert.SerializeObject(user);
            // 2. 创建一个FormsAuthenticationTicket，它包含登录名以及额外的用户数据。
            //设置Ticket信息
            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(2, user.UserName, DateTime.Now, DateTime.Now.AddDays(3), true, userStr);
            // 3. 加密Ticket，变成一个加密的字符串。加密验证票据
            string ticketStr = FormsAuthentication.Encrypt(ticket);
            // 4. 根据加密结果创建登录Cookie
            HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, ticketStr);
            cookie.HttpOnly = true;
            cookie.Secure = FormsAuthentication.RequireSSL;
            cookie.Domain = FormsAuthentication.CookieDomain;
            cookie.Path = FormsAuthentication.FormsCookiePath;
            cookie.Expires = ticket.Expiration;
            HttpContext context = HttpContext.Current;
            // 5. 写登录Cookie
            context.Response.Cookies.Remove(cookie.Name);
            context.Response.Cookies.Add(cookie);
            result = "{\"success\":true,\"msg\":\"登录成功！\"}";
        }
        else
            result = "{\"success\":false,\"msg\":\"账号或密码错误，请重新登陆！\"}";
        Response.Write(result);
    }
    /// <summary>
    ///退出登录 
    /// </summary>
    public void LogOut()
    {
        FormsAuthentication.SignOut();
        string result = "{\"success\":true,\"msg\":\"退出成功！\"}";
        Response.Write(result);
    }

}