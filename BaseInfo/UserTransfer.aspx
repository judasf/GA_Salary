<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserTransfer.aspx.cs" Inherits="BaseInfo_UserTransfer" %>

<!DOCTYPE html>
<html>
<head>
    <title>人事调动</title>
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
        var auditFun = function (id) {
            parent.$.messager.confirm('询问', '确定要审核此项人事调动？', function (r) {
                if (r) {
                    $.post('../service/UserTransfer.ashx/AuditUserTransferByID', {
                        id: id
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
        var removeFun = function (id) {
            parent.$.messager.confirm('询问', '确定要删除此项申请？', function (r) {
                if (r) {
                    $.post('../service/UserTransfer.ashx/RemoveUserTransferByID', {
                        id: id
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
        $(function () {
            grid = $('#grid').datagrid({
                title: '人事调动',
                url: '../service/UserTransfer.ashx/GetUserTransfer',
                striped: true,
                rownumbers: true,
                pagination: true,
                pageSize: 20,
                singleSelect: true,
                noheader: true,
                idField: 'id',
                sortName: 'id',
                sortOrder: 'desc',
                columns: [[{
                    width: '80',
                    title: '申请日期',
                    field: 'applydate',
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '180',
                    title: '身份证号',
                    field: 'username',
                    sortable: true,
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '80',
                    title: '姓名',
                    field: 'realname',
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '100',
                    title: '原部门',
                    field: 'olddept',
                    sortable: true,
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '100',
                    title: '新部门',
                    field: 'newdept',
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '80',
                    title: '当前进度',
                    field: 'status',
                    halign: 'center',
                    align: 'center',
                    formatter: function (value, row, index) {
                        switch (value) {
                            case '0':
                                return '待审核'
                                break;
                            case '1':
                                return '已审核'
                                break;
                        }
                    }
                }, {
                    width: '80',
                    title: '申请人',
                    field: 'applyuser',
                    halign: 'center',
                    align: 'center'
                }, {
                    title: '操作',
                    field: 'action',
                    width: '70',
                    halign: 'center',
                    align: 'center',
                    formatter: function (value, row) {
                        var str = '';
                        if (roleid == 3) { //人事管理员
                            if (row.status == 0)
                                str += $.formatString('<a href="javascript:void(0)" onclick="auditFun(\'{0}\');">审核</a>&nbsp&nbsp&nbsp&nbsp;', row.id);
                                str += $.formatString('<a href="javascript:void(0)" onclick="removeFun(\'{0}\');">删除</a>', row.id);
                        }
                        return str;
                    }
                }]],
                rowStyler: function (index, row) {
                    if (row.status == 0 && roleid == 3)
                        return 'color:#f00;font-weight:700;';
                },
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
                                <td style="width: 60px; text-align: right;">姓名：
                                </td>
                                <td>
                                    <input name="realName" class="combo" style="width: 80px;" />
                                </td>
                                <td style="width: 60px; text-align: right;">进度：
                                </td>
                                <td>
                                    <input style="width: 60px" name="status" id="status" class="easyui-combobox"
                                        data-options="panelHeight:'auto',editable:false,valueField:'value',textField:'text',data:[{'value':'0','text':'待审核'},{'value':'1','text':'已审核'}]" />
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
        </table>
    </div>
    <div data-options="region:'center',fit:true,border:false">
        <table id="grid" data-options="fit:true,border:false">
        </table>
    </div>
</body>
</html>
