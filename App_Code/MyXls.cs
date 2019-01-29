using System;
using System.Collections.Generic;
using System.Web;
using org.in2bits.MyXls;
using System.Data;
using System.Data.OleDb;
using System.IO;
/// <summary>
///导出Excel文件类
/// </summary>
public sealed class MyXls
{
    public MyXls()
    {
        //
        //TODO: 在此处添加构造函数逻辑
        //
    }
    /// <summary>
    /// 导出生成excel文件
    /// </summary>
    /// <param name="dt">datatable</param>
    /// <param name="fileName">文件名.xls</param>
    /// <param name="longColumnsIndex">需要设置长宽度的列的集合eg."1,2,3,4"</param>
    public static void CreateXls(DataTable dt, string fileName, string longColumnsIndex)
    {
        XlsDocument xls = new XlsDocument();

        if (System.Web.HttpContext.Current.Request.UserAgent.ToLower().IndexOf("msie") > -1)
            xls.FileName = System.Web.HttpUtility.UrlEncode(fileName, System.Text.Encoding.UTF8);
        else
            xls.FileName = fileName;
        int rowIndex = 1;
        int colIndex = 0;
        Worksheet sheet = xls.Workbook.Worksheets.Add("sheet");//状态栏标题名称
        Cells cells = sheet.Cells;
        //设置整体列宽带
        ColumnInfo colInfo = new ColumnInfo(xls, sheet);
        colInfo.ColumnIndexStart = 0;
        colInfo.ColumnIndexEnd = 22;
        colInfo.Width = 14 * 256;
        sheet.AddColumnInfo(colInfo);
        if (longColumnsIndex.Length > 0)
        {
            //单独设置需要长宽度的列
            string[] longIndexs = longColumnsIndex.Split(',');
            if (longIndexs.Length > 0)
            {
                //遍历数组，设置每一列的宽度
                for (int i = 0; i < longIndexs.Length; i++)
                {
                    ColumnInfo colInfo1 = new ColumnInfo(xls, sheet);
                    colInfo1.ColumnIndexStart = ushort.Parse(longIndexs[i]);
                    colInfo1.ColumnIndexEnd = ushort.Parse(longIndexs[i]);
                    colInfo1.Width = 36 * 256;
                    sheet.AddColumnInfo(colInfo1);
                }
            }
        }
        //设置样式
        XF xf = xls.NewXF();
        xf.UseProtection = false;
        xf.HorizontalAlignment = HorizontalAlignments.Centered;
        xf.VerticalAlignment = VerticalAlignments.Centered;
        xf.TextWrapRight = true;
        xf.UseBorder = true;
        xf.TopLineStyle = 1;
        xf.TopLineColor = Colors.Black;
        xf.BottomLineStyle = 1;
        xf.BottomLineColor = Colors.Black;
        xf.LeftLineStyle = 1;
        xf.LeftLineColor = Colors.Black;
        xf.RightLineStyle = 1;
        xf.RightLineColor = Colors.Black;
        xf.Font.Bold = true;
        //
        foreach (DataColumn col in dt.Columns)
        {
            colIndex++;
            Cell cell = cells.Add(1, colIndex, col.ColumnName, xf);
        }
        sheet.Rows[1].RowHeight = 24 * 20;
        //填充数据
        foreach (DataRow row in dt.Rows)
        {

            rowIndex++;
            colIndex = 0;
            foreach (DataColumn col in dt.Columns)
            {
                colIndex++;
                Cell cell = cells.Add(rowIndex, colIndex, row[col.ColumnName].ToString(), xf);//转换为数字型
                //如果你数据库里的数据都是数字的话 最好转换一下，不然导入到Excel里是以字符串形式显示。
                cell.Font.FontFamily = FontFamilies.Roman; //字体
                cell.Font.Bold = false;  //字体为粗体   
            }
            //设置行高
            sheet.Rows[(ushort)rowIndex].RowHeight = 24 * 20;
        }
        xls.Send(XlsDocument.SendMethods.Attachment);
    }
    /// <summary>
    /// 合并单元格，参数列表：开始行，结束行，开始列，结束列
    /// </summary>
    /// <param name="ws">sheet</param>
    /// <param name="xf">样式</param>
    /// <param name="title">新内容</param>
    /// <param name="startRow">开始行</param>
    /// <param name="startCol">开始列</param>
    /// <param name="endRow">结束行</param>
    /// <param name="endCol">结束列</param>
    public static void MergeRegion(ref Worksheet ws, XF xf, string title, int startRow, int endRow, int startCol, int endCol)
    {
        for (int i = startCol; i <= endCol; i++)
        {
            for (int j = startRow; j <= endRow; j++)
            {
                ws.Cells.Add(j, i, title, xf);
            }
        }
        ws.Cells.Merge(startRow, endRow, startCol, endCol);
    }
    /// <summary>
    /// 检测excel中的单元表是否存在
    /// </summary>
    /// <param name="filePath"></param>
    /// <param name="sheetName"></param>
    /// <returns>-1:文件不存在；0:单元表不存在；1：单元表存在</returns>
    public static int ChkSheet(string filePath, string sheetName)
    {
        int result = 0;
        if (!File.Exists(filePath))
        {
            return -1;
        }
        string strConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;IMEX=1; HDR=1';";
        //链接Excel
        OleDbConnection cnnxls = new OleDbConnection(strConn);

        cnnxls.Open();
        //取得sheeet 名
        DataTable sheetDt = cnnxls.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);

        foreach (DataRow dr in sheetDt.Rows)
        {
            //excel文件中单元表的名称
            string sheetNames = dr["Table_Name"].ToString();
            if (sheetNames == sheetName + "$")
                result = 1;
        }
        //验证列名
        if(result==1)//sheet表名存在
        {
            DataTable columns= cnnxls.GetOleDbSchemaTable(OleDbSchemaGuid.Columns,new object[]{null,null,sheetName,null});
        }
        cnnxls.Close();
        return result;
    }
    /// <summary>
    /// 检测excel文件中的列名是否存在
    /// </summary>
    /// <param name="filePath">上传后的文件路径</param>
    /// <param name="sheetName">单元表的名字</param>
    /// <param name="columnsList">List(string)要验证的列名集合</param>
    /// <returns>返回整数List,全部为1通过验证，有0则验证失败</returns>
    public static List<int> ChkSheetColumns(string filePath, string sheetName, List<string> columnsList)
    {
        List<int> resultArr = new List<int>();
        string strConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;IMEX=1; HDR=1';";
        //链接Excel
        OleDbConnection cnnxls = new OleDbConnection(strConn);

        cnnxls.Open();
       
        //验证列名
         DataTable columnsDt = cnnxls.GetOleDbSchemaTable(OleDbSchemaGuid.Columns, new object[] { null, null, sheetName+"$", null });
        //当前sheet列名集合
        List<string> columnNames=new List<string>();
         foreach (DataRow dr in columnsDt.Rows)
         {
             //excel单元表的列名
             columnNames.Add(dr["Column_Name"].ToString());
         }
        //遍历要检测的列名集合
        foreach(string name in columnsList)
        {
            if (columnNames.Contains(name))
                resultArr.Add(1);
            else
                resultArr.Add(0);
        }
        cnnxls.Close();
        return resultArr;
    }
}