<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>工资管理系统</title>
    <link href="../css/style.css" rel="stylesheet" type="text/css" />
    <%--引入My97日期文件--%>
    <script src="../js/My97DatePicker/WdatePicker.js" type="text/javascript"></script>
    <%--引入Jquery文件--%>
    <script src="../js/easyui/jquery-1.10.2.min.js" type="text/javascript"></script>
    <script src="../js/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <%--引入easyui文件--%>
    <link href="../js/easyui/themes/default/easyui.css" rel="stylesheet" type="text/css" />
    <link href="../js/easyui/themes/icon.css" rel="stylesheet" type="text/css" />
    <link href="../css/extEasyUIIcon.css" rel="stylesheet" type="text/css" />
    <script src="../js/easyui/locale/easyui-lang-zh_CN.js" type="text/javascript"></script>
    <script src="../js/extJquery.js" type="text/javascript"></script>
    <script src="../js/extEasyUI.js" type="text/javascript"></script>
    <%--引入uploadify文件--%>
    <link rel="stylesheet" type="text/css" href="../js/uploadify/uploadify.css" />
    <script type="text/javascript" src="../js/uploadify/jquery.uploadify.js"></script>
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
        //查询功能
        var searchGrid = function () {
            if ($('#searchForm').form('validate')) {
                parent.$.messager.progress({
                    title: '提示',
                    text: '数据处理中，请稍后....'
                });
                $.post('../Service/salary.ashx/GetDeptSalary', $.serializeObject($('#searchForm')), function (result) {
                    parent.$.messager.progress('close');
                    if (result.total >= 1) {
                        deptsalaryGrid.datagrid({
                            columns: [result.columns]
                        }).datagrid({ loadFilter: pagerFilter }).datagrid("loadData", result.rows);
                    } else {
                        parent.$.messager.alert('提示', '无该月工资数据', 'error');
                        deptsalaryGrid.datagrid({
                            columns: [[]]
                        }).datagrid("loadData", { rows: [] });
                    }
                }, 'json');
            }
        };
        //导出明细excel
        var exportExcel = function () {
            if ($('#searchForm').form('validate')) {
                jsPostForm('../service/salary.ashx/ExportDeptSalaryDetail', $.serializeObject($('#searchForm')));
            }
        };
        //设置分页
        var pagerFilter = function (data) {
            if (typeof data.length == 'number' && typeof data.splice == 'function') {	// is array
                data = {
                    total: data.length,
                    rows: data
                }
            }
            var dg = $(this);
            var opts = dg.datagrid('options');
            var pager = dg.datagrid('getPager');
            pager.pagination({
                onSelectPage: function (pageNum, pageSize) {
                    opts.pageNumber = pageNum;
                    opts.pageSize = pageSize;
                    pager.pagination('refresh', {
                        pageNumber: pageNum,
                        pageSize: pageSize
                    });
                    dg.datagrid('loadData', data);
                }
            });
            if (!data.originalRows) {
                data.originalRows = (data.rows);
            }
            var start = (opts.pageNumber - 1) * parseInt(opts.pageSize);
            var end = start + parseInt(opts.pageSize);
            data.rows = (data.originalRows.slice(start, end));
            return data;
        }
        //工资表
        var deptsalaryGrid;
        $(function () {
            deptsalaryGrid = $('#deptsalaryGrid').datagrid({
                fit: false,//自动大小  
                rownumbers: false,//行号 
                singleSelect: false,//单行选取
                pagination: true,//显示分页
                pageSize: 20,//
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
                        <td class="search_td">月份： 
                        </td>
                        <td align="left" style="padding: 5px;">
                            <input style="width: 80px;" name="sdate" class="Wdate easyui-validatebox" onfocus="WdatePicker({maxDate:'%y-%M',dateFmt:'yyyy-MM'})"
                                readonly="readonly" required />
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-search',plain:false"
                                onclick="searchGrid();">工资查询</a>
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'ext-icon-table_go',plain:false"
                                onclick="exportExcel();">导出</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="deptsalaryGrid">
        </table>
    </div>
</body>
</html>
