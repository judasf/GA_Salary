<%@ Page Language="C#" %>

<% 
    /** 
     * 人事调动表操作对话框
     * 
     */
    string id = string.IsNullOrEmpty(Request.QueryString["UID"]) ? "" : Request.QueryString["UID"].ToString();
%>
<script type="text/javascript">

    var onFormSubmit = function ($dialog, $grid) {
        if ($('form').form('validate')) {
            var url = 'service/UserInfo.ashx/UserTransfer';
            $.post(url, $.serializeObject($('form')), function (result) {
                if (result.success) {
                    $grid.datagrid('reload');
                    $dialog.dialog('close');
                } else {
                    parent.$.messager.alert('提示', result.msg, 'error');
                }
            }, 'json');
        }
    };
    $(function () {
        if ($('#UID').val().length > 0) {
            parent.$.messager.progress({
                text: '数据加载中....'
            });
            $.post('service/UserInfo.ashx/GetUserInfoByID', {
                UID: $('#UID').val()
            }, function (result) {
                if (result.rows[0].uid != undefined) {
                    $('form').form('load', {
                        'UID': result.rows[0].uid,
                        'userName': result.rows[0].username,
                        'realName': result.rows[0].realname,
                        'deptName': result.rows[0].deptname
                });
                $('#userName').html(result.rows[0].username);
                $('#realName').html(result.rows[0].realname);
                $('#deptName').html(result.rows[0].deptname);
            }
                parent.$.messager.progress('close');
        }, 'json');
    }
    });
</script>
<form method="post">
    <table cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" border="1" style="border-collapse: collapse; width: 320px">

        <tr>
            <td class="left_td">身份证号：
            </td>
            <td class="tdinput">
                <input type="hidden" id="UID" name="UID" value="<%=id %>" />
                <input type="hidden" name="userName" />
                <span id="userName"></span>
            </td>
        </tr>
        <tr>
            <td class="left_td">姓    名：
            </td>
            <td class="tdinput">
                <input type="hidden" name="realName" />
                <span id="realName"></span>
            </td>
        </tr>
        <tr>
            <td class="left_td">所在部门：
            </td>
            <td class="tdinput">
                <input type="hidden" name="deptName" />
                <span id="deptName"></span>
            </td>
        </tr>
        <tr>
            <td class="left_td">新部门：
            </td>
            <td class="tdinput">
                <input id="deptId" type="text" name="deptId" class="easyui-combobox combo" data-options="required:true,valueField:'id',textField:'text',mode:'remote',editable:true,panelHeight:'160',url:'service/Department.ashx/GetDepartmentCombobox'" />
            </td>
        </tr>
    </table>
</form>
