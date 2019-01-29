<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>工资管理系统</title>
    <%-- <link href="css/Style.css" rel="stylesheet" type="text/css" />--%>
    <script src="js/easyui/jquery-1.10.2.min.js" type="text/javascript"></script>
    <script src="js/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <link href="js/easyui/themes/default/easyui.css" rel="stylesheet" type="text/css" />
    <link href="js/easyui/themes/icon.css" rel="stylesheet" type="text/css" />
    <script src="js/easyui/locale/easyui-lang-zh_CN.js" type="text/javascript"></script>
    <script src="js/extJquery.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/login.js"></script>
    <script type="text/javascript">
        var loginFun = function () {
            var $form = $('#form1');
            if ($form.form('validate')) {
                login_loading($("#loginBtn")[0]);
                $.post('service/commondb.ashx/login', $.serializeObject($form), function (result) {
                    if (result.success) {
                        location.replace('index.aspx')
                    }
                    else {
                        $.messager.alert('提示', result.msg, 'error');
                        login_loaded();
                    }
                }, 'json')
            }
        }
        $(function () {
            $('#form1').keydown(function (event) {
                if (event.which == 13) {
                    loginFun();
                }
            });
        });
    </script>
    <style type="text/css">
        body { margin: 0 auto; margin: 0 auto !important; *margin: 0 auto; padding: 0 auto; padding: 0 auto !important; *padding: 0 auto; text-align: center; text-align: center !important; *text-align: center; background: #005a87; font-family: "宋体"; }
        from { margin: 0; margin: 0 !important; *margin: 0; padding: 0; padding: 0 !important; *padding: 0; }
        .STYLE6 { COLOR: #ffffff; }
        .STYLE7 { color: #FFFFFF; font-size: 32px; top: auto; font-family: "宋体"; }
        .tishi { font-family: "宋体"; }
        .STYLE8 { font-size: 36px; }
        .search_btn{cursor:pointer;}
        td { padding: 0; }
        .user { background: url(images/txtBg.gif) repeat-x left top; border: 1px solid #417bc9; font-family: "Arial"; font-size: 12px; height: 19px; padding-top: 1px; width: 178px; }

    </style>
</head>
<body style="margin: 0; padding: 0; background-color: #417bc9;">
    <form id="form1">
        <div style="text-align: center; padding: 140px; margin: 20px; border: 1px solid #417bc9; background-color: #417bc9; height: 300px;">
            <div class="STYLE7 STYLE8" style="text-align: center; top: 0px; height: 100px;">
                <span style="font-size: 50px">安阳市公安局工资查询系统</span>
            </div>
            <div style="width: 432px; margin: 0 auto;">
                <table width="432" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <th height="26" colspan="2" background="images/Login_Top.gif" class="STYLE6" scope="col">系统登陆</th>
                    </tr>
                    <tr>
                        <td bgcolor="#C4D0E1">
                            <label for="bottom">
                                <img src="images/Login_TT.png" width="150" height="148" hspace="10" vspace="10"></label></td>
                        <td background="images/Login_BG.gif">
                            <table height="148" border="0" cellpadding="0" cellspacing="0" width="257">
                                <tr>
                                    <td width="88">身份证号
                                    </td>
                                    <td style="text-align: left;">
                                        <input name="userName" class="easyui-validatebox user" type="text" id="userName" style="width: 150px;" data-options="required:true"/></td>
                                </tr>
                                <tr>
                                    <td>密&nbsp;&nbsp;&nbsp;&nbsp;码</td>
                                    <td style="text-align: left;">
                                        <input name="userPwd" type="password" id="userPwd" style="width: 150px;" class="easyui-validatebox user" data-options="required:true"/>


                                    </td>

                                </tr>
                                <tr>
                                    <td colspan="2" style="font-size: 12px;">密码:123456 登陆后不允许修改密码</td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td style="text-align: left;">
                                        <input type="button" id="loginBtn" class="search_btn" onclick="loginFun();" name="Submit" value="登 录" />
                                        <input type="reset" name="reset" class="search_btn" value="清 空"/></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="36" colspan="2" align="center" background="../images/Login_Down.gif" class="STYLE6" scope="col">客服热线:18503722071 5129660</td>
                    </tr>
                </table>
            </div>
        </div>

    </form>
</body>
</html>
