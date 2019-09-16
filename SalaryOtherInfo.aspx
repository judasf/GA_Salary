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
    <%  int roleid = 0;
        string userName = "";
        if (!Request.IsAuthenticated)
        {
            Response.Redirect("index.aspx");
    %>
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
        //查询功能
        var searchGrid = function () {
            if ($('#searchForm').form('validate')) {
                parent.$.messager.progress({
                    title: '提示',
                    text: '数据处理中，请稍后....'
                });
                $.post('Service/salary.ashx/GetSalaryOtherInfo', $.serializeObject($('#searchForm')), function (result) {
                    parent.$.messager.progress('close');
                    if (result.total >= 1) {
                        salaryOtherGrid.datagrid({
                            columns: [result.columns]
                        }).datagrid("loadData", result.rows);
                    } else {
                        parent.$.messager.alert('提示', '无该月薪酬数据', 'error');
                        salaryOtherGrid.datagrid({
                            columns: [[]]
                        }).datagrid("loadData", { rows: [] });
                    }
                }, 'json');
            }
        };
        //导出明细excel
        var exportOtherExcel = function () {
            if ($('#searchForm').form('validate')) {
                jsPostForm('../service/salary.ashx/ExportSalaryOtherDetail', $.serializeObject($('#searchForm')));
            }
        };
        //日期控件选择月份后触发
        var pickTable = function () {
            var tm = $dp.cal.getNewDateStr();
            $.post('Service/salary.ashx/GetSalaryOtherTableName', { sdate: tm }, function (result) {
                if (result.total >= 1) {
                    salaryOther.combobox("clear").combobox("loadData", result.rows);
                } else {
                    parent.$.messager.alert('提示', '该月未导入其他薪酬数据', 'error');
                    salaryOther.combobox("clear");
                }
            }, 'json');

        }
        //日期控件清空后触发,清空下拉框
        var clearTable = function () {
            salaryOther.combobox("clear");
        }
        //薪酬下拉列表框
        var salaryOther;
        //工资表
        var salaryOtherGrid;
        $(function () {
            salaryOther = $('#SalaryOther').combobox({
                valueField: 'tablename',
                textField: 'salaryname',
                panelHeight: 'auto',
                editable: false,
                required: true
            });
            salaryOtherGrid = $('#salaryOtherGrid').datagrid({
                fit: false,//自动大小  
                rownumbers: false,//行号 
                singleSelect: false,//单行选取
                pagination: true, //显示分页
                pageSize: 20,
                idField: '身份证号码',
                sortName: '身份证号码',
                sortOrder: 'desc',
                columns: [[]]
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
                        <td colspan="2" class="h_title">数据查询
                        </td>
                    </tr>
                    <tr>

                        <td align="left" style="padding: 5px;">月份：
                            <input style="width: 80px;" id="sdate" name="sdate" class="Wdate easyui-validatebox" onfocus="WdatePicker({maxDate:'%y-%M',dateFmt:'yyyy-MM',onpicked:pickTable,oncleared:clearTable})"
                                readonly="readonly" required />
                            <label for="SalaryOther" style="margin-left: 10px;">选择薪酬：</label>
                            <input id="SalaryOther" name="SalaryOther" />
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-search',plain:false"
                                onclick="searchGrid();">查询</a>
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-table_go',plain:false"
                                onclick="exportOtherExcel();">导出</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="salaryOtherGrid">
        </table>
    </div>
</body>
</html>
