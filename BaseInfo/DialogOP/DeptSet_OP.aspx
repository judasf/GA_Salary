<%@ Page Language="C#" %>

<% 
    /** 
     * 设置员工部门操作对话框
     * 
     */
    string ids = string.IsNullOrEmpty(Request.QueryString["ids"]) ? "" : Request.QueryString["ids"].ToString();
%>
<script type="text/javascript">
    var onDeptSetFormSubmit = function ($dialog, $grid) {
        if ($('form').form('validate')) {
            var url = 'service/UserInfo.ashx/SetUserDepartment';
            $.post(url, $.serializeObject($('form')), function (result) {
                if (result.success) {
                    $grid.datagrid('load');
                    $grid.datagrid('clearSelections');
                    $dialog.dialog('close');
                } else {
                    parent.$.messager.alert('提示', result.msg, 'error');
                }
            }, 'json');
        }
    };
</script>
<form method="post">
    <table class="table table-bordered  table-hover">
        <tr>
            <td style="text-align: right">部门名称：
            </td>
            <td style="width: 200px">
                <input type="hidden" id="ids" name="ids" value="<%=ids %>" />
                <input id="deptId" type="text" name="deptId" class="easyui-combobox combo" data-options="required:true,valueField:'id',textField:'text',editable:true,panelHeight:'160',url:'service/Department.ashx/GetDeptsCombobox'" />
            </td>
        </tr>
    </table>
</form>
