<%@ Page Language="C#" %>

<%--用户修改密码--%>
<%  
    int uid = 0;
    if (!Request.IsAuthenticated)
    {%>
<script type="text/javascript">
    parent.$.messager.alert('提示', '登陆超时，请重新登陆再进行操作！', 'error', function () {
        parent.location.replace('default.aspx');
    });
</script>
<%}
    else
    {
        UserDetail ud = new UserDetail();
        uid = ud.LoginUser.UID;
%>
<script type="text/javascript">
    var uid='<%=uid%>';
</script>
<%} %>
<script type="text/javascript">

    var onFormSubmit = function ($dialog) {
        if ($('form').form('validate')) {
            var url = 'service/UserInfo.ashx/EditPasswd';
            $.post(url, $.serializeObject($('form')), function (result) {
                if (result.success) {
                    $dialog.dialog('close');
                    parent.$.messager.alert('提示', result.msg, 'info');
                } else {
                    parent.$.messager.alert('提示', result.msg, 'error');
                }
            }, 'json');
        }
    };
</script>
<form method="post">
    <table cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" border="1" style="border-collapse: collapse;width:320px">
        <tr style="line-height:30px;">
            <th class="left_td" >原密码：
            </th>
            <td class="tdinput">
                <input type="hidden" name="uid" value="<%=uid %>">
                <input name="oldPwd" type="password" placeholder="请输入原密码" class="inputBorder easyui-validatebox"
                    data-options="required:true" />
            </td>
        </tr>
        <tr>
            <th  class="left_td">新密码：
            </th>
            <td class="tdinput">
                <input name="pwd" id="pwd" type="password" placeholder="请输入新密码" class=" inputBorder easyui-validatebox"
                    data-options="required:true" />
            </td>
        </tr>
        <tr>
            <th  class="left_td">重复密码：
            </th>
            <td class="tdinput">
                <input name="rePwd" type="password" placeholder="请再次输入新密码" class="inputBorder easyui-validatebox"
                    data-options="required:true,validType:'equalTo[\'#pwd\']'" />
            </td>
        </tr>
    </table>
</form>
