<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserInfo.aspx.cs" Inherits="BaseInfo_UserInfo" %>

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
        var addFun = function () {
            var dialog = parent.$.modalDialog({
                title: '添加用户',
                width: 340,
                height: 300,
                iconCls: 'ext-icon-note_add',
                href: 'baseinfo/dialogop/UserInfo_op.aspx', //将对话框内容添加到父页面index
                buttons: [{
                    text: '添加',
                    handler: function () {
                        parent.onFormSubmit(dialog, grid);
                    }
                },
                {
                    text: '取消',
                    handler: function () {
                        dialog.dialog('close');
                    }
                }
                ]
            });
        };
        var editFun = function (id) {
            var dialog = parent.$.modalDialog({
                title: '编辑用户',
                width: 340,
                height: 300,
                iconCls: 'icon-edit',
                href: 'baseinfo/dialogop/UserInfo_op.aspx?uid=' + id,
                buttons: [{
                    text: '保存',
                    handler: function () {
                        parent.onFormSubmit(dialog, grid);
                    }
                }]
            });
        };
        var removeFun = function (id) {
            parent.$.messager.confirm('询问', '您确定要删除此记录？', function (r) {
                if (r) {
                    $.post('../service/UserInfo.ashx/RemoveUserInfoByID', {
                        UID: id
                    }, function (result) {
                        if (result.success) {
                            grid.datagrid('reload');
                        } else {
                            parent.$.messager.alert('提示', result.msg, 'error');
                        }
                    }, 'json');
                }
            });
        };
        var resetPwdFun = function (id) {
            parent.$.messager.confirm('询问', '恢复该用户密码？', function (r) {
                if (r) {
                    $.post('../service/UserInfo.ashx/ResetPwdByID', {
                        UID: id
                    }, function (result) {
                        if (result.success) {
                            grid.datagrid('reload');
                            parent.$.messager.show({ title: '成功', msg: '密码恢复成功！' });
                        } else {
                            parent.$.messager.alert('提示', result.msg, 'error');
                        }
                    }, 'json');
                }
            });
        };
        //批量设置部门
        var setDept = function () {
            var rows = grid.datagrid('getSelections');
            var ids = [];
            if (rows.length == 0) {
                parent.$.messager.alert('提示', '请选择人员', 'error');
                return false;
            }
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                ids.push(row.uid);
            }
            var dialog = parent.$.modalDialog({
                title: '设置部门',
                width: 340,
                height: 150,
                iconCls: 'icon-edit',
                href: 'baseinfo/dialogop/DeptSet_OP.aspx?ids=' + ids.join(','),
                buttons: [{
                    text: '保存',
                    handler: function () {
                        parent.onDeptSetFormSubmit(dialog, grid);
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
                singleSelect: false,
                noheader: true,
                idField: 'uid',
                sortName: 'uid',
                sortOrder: 'desc',
                frozenColumns: [[{
                    field: 'ck',
                    checkbox: true
                }]],
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
                    sortable: true,
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
                    width: '80',
                    halign: 'center',
                    align: 'center',
                    formatter: function (value, row) {
                        var str = '';

                        str += $.formatString('<img src="../js/easyui/themes/icons/pencil.png" title="编辑" onclick="editFun(\'{0}\');"/>&nbsp;&nbsp;&nbsp;&nbsp;', row.uid);
                        str += $.formatString('<img src="../js/easyui/themes/icons/no.png" title="删除" onclick="removeFun(\'{0}\');"/>&nbsp;&nbsp;&nbsp;&nbsp;', row.uid);
                        str += $.formatString('<img src="../css/images/ext_icons/lock/lock_edit.png" title="重置密码" onclick="resetPwdFun(\'{0}\');"/>&nbsp;&nbsp;', row.uid);
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
            if (roleid != 3)
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
                                    <input id="deptId" type="text" name="deptId" style="width: 100px;"class="easyui-combobox combo" data-options="required:true,valueField:'id',textField:'text',editable:false,panelHeight:'160',url:'../service/Department.ashx/GetAllDeptsCombobox'" />
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
            <%if (roleid == 3)//人事管理员
                { %>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td>
                                <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-note_add',plain:true"
                                    onclick="addFun();">添加用户</a>
                            </td>
                            <td>
                                <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-group',plain:true"
                                    onclick="setDept();">批量设置部门</a>
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
