<%@ WebHandler Language="C#" Class="uploadify" %>

using System;
using System.Web;
using System.IO;
using System.Web.SessionState;
using System.Reflection;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
/// <summary>
/// uploadify插件处理页面
/// </summary>
public class uploadify : IHttpHandler, IRequiresSessionState
{
    HttpRequest Request;
    HttpResponse Response;
    HttpSessionState Session;
    HttpServerUtility Server;
    HttpCookie Cookie;
    public void ProcessRequest(HttpContext context)
    {
        //不让浏览器缓存
        context.Response.Buffer = true;
        context.Response.ExpiresAbsolute = DateTime.Now.AddDays(-1);
        context.Response.AddHeader("pragma", "no-cache");
        context.Response.AddHeader("cache-control", "");
        context.Response.CacheControl = "no-cache";
        context.Response.ContentType = "text/plain";
        context.Response.Charset = "utf-8";

        Request = context.Request;
        Response = context.Response;
        Session = context.Session;
        Server = context.Server;
        //判断登陆状态
        if(!Request.IsAuthenticated)
        {
            Response.Write("{\"success\":false,\"msg\":\"登陆超时，请重新登陆后再进行操作！\"}");
            Response.End();
            return;
        }
        //上传保存的根目录
        string rootFloder = Request.Form["floderName"];
        ////保存文件夹
        //string floderName = rootFloder+@"\upfiles\" + DateTime.Now.ToString("yyyyMMdd") + @"\";
        //文件夹路径
        string floderPath = Server.MapPath("~") + rootFloder + @"\upfiles\";
        //上传的文件
        HttpPostedFile file = context.Request.Files["Filedata"];
        //文件扩展名
        string fileExtension = Path.GetExtension(file.FileName);
        //不带后缀的文件名
        string fileNameWithOutExtension = Path.GetFileNameWithoutExtension(file.FileName);
        //新文件名
        string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss")+"_"+fileNameWithOutExtension;
        //给新文件名加扩展名
        newFileName += fileExtension;
        //上传的文件路径
        string filePath = floderPath + newFileName;
        //文件相对路径
        string retrunFilePath = rootFloder+"/upfiles/"+ newFileName;
        if(file != null)
        {
            if(!Directory.Exists(floderPath))
            {
                Directory.CreateDirectory(floderPath);
            }
            if(fileExtension != ".xls")
            {
                Response.Write("{\"success\":false,\"msg\":\"文件格式不正确，请选择正确的excel文件！\"}");
                return;
            }
            if(File.Exists(filePath))
            {
                File.Delete(filePath);
            }
            //保存文件
            file.SaveAs(filePath);
            Response.Write("{\"success\":true,\"msg\":\"上传成功！\",\"filepath\":\"" + retrunFilePath + "\"}");

        }
        else
        {
            Response.Write("{\"success\":false,\"msg\":\"上传失败，上传文件不存在！\"}");
        }
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}