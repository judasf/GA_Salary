<%@ Page Language="C#" %>

<% 
    /** 
     * UserInfo表操作对话框
     * 
     */
    string id = string.IsNullOrEmpty(Request.QueryString["UID"]) ? "" : Request.QueryString["UID"].ToString();
%>
<script type="text/javascript">

    var onFormSubmit = function ($dialog, $grid) {
        if ($('form').form('validate')) {
            var url;
            if ($('#UID').val().length == 0) {
                url = 'service/UserInfo.ashx/SaveUserInfo';
            } else {
                url = 'service/UserInfo.ashx/UpdateUserInfo';
            }
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
                        'roleId': result.rows[0].roleid,
                        'deptId': result.rows[0].deptid
                    });
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
                <input id="userName" type="text" name="userName" class="easyui-validatebox inputBorder" <%=!(id=="")?"readonly":"" %> required placeholder="身份证号" />
            </td>
        </tr>
        <tr>
            <td class="left_td">姓    名：
            </td>
            <td class="tdinput">
                <input id="realName" type="text" name="realName" class="easyui-validatebox inputBorder"required placeholder="姓名" />
            </td>
        </tr>
        <tr>
            <td class="left_td">所在部门：
            </td>
            <td class="tdinput">
                <input id="deptId" type="text" name="deptId" class="easyui-combobox combo" data-options="required:true,valueField:'id',textField:'text',editable:false,panelHeight:'160',url:'service/Department.ashx/GetDepartmentCombobox'" />
            </td>
        </tr>
        <tr>
            <td class="left_td">角色名称：
            </td>
            <td class="tdinput">
                <input id="roleId" type="text" name="roleId" class="easyui-combobox combo" data-options="required:true,valueField:'id',textField:'text',editable:false,panelHeight:'auto',url:'service/RoleInfo.ashx/GetRoleInfoCombobox'" />
            </td>
        </tr>
    </table>
</form>
