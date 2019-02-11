<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>工资管理系统</title>
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <%--引入My97日期文件--%>
    <script src="js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>
    <%--引入Jquery文件--%>
    <script src="js/easyui/jquery-1.10.2.min.js" type="text/javascript"></script>
    <script src="js/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <%--引入easyui文件--%>
    <link href="js/easyui/themes/default/easyui.css" rel="stylesheet" type="text/css" />
    <link href="js/easyui/themes/icon.css" rel="stylesheet" type="text/css" />
    <link href="css/extEasyUIIcon.css" rel="stylesheet" type="text/css" />
    <script src="js/easyui/locale/easyui-lang-zh_CN.js" type="text/javascript"></script>
    <script src="js/extJquery.js" type="text/javascript"></script>
    <script src="js/extEasyUI.js" type="text/javascript"></script>
    <%--引入uploadify文件--%>
    <link rel="stylesheet" type="text/css" href="js/uploadify/uploadify.css" />
    <script type="text/javascript" src="js/uploadify/jquery.uploadify.js"></script>
    <%  int roleid = 99;
        string userName = "";
        if (!Request.IsAuthenticated)
        {%>
    <script type="text/javascript">
        parent.$.messager.alert('提示', '登陆超时，请重新登陆再进行操作！', 'error', function () {
            parent.location.replace('index.aspx');
        });
    </script>
    <%}
        else
        {
            UserDetail ud = new UserDetail();
            roleid = ud.LoginUser.RoleId;
            userName = ud.LoginUser.UserName;
    %>
    <script type="text/javascript">
        var roleid = '<%=roleid%>';
        var userName = '<%=userName%>';
    </script>
    <%} %>
    <script type="text/javascript">
        //退出登录
        var logOut = function () {
            $.ajax({
                type: "post",
                dataType: "json",
                url: "service/commondb.ashx/LogOut"
            }).done(function (result) {
                if (result.success) {
                    location.replace('default.aspx');
                }
            });
        };
        //修改密码
        var editCurrentUserPwd = function () {
            var dialog = parent.$.modalDialog({
                title: '修改密码',
                width: 340,
                height: 250,
                href: 'BaseInfo/DialogOP/UserPwd_OP.aspx',
                buttons: [{
                    text: '修改',
                    handler: function () {
                        parent.onFormSubmit(dialog);
                    }
                },
                {
                    text: '取消',
                    handler: function () {
                        dialog.dialog('close');
                    }
                }]
            });
        };
    </script>
</head>
<body class="easyui-layout">
    <div data-options="region:'north',fit:false,border:false" style="overflow: hidden">

        <div class="header">
            安阳市公安局工资查询系统
        </div>
        <div class="top">
            <ul style="float: left;">
                <%if (roleid == 0)//员工
                    { %>
                <li class="current"><a href="SalaryInfo.aspx" target="mainfrm">工资查询</a></li>
                <%} %>
                <%if (roleid == 3)//人事管理员
                    { %>
                <li class="current"><a href="BaseInfo/UserInfo.aspx" target="mainfrm">用户管理</a></li>
                <li><a href="BaseInfo/Department.aspx" target="mainfrm">部门管理</a></li>
                <li><a href="BaseInfo/UserTransfer.aspx" target="mainfrm">人事调动</a></li>
                <%} %>
                <%if (roleid == 2)//部门管理员
                    { %>
                <li class="current"><a href="DeptMana/Dept_SalaryInfo.aspx" target="mainfrm">部门工资</a></li>
                <li><a href="DeptMana/Dept_UserInfo.aspx" target="mainfrm">部门人员</a></li>
                <li><a href="BaseInfo/UserTransfer.aspx" target="mainfrm">人事调动</a></li>
                <%}
                    if (roleid == 1)//工资管理员
                    { %>
                  <li class="current"><a href="SalaryTableInfo.aspx" target="mainfrm">工资导入</a></li>
                <%} %>
                <li class="clearboth"></li>
            </ul>
            <span style="float: right; padding-right: 20px; font-size: 14px; line-height: 36px; color: #fff;">[<%=userName%>]，欢迎您！ <a href="javascript:void(0);" onclick="editCurrentUserPwd();">[修改密码]</a> <a
                href="javascript:void(0);" onclick="logOut();">[安全退出]</a> </span>
        </div>
        <div class="clearboth"></div>
    </div>
    <div data-options="region:'center',fit:true,border:false">
        <%if (roleid == 3)//人事管理
            { %>
        <iframe name="mainfrm" src="BaseInfo/UserInfo.aspx" frameborder="0" style="border: 0; width: 100%; height: 88%;"></iframe>
        <%}
    else if (roleid == 0)//员工
    { %>
        <iframe name="mainfrm" src="SalaryInfo.aspx" frameborder="0" style="border: 0; width: 100%; height: 88%;"></iframe>
        <%}
    else if (roleid == 2)//部门管理员
    { %>
          <iframe name="mainfrm" src="DeptMana/Dept_SalaryInfo.aspx" frameborder="0" style="border: 0; width: 100%; height: 88%;"></iframe>
        <%}
    else if (roleid == 1)//工资管理员
    { %>
         <iframe name="mainfrm" src="SalaryTableInfo.aspx" frameborder="0" style="border: 0; width: 100%; height: 88%;"></iframe>
        <%} %>
    </div>
    <script>
        $(".top").find("li").each(function () {
            $(this).css('width', '120px').click(function () {
                $(this).addClass('current').siblings().removeClass('current');
            });
        });
    </script>
</body>
</html>
