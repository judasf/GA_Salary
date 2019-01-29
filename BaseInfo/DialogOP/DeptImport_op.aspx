<%@ Page Language="C#" %>

<% 
    /** 
     *导入excel文件操作对话框
     * 
     */
   
%>
<script type="text/javascript">
    //提交表单

    var onFormSubmit = function ($dialog, $grid) {
        if ($('#upform').form('validate')) {
            var url = 'service/Department.ashx/ImportDeptInfo';
            //判断是否有报表上传
            if ($('#report').val() == "") {
                parent.$.messager.alert('提示', '请上传文件后再导入数据！', 'error');
                return;
            }
            else {
                parent.$.messager.progress({
                    title: '提示',
                    text: '数据导入中，请稍后....'
                });
                $.post(url, $.serializeObject($('form')), function (result) {
                    parent.$.messager.progress('close');
                    if (result.success) {
                        $grid.datagrid('load');
                        parent.$.messager.show({
                            title: '提示',
                            msg: result.msg,
                            showType: 'show',
                            style: {
                                top: document.body.scrollTop + document.documentElement.scrollTop
                            }
                        });
                        $dialog.dialog('close');
                    } else
                        parent.$.messager.alert('提示', result.msg, 'error');
                }, 'json');
            }
        }
    };
    $(function () {
        //初始化上传插件
        $("#file_upload").uploadify({
            //开启调试
            'debug': false,
            //是否自动上传
            'auto': false,
            //上传成功后是否在列表中删除
            'removeCompleted': false,
            //在文件上传时需要一同提交的数据
            'formData': { 'floderName': 'BaseInfo' },
            'buttonText': '选择文件',
            //flash
            'swf': "js/uploadify/uploadify.swf",
            //文件选择后的容器ID
            'queueID': 'uploadfileQueue',
            'uploader': 'js/uploadify/uploadify.ashx',
            'width': '75',
            'height': '24',
            'multi': false,
            'fileTypeDesc': '支持的格式：',
            'fileTypeExts': '*.xls',
            'fileSizeLimit': '10MB',
            'removeTimeout': 1,
            'queueSizeLimit': 1,
            'uploadLimit': 1,
            'overrideEvents': ['onDialogClose', 'onSelectError', 'onUploadError'],
            'onDialogClose': function (queueData) {
                $('#reportNum').val(queueData.queueLength);
            },
            'onCancel': function (file) {
                $('#reportNum').val(0);
            },
            //返回一个错误，选择文件的时候触发
            'onSelectError': function (file, errorCode, errorMsg) {
                switch (errorCode) {
                    case -100:
                        parent.$.messager.alert('出错', '只能上传' + $('#file_upload').uploadify('settings', 'queueSizeLimit') + '个文件！', 'error');
                        break;
                    case -110:
                        parent.$.messager.alert('出错', '文件“' + file.name + '”大小超出系统限制的' + $('#file_upload').uploadify('settings', 'fileSizeLimit') + '大小！', 'error');
                        break;
                    case -120:
                        parent.$.messager.alert('出错', '文件“' + file.name + '”大小异常！', 'error');
                        break;
                    case -130:
                        parent.$.messager.alert('出错', '文件“' + file.name + '”类型不正确，请选择正确的Excel文件！', 'error');
                        break;
                }
            },
            //返回一个错误，文件上传出错的时候触发
            'onUploadError': function (file, errorCode, errorMsg) {
                switch (errorCode) {
                    case -200:
                        parent.$.messager.alert('出错', '网络错误请重试,错误代码：' + errorMsg, 'error');
                        break;
                    case -210:
                        parent.$.messager.alert('出错', '上传地址不存在，请检查！', 'error');
                        break;
                    case -220:
                        parent.$.messager.alert('出错', '系统IO错误！', 'error');
                        break;
                    case -230:
                        parent.$.messager.alert('出错', '系统安全错误！', 'error');
                        break;
                    case -240:
                        parent.$.messager.alert('出错', '文件已上传！', 'error');
                        break;
                }
            },
            //检测FLASH失败调用
            'onFallback': function () {
                parent.$.messager.alert('出错', '您未安装FLASH控件，无法上传图片！请安装FLASH控件后再试!', 'error');
            },
            //上传到服务器，服务器返回相应信息到data里
            'onUploadSuccess': function (file, data, response) {
                if (data) {
                    var result = $.parseJSON(data);
                    if (result.success) {
                        $('#report').val(result.filepath);
                        $('#reportName').html(file.name);
                        $('#reportTr').show();
                    }
                    else
                        parent.$.messager.alert('出错', result.msg, 'error');
                }
            }
        });
    });
</script>
<form method="post" id="upform">
    <table class="table table-bordered  table-hover">
        <tr>
            <td style="text-align: right;width:80px;">数据模板：
           </td>
            <td  align="left"><a href="../../template.xls">点击下载</a></td>
        </tr>
        <tr>
            <td style="text-align: right;width:80px;">数据上传：
            </td>
            <td>
                <input type="hidden" name="report" id="report" />
                <input type="hidden" name="reportNum" id="reportNum" value="0" />
                <div class="clearfix">
                    <div id="uploadfileQueue" style="float: right; width: 380px;">
                    </div>
                    <div style="width: 75px; float: left; text-align: center;">
                        <input id="file_upload" name="file_upload" type="file" />
                        <div class="uploadify-button" style="height: 24px; cursor: pointer; line-height: 24px; width: 75px;"
                            onclick="$('#file_upload').uploadify('upload', '*');">
                            <span class="uploadify-button-text">上传文件</span>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
        <tr id="reportTr" style="display: none;">
            <td style="text-align: right;">文件名称：
            </td>
            <td>
                <span id="reportName"></span>
            </td>
        </tr>
    </table>
</form>
