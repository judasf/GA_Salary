﻿<%@ Page Language="C#" %>

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
    <%  int roleid = 0;
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
        //导入数据
        var importSalaryOther = function () {
            var dialog = parent.$.modalDialog({
                title: '导入数据',
                width: 600,
                height: 230,
                iconCls: 'ext-icon-table_go',
                href: 'Dialog/ImportSalaryOther_op.aspx',
                buttons: [{
                    text: '导入',
                    handler: function () {
                        parent.onFormSubmit(dialog, salaryOtherTableGrid);
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
        var delOtherTableFun = function (name) {
            parent.$.messager.confirm('询问', '您确定要删除该薪酬数据？', function (r) {
                if (r) {
                    $.post('../service/Salary.ashx/DelOtherTableByName', {
                        tablename: name
                    }, function (result) {
                        if (result.success) {
                            salaryOtherTableGrid.datagrid('reload');
                        } else {
                            parent.$.messager.alert('提示', result.msg, 'error');
                        }
                    }, 'json');
                }
            });
        };
        //工资数据表列表
        var salaryOtherTableGrid;
        $(function () {
            salaryOtherTableGrid = $('#salaryOtherTableGrid').datagrid({
                title: '已导入薪酬数据表',
                url: '../service/Salary.ashx/GetSalaryOtherTableInfo',
                striped: true,
                rownumbers: true,
                pagination: true,
                pageSize: 20,
                singleSelect: false,
                noheader: false,
                idField: 'id',
                sortName: 'id',
                sortOrder: 'desc',
                columns: [[{
                    width: '120',
                    title: '月份',
                    field: 'month',
                    sortable: true,
                    halign: 'center',
                    align: 'center'
                },{
                    width: '180',
                    title: '薪酬名称',
                    field: 'salaryname',
                    sortable: true,
                    halign: 'center',
                    align: 'center'
                }, {
                    width: '160',
                    title: '导入时间',
                    field: 'inputtime',
                    halign: 'center',
                    align: 'center'
                }, {
                    title: '操作',
                    field: 'action',
                    width: '50',
                    halign: 'center',
                    align: 'center',
                    formatter: function (value, row) {
                        var str = '';
                        str += $.formatString('<img src="../js/easyui/themes/icons/no.png" title="删除" onclick="delOtherTableFun(\'{0}\');"/>', row.tablename);
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
            var pager = $('#salaryOtherTableGrid').datagrid('getPager');
            pager.pagination({
                layout: ['list', 'sep', 'first', 'prev', 'sep', 'links', 'sep', 'next', 'last', 'sep', 'refresh', 'sep', 'manual']

            });
        });
    </script>
</head>
<body class="easyui-layout">

    <div data-options="region:'center',fit:true,border:false">
        <div id="agTip">
            <form id="searchForm" style="margin: 0;">
                <table cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" border="1" style="border-collapse: collapse; width: 800px;">
                    <tr>

                        <td align="left" style="padding: 5px;">

                            <%if (roleid == 1)//工资管理员
                                { %> 其他薪酬数据导入：<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-table_row_insert',plain:false"
                                    onclick="importSalaryOther();">导入数据</a>
                            <%}%>
                          
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="salaryOtherTableGrid">
        </table>
    </div>
</body>
</html>
