<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Dept_UserInfo.aspx.cs" Inherits="BaseInfo_UserInfo" %>

<!DOCTYPE html>
<html>
<head>
    <title>用户管理</title>
    <script src="../js/easyui/jquery-1.10.2.min.js" type="text/javascript"></script>
    <script src="../js/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <link href="../css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../js/easyui/themes/default/easyui.css" rel="stylesheet" type="text/css" />
    <link href="../js/easyui/themes/icon.css" rel="stylesheet" type="text/css" />
    <link href="../css/extEasyUIIcon.css" rel="stylesheet" type="text/css" />
    <script src="../js/easyui/locale/easyui-lang-zh_CN.js" type="text/javascript"></script>
    <script src="../js/extJquery.js" type="text/javascript"></script>
    <%--管理员操作--%>
    <%  int roleid = 99;
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
    %>
    <script type="text/javascript">
        var roleid = '<%=roleid%>';
    </script>
    <%} %>
    <script type="text/javascript">
        var grid;
        var transferFun = function (id) {
            var dialog = parent.$.modalDialog({
                title: '人事调动',
                width: 340,
                height: 240,
                iconCls: 'icon-edit',
                href: 'baseinfo/dialogop/UserTransfer_OP.aspx?uid=' + id,
                buttons: [{
                    text: '提交',
                    handler: function () {
                        parent.onFormSubmit(dialog, grid);
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
        $(function () {
            grid = $('#grid').datagrid({
                title: '用户管理',
                url: '../service/UserInfo.ashx/GetUserInfo',
                striped: true,
                rownumbers: true,
                pagination: true,
                pageSize: 20,
                singleSelect: true,
                noheader: true,
                idField: 'uid',
                sortName: 'uid',
                sortOrder: 'desc',
                columns: [[{
                    width: '180',
                    title: '身份证号',
                    field: 'username',
                    sortable: true,
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '120',
                    title: '姓名',
                    field: 'realname',
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '120',
                    title: '部门名称',
                    field: 'deptname',
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '100',
                    title: '角色名',
                    field: 'rolename',
                    halign: 'center',
                    align: 'center'

                }, {
                    title: '操作',
                    field: 'action',
                    width: '70',
                    halign: 'center',
                    align: 'left',
                    formatter: function (value, row) {
                        var str = '';

                        str += $.formatString('<a href="javascript:void(0);" title="人事调动" onclick="transferFun(\'{0}\');">人事调动</a>', row.uid);
                        return str;
                    }
                }]],
                toolbar: '#toolbar',
                onLoadSuccess: function (data) {
                    parent.$.messager.progress('close');
                    if (!data.success && data.total == -1) {
                        parent.$.messager.alert('提示', '登陆超时，请重新登陆再进行操作！', 'error', function () {
                            parent.location.replace('index.aspx');
                        });
                    }
                    if (data.rows.length == 0) {
                        var body = $(this).data().datagrid.dc.body2;
                        body.find('table tbody').append('<tr><td width="' + body.width() + '" style="height: 25px; text-align: center;">没有数据</td></tr>');
                    }
                }
            });
            var pager = $('#grid').datagrid('getPager');
            pager.pagination({
                layout: ['list', 'sep', 'first', 'prev', 'sep', 'links', 'sep', 'next', 'last', 'sep', 'refresh', 'sep', 'manual']

            });
            //非管理员隐藏操作列
            if (roleid != 2)
                $('#grid').datagrid('hideColumn', 'action');
        });
    </script>
</head>
<body class="easyui-layout">
    <div id="toolbar">
        <table>
            <tr>
                <td>
                    <form id="searchForm" style="margin: 0;">
                        <table>
                            <tr>

                                <td style="width: 80px; text-align: right;">身份证号：
                                </td>
                                <td>
                                    <input name="userName" class="combo" style="width: 180px;" />
                                </td>
                                <td style="width: 80px; text-align: right;">姓名：
                                </td>
                                <td>
                                    <input name="realName" class="combo" style="width: 80px;" />
                                </td>
                                <td style="width: 80px; text-align: right;">部门名称：
                                </td>
                                <td>
                                <td class="tdinput">
                                    <input id="deptId" type="text" name="deptId" style="width: 100px;" class="easyui-combobox combo" data-options="required:true,valueField:'id',textField:'text',editable:false,panelHeight:'160',url:'../service/Department.ashx/GetAllDeptsCombobox'" />
                                </td>
                                <td style="width: 80px; text-align: right;">角色名称：
                                </td>
                                <td>
                                    <input name="roleId" style="width: 100px;" class="easyui-combobox" data-options="valueField:'id',textField:'text',editable:false, panelWidth: 100,panelHeight:'auto',url:'../service/RoleInfo.ashx/GetAllRoleInfoCombobox'" />
                                </td>
                                <td>
                                    <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-search',plain:true"
                                        onclick="grid.datagrid('load',$.serializeObject($('#searchForm')));">查询</a><a href="javascript:void(0);"
                                            class="easyui-linkbutton" data-options="iconCls:'ext-icon-magifier_zoom_out',plain:true"
                                            onclick="$('#searchForm input').val('');grid.datagrid('load',{});">重置</a>
                                </td>

                            </tr>
                        </table>
                    </form>
                </td>
            </tr>
            <%if (roleid == 1)
                { %>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td>
                                <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-note_add',plain:true"
                                    onclick="addFun();">添加新用户</a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%} %>
        </table>
    </div>
    <div data-options="region:'center',fit:true,border:false">
        <table id="grid" data-options="fit:true,border:false">
        </table>
    </div>
</body>
</html>
