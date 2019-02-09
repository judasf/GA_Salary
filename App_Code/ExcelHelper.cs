using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using NPOI.SS.UserModel;
using NPOI.HSSF.UserModel;
using NPOI.HPSF;
using NPOI.SS.Util;
using NPOI.XSSF.UserModel;
using NPOI.HSSF.Util;

public class ExcelHelper
{
    /// <summary>
    /// DataTable导出到Excel文件
    /// </summary>
    /// <param name="dtSource">源DataTable</param>
    /// <param name="strHeaderText">表头文本</param>
    /// <param name="strFileName">保存位置</param>
    /// <param name="sheetName">单元表名称</param>
    public static void Export(DataTable dtSource, string strHeaderText, string strFileName, string sheetName)
    {
        using (MemoryStream ms = Export(dtSource, strHeaderText, sheetName))
        {
            using (FileStream fs = new FileStream(strFileName, FileMode.Create, FileAccess.Write))
            {
                byte[] data = ms.ToArray();
                fs.Write(data, 0, data.Length);
                fs.Flush();
            }
        }
    }

    /// <summary>
    /// DataTable导出到Excel的MemoryStream
    /// </summary>
    /// <param name="dtSource">源DataTable</param>
    /// <param name="strHeaderText">表头文本</param>
    /// <param name="sheetName">单元表名称</param>
    /// <returns></returns>
    public static MemoryStream Export(DataTable dtSource, string strHeaderText, string sheetName)
    {
        HSSFWorkbook workbook = new HSSFWorkbook();
        ISheet sheet = workbook.CreateSheet(sheetName);

        #region 右击文件 属性信息
        {
            DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
            dsi.Company = "安阳联通";
            workbook.DocumentSummaryInformation = dsi;

            SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
            si.Author = "Fankq"; //填加xls文件作者信息
            si.ApplicationName = "数据生成"; //填加xls文件创建程序信息
            si.LastAuthor = "Fankq"; //填加xls文件最后保存者信息
            si.Comments = ""; //填加xls文件作者信息
            si.Title = "数据导出"; //填加xls文件标题信息
            si.Subject = "数据导出";//填加文件主题信息
            si.CreateDateTime = DateTime.Now;
            workbook.SummaryInformation = si;
        }
        #endregion

        ICellStyle dateStyle = workbook.CreateCellStyle();
        IDataFormat format = workbook.CreateDataFormat();
        dateStyle.DataFormat = format.GetFormat("yyyy/M/d h:mm:ss");

        //取得列宽
        int[] arrColWidth = new int[dtSource.Columns.Count];
        foreach (DataColumn item in dtSource.Columns)
        {
            arrColWidth[item.Ordinal] = Encoding.GetEncoding(936).GetBytes(item.ColumnName.ToString()).Length;
        }
        for (int i = 0; i < dtSource.Rows.Count; i++)
        {
            for (int j = 0; j < dtSource.Columns.Count; j++)
            {
                int intTemp = Encoding.GetEncoding(936).GetBytes(dtSource.Rows[i][j].ToString()).Length;
                if (intTemp > arrColWidth[j] && intTemp < 100)
                {
                    arrColWidth[j] = intTemp;
                }
            }
        }



        int rowIndex = 0;

        foreach (DataRow row in dtSource.Rows)
        {
            #region 新建表，填充表头，填充列头，样式
            if (rowIndex == 65535 || rowIndex == 0)
            {
                if (rowIndex != 0)
                {
                    sheet = workbook.CreateSheet();
                }

                //#region 表头及样式
                //{
                //    IRow headerRow = sheet.CreateRow(0);
                //    headerRow.HeightInPoints = 25;
                //    headerRow.CreateCell(0).SetCellValue(strHeaderText);

                //    ICellStyle headStyle = workbook.CreateCellStyle();
                //    headStyle.Alignment = HorizontalAlignment.Center;
                //    IFont font = workbook.CreateFont();
                //    font.FontHeightInPoints = 20;
                //    font.Boldweight = 700;
                //    headStyle.SetFont(font);

                //    headerRow.GetCell(0).CellStyle = headStyle;

                //    sheet.AddMergedRegion(new CellRangeAddress(0, 0, 0, dtSource.Columns.Count - 1));
                //}
                //#endregion


                #region 列头及样式
                {
                    IRow headerRow = sheet.CreateRow(0);


                    ICellStyle headStyle = workbook.CreateCellStyle();
                    headStyle.Alignment = HorizontalAlignment.Center;
                    IFont font = workbook.CreateFont();
                    font.FontHeightInPoints = 10;
                    font.Boldweight = 700;
                    headStyle.SetFont(font);


                    foreach (DataColumn column in dtSource.Columns)
                    {
                        headerRow.CreateCell(column.Ordinal).SetCellValue(column.ColumnName);
                        headerRow.GetCell(column.Ordinal).CellStyle = headStyle;

                        //设置列宽
                        sheet.SetColumnWidth(column.Ordinal, (arrColWidth[column.Ordinal] + 1) * 256);

                    }
                }
                #endregion

                rowIndex = 1;
            }
            #endregion


            #region 填充内容
            IRow dataRow = sheet.CreateRow(rowIndex);
            foreach (DataColumn column in dtSource.Columns)
            {
                ICell newCell = dataRow.CreateCell(column.Ordinal);

                string drValue = row[column].ToString();

                switch (column.DataType.ToString())
                {
                    case "System.String"://字符串类型
                        newCell.SetCellValue(drValue.Trim());
                        break;
                    case "System.DateTime"://日期类型
                        DateTime dateV;
                        DateTime.TryParse(drValue.Trim(), out dateV);
                        newCell.SetCellValue(drValue.Trim());

                        newCell.CellStyle = dateStyle;//格式化显示
                        break;
                    case "System.Boolean"://布尔型
                        bool boolV = false;
                        bool.TryParse(drValue.Trim(), out boolV);
                        newCell.SetCellValue(boolV);
                        break;
                    case "System.Int16"://整型
                    case "System.Int32":
                    case "System.Int64":
                    case "System.Byte":
                        int intV = 0;
                        int.TryParse(drValue.Trim(), out intV);
                        newCell.SetCellValue(intV);
                        break;
                    case "System.Decimal"://浮点型
                    case "System.Double":
                        double doubV = 0;
                        double.TryParse(drValue.Trim(), out doubV);
                        newCell.SetCellValue(doubV);
                        break;
                    case "System.DBNull"://空值处理
                        newCell.SetCellValue("");
                        break;
                    default:
                        newCell.SetCellValue("");
                        break;
                }

            }
            #endregion

            rowIndex++;
        }


        using (MemoryStream ms = new MemoryStream())
        {
            workbook.Write(ms);
            ms.Flush();
            ms.Position = 0;

            //workbook.Dispose();//一般只用写这一个就OK了，他会遍历并释放所有资源，但当前版本有问题所以只释放sheet
            return ms;
        }

    }
    /// <summary>
    /// DataTable导出到Excel的MemoryStream 附加标题说明
    /// </summary>
    /// <param name="dtSource">源DataTable</param>
    /// <param name="strHeaderText">表头文本</param>
    /// <param name="sheetName">单元表名称</param>
    /// <returns></returns>
    public static MemoryStream Export(DataTable dtSource, string strHeaderText, List<List<string>> addTitles, string sheetName)
    {
        HSSFWorkbook workbook = new HSSFWorkbook();
        ISheet sheet = workbook.CreateSheet(sheetName);

        #region 右击文件 属性信息
        {
            DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
            dsi.Company = "安阳联通";
            workbook.DocumentSummaryInformation = dsi;

            SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
            si.Author = "Fankq"; //填加xls文件作者信息
            si.ApplicationName = "数据生成"; //填加xls文件创建程序信息
            si.LastAuthor = "Fankq"; //填加xls文件最后保存者信息
            si.Comments = ""; //填加xls文件作者信息
            si.Title = "数据导出"; //填加xls文件标题信息
            si.Subject = "数据导出";//填加文件主题信息
            si.CreateDateTime = DateTime.Now;
            workbook.SummaryInformation = si;
        }
        #endregion

        ICellStyle dateStyle = workbook.CreateCellStyle();
        IDataFormat format = workbook.CreateDataFormat();
        dateStyle.DataFormat = format.GetFormat("yyyy/M/d h:mm:ss");

        //取得列宽
        int[] arrColWidth = new int[dtSource.Columns.Count];
        foreach (DataColumn item in dtSource.Columns)
        {
            arrColWidth[item.Ordinal] = Encoding.GetEncoding(936).GetBytes(item.ColumnName.ToString()).Length;
        }
        for (int i = 0; i < dtSource.Rows.Count; i++)
        {
            for (int j = 0; j < dtSource.Columns.Count; j++)
            {
                int intTemp = Encoding.GetEncoding(936).GetBytes(dtSource.Rows[i][j].ToString()).Length;
                if (intTemp > arrColWidth[j] && intTemp < 100)
                {
                    arrColWidth[j] = intTemp;
                }
            }
        }



        int rowIndex = 0;

        foreach (DataRow row in dtSource.Rows)
        {
            #region 新建表，填充表头，填充列头，样式
            if (rowIndex == 65535 || rowIndex == 0)
            {
                if (rowIndex != 0)
                {
                    sheet = workbook.CreateSheet();
                }

                #region 表头及样式
                {
                    IRow headerRow = sheet.CreateRow(0);
                    headerRow.HeightInPoints = 18;
                    headerRow.CreateCell(0).SetCellValue(strHeaderText);

                    ICellStyle headStyle = workbook.CreateCellStyle();
                    headStyle.Alignment = HorizontalAlignment.Center;
                    IFont font = workbook.CreateFont();
                    font.FontHeightInPoints = 13;
                    font.Boldweight = 700;
                    headStyle.SetFont(font);
                    headStyle.BorderLeft = BorderStyle.Thin;
                    headStyle.BorderRight = BorderStyle.Thin;
                    headStyle.BorderTop = BorderStyle.Thin;
                    headStyle.BorderBottom = BorderStyle.Thin;
                    headerRow.GetCell(0).CellStyle = headStyle;

                    sheet.AddMergedRegion(new CellRangeAddress(0, 0, 0, dtSource.Columns.Count - 1));
                }
                #endregion
                #region 附加表头第一列样式
                ICellStyle addColumn1Style = workbook.CreateCellStyle();
                addColumn1Style.BorderLeft = BorderStyle.Thin;
                addColumn1Style.BorderRight = BorderStyle.Thin;
                addColumn1Style.BorderTop = BorderStyle.Thin;
                addColumn1Style.BorderBottom = BorderStyle.Thin;
                addColumn1Style.WrapText = true;
                IFont font1 = workbook.CreateFont();
                font1.FontHeightInPoints = 10;
                addColumn1Style.SetFont(font1);
                addColumn1Style.FillForegroundColor = HSSFColor.Indigo.Index;
                addColumn1Style.FillPattern = FillPattern.SolidForeground;
                #endregion

                #region 列头及样式
                {
                    IRow headerRow = sheet.CreateRow(1);

                    headerRow.HeightInPoints = 25;
                    headerRow.Height = 100 * 6;
                    ICellStyle headStyle = workbook.CreateCellStyle();
                    headStyle.Alignment = HorizontalAlignment.Center;
                    headStyle.VerticalAlignment = VerticalAlignment.Center;
                    IFont font = workbook.CreateFont();
                    font.FontHeightInPoints = 10;
                    headStyle.WrapText = true;
                    headStyle.SetFont(font);
                    headStyle.BorderLeft = BorderStyle.Thin;
                    headStyle.BorderRight = BorderStyle.Thin;
                    headStyle.BorderTop = BorderStyle.Thin;
                    headStyle.BorderBottom = BorderStyle.Thin;
                    //第一列 添加“属性中文名称”
                    headerRow.CreateCell(0).SetCellValue("属性中文名称");
                    headerRow.GetCell(0).CellStyle = addColumn1Style;
                    foreach (DataColumn column in dtSource.Columns)
                    {
                        headerRow.CreateCell(column.Ordinal + 1).SetCellValue(column.ColumnName);
                        headerRow.GetCell(column.Ordinal + 1).CellStyle = headStyle;

                        //设置列宽
                        sheet.SetColumnWidth(column.Ordinal, 15 * 256);

                    }
                    rowIndex = 2;
                    foreach (List<string> item in addTitles)
                    {
                        IRow addRow = sheet.CreateRow(rowIndex++);
                        for (int i = 0; i < item.Count; i++)
                        {
                            addRow.CreateCell(i + 1).SetCellValue(item[i]);
                        }
                    }
                }
                #endregion

                rowIndex = 4;
            }
            #endregion


            #region 填充内容
            IRow dataRow = sheet.CreateRow(rowIndex);
            foreach (DataColumn column in dtSource.Columns)
            {
                ICell newCell = dataRow.CreateCell(column.Ordinal + 1);

                string drValue = row[column].ToString();

                switch (column.DataType.ToString())
                {
                    case "System.String"://字符串类型
                        newCell.SetCellValue(drValue.Trim());
                        break;
                    case "System.DateTime"://日期类型
                        DateTime dateV;
                        DateTime.TryParse(drValue.Trim(), out dateV);
                        newCell.SetCellValue(drValue.Trim());

                        newCell.CellStyle = dateStyle;//格式化显示
                        break;
                    case "System.Boolean"://布尔型
                        bool boolV = false;
                        bool.TryParse(drValue.Trim(), out boolV);
                        newCell.SetCellValue(boolV);
                        break;
                    case "System.Int16"://整型
                    case "System.Int32":
                    case "System.Int64":
                    case "System.Byte":
                        int intV = 0;
                        int.TryParse(drValue.Trim(), out intV);
                        newCell.SetCellValue(intV);
                        break;
                    case "System.Decimal"://浮点型
                    case "System.Double":
                        double doubV = 0;
                        double.TryParse(drValue.Trim(), out doubV);
                        newCell.SetCellValue(doubV);
                        break;
                    case "System.DBNull"://空值处理
                        newCell.SetCellValue("");
                        break;
                    default:
                        newCell.SetCellValue("");
                        break;
                }

            }
            #endregion

            rowIndex++;
        }


        using (MemoryStream ms = new MemoryStream())
        {
            workbook.Write(ms);
            ms.Flush();
            ms.Position = 0;

            //workbook.Dispose();//一般只用写这一个就OK了，他会遍历并释放所有资源，但当前版本有问题所以只释放sheet
            return ms;
        }

    }
    /// <summary>
    /// 导出EXCEL多个单元表
    /// </summary>
    /// <param name="dataSources">datatable数组</param>
    /// <returns></returns>
    private static MemoryStream Export(DataTable[] dataSources)
    {
        HSSFWorkbook workbook = new HSSFWorkbook();
        #region 右击文件 属性信息
        {
            DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
            dsi.Company = "安阳联通";
            workbook.DocumentSummaryInformation = dsi;

            SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
            si.Author = "Fankq"; //填加xls文件作者信息
            si.ApplicationName = "数据生成"; //填加xls文件创建程序信息
            si.LastAuthor = "Fankq"; //填加xls文件最后保存者信息
            si.Comments = ""; //填加xls文件作者信息
            si.Title = "数据导出"; //填加xls文件标题信息
            si.Subject = "数据导出";//填加文件主题信息
            si.CreateDateTime = DateTime.Now;
            workbook.SummaryInformation = si;
        }
        #endregion
        #region 设置时间显示格式
        ICellStyle dateStyle = workbook.CreateCellStyle();
        IDataFormat format = workbook.CreateDataFormat();
        dateStyle.DataFormat = format.GetFormat("yyyy/M/d h:mm:ss");
        dateStyle.BorderLeft = BorderStyle.Thin;
        dateStyle.BorderRight = BorderStyle.Thin;
        dateStyle.BorderTop = BorderStyle.Thin;
        dateStyle.BorderBottom = BorderStyle.Thin;

        #endregion
        #region 标题样式及内容样式
        ICellStyle headStyle = workbook.CreateCellStyle();
        headStyle.Alignment = HorizontalAlignment.Center;
        IFont font = workbook.CreateFont();
        font.FontHeightInPoints = 10;
        font.Boldweight = 700;
        headStyle.SetFont(font);
        headStyle.BorderLeft = BorderStyle.Thin;
        headStyle.BorderRight = BorderStyle.Thin;
        headStyle.BorderTop = BorderStyle.Thin;
        headStyle.BorderBottom = BorderStyle.Thin;

        ICellStyle contentStyle = workbook.CreateCellStyle();
        contentStyle.Alignment = HorizontalAlignment.Left;
        contentStyle.WrapText = true;
        contentStyle.BorderLeft = BorderStyle.Thin;
        contentStyle.BorderRight = BorderStyle.Thin;
        contentStyle.BorderTop = BorderStyle.Thin;
        contentStyle.BorderBottom = BorderStyle.Thin;
        #endregion
        foreach (DataTable dt in dataSources)
        {
            string sheetName = dt.TableName;
            ISheet sheet = workbook.CreateSheet(sheetName);
            #region 取得列宽
            int[] arrColWidth = new int[dt.Columns.Count];
            foreach (DataColumn item in dt.Columns)
            {
                arrColWidth[item.Ordinal] = Encoding.GetEncoding(936).GetBytes(item.ColumnName.ToString()).Length;
            }
            for (int i = 0; i < 1; i++)//只取第一行列宽
            {
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    int intTemp = Encoding.GetEncoding(936).GetBytes(dt.Rows[i][j].ToString()).Length;
                    if (intTemp > arrColWidth[j] && intTemp < 100)
                    {
                        arrColWidth[j] = intTemp;
                    }
                }
            }
            #endregion
            //遍历每行
            int rowIndex = 0;
            foreach (DataRow row in dt.Rows)
            {
                #region 生成标题行
                if (rowIndex == 65535 || rowIndex == 0)
                {
                    if (rowIndex != 0)//达到上限时新建sheet
                    {
                        sheet = workbook.CreateSheet();
                    }

                    IRow headerRow = sheet.CreateRow(0);
                    headerRow.Height = 100 * 4;
                    foreach (DataColumn column in dt.Columns)
                    {
                        headerRow.CreateCell(column.Ordinal).SetCellValue(column.ColumnName);
                        headerRow.GetCell(column.Ordinal).CellStyle = headStyle;
                        //设置列宽
                        sheet.SetColumnWidth(column.Ordinal, (arrColWidth[column.Ordinal] + 1) * 256);

                    }

                    rowIndex = 1;
                }
                #endregion
                #region 填充内容
                IRow dataRow = sheet.CreateRow(rowIndex);
                foreach (DataColumn column in dt.Columns)
                {
                    ICell newCell = dataRow.CreateCell(column.Ordinal);
                    string drValue = row[column].ToString();
                    switch (column.DataType.ToString())
                    {
                        case "System.String"://字符串类型
                            newCell.SetCellValue(drValue.Trim());
                            break;
                        case "System.DateTime"://日期类型
                            DateTime dateV;
                            DateTime.TryParse(drValue.Trim(), out dateV);
                            newCell.SetCellValue(drValue.Trim());

                            newCell.CellStyle = dateStyle;//格式化显示
                            break;
                        case "System.Boolean"://布尔型
                            bool boolV = false;
                            bool.TryParse(drValue.Trim(), out boolV);
                            newCell.SetCellValue(boolV);
                            break;
                        case "System.Int16"://整型
                        case "System.Int32":
                        case "System.Int64":
                        case "System.Byte":
                            int intV = 0;
                            int.TryParse(drValue.Trim(), out intV);
                            newCell.SetCellValue(intV);
                            break;
                        case "System.Decimal"://浮点型
                        case "System.Double":
                            double doubV = 0;
                            double.TryParse(drValue.Trim(), out doubV);
                            newCell.SetCellValue(doubV);
                            break;
                        case "System.DBNull"://空值处理
                            newCell.SetCellValue("");
                            break;
                        default:
                            newCell.SetCellValue("");
                            break;
                    }
                    newCell.CellStyle = contentStyle;
                }
                #endregion
                rowIndex++;
            }
        }
        using (MemoryStream ms = new MemoryStream())
        {
            workbook.Write(ms);
            ms.Flush();
            ms.Position = 0;
            //workbook.Dispose();//一般只用写这一个就OK了，他会遍历并释放所有资源，但当前版本有问题所以只释放sheet
            return ms;
        }
    }
    /// <summary>
    /// 使用模板导出自己EXCEL
    /// </summary>
    /// <param name="dataSources">datatable数组</param>
    /// <returns></returns>
    private static MemoryStream ExportByTmp(DataTable[] dataSources)
    {
        HttpContext context = HttpContext.Current;
        FileStream file = new FileStream(context.Server.MapPath("~") + @"Template/ImportTmp.xls", FileMode.Open, FileAccess.Read);
        HSSFWorkbook workbook = new HSSFWorkbook(file);
        #region 右击文件 属性信息
        {
            DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
            dsi.Company = "安阳联通";
            workbook.DocumentSummaryInformation = dsi;

            SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
            si.Author = "Fankq"; //填加xls文件作者信息
            si.ApplicationName = "数据生成"; //填加xls文件创建程序信息
            si.LastAuthor = "Fankq"; //填加xls文件最后保存者信息
            si.Comments = ""; //填加xls文件作者信息
            si.Title = "数据导出"; //填加xls文件标题信息
            si.Subject = "数据导出";//填加文件主题信息
            si.CreateDateTime = DateTime.Now;
            workbook.SummaryInformation = si;
        }
        #endregion
        #region 设置时间显示格式
        ICellStyle dateStyle = workbook.CreateCellStyle();
        IDataFormat format = workbook.CreateDataFormat();
        dateStyle.DataFormat = format.GetFormat("yyyy/M/d h:mm:ss");
        dateStyle.BorderLeft = BorderStyle.Thin;
        dateStyle.BorderRight = BorderStyle.Thin;
        dateStyle.BorderTop = BorderStyle.Thin;
        dateStyle.BorderBottom = BorderStyle.Thin;

        #endregion
        #region 内容格式
        ICellStyle contentStyle = workbook.CreateCellStyle();
        contentStyle.Alignment = HorizontalAlignment.Left;
        contentStyle.BorderLeft = BorderStyle.Thin;
        contentStyle.BorderRight = BorderStyle.Thin;
        contentStyle.BorderTop = BorderStyle.Thin;
        contentStyle.BorderBottom = BorderStyle.Thin;
        #endregion

        foreach (DataTable dt in dataSources)
        {
            int rowIndex = 4;
            string sheetName = dt.TableName;
            ISheet sheet = workbook.GetSheet(sheetName);
            if (sheetName == "铁塔检查信息")
                rowIndex = 5;
            //遍历每行
            foreach (DataRow row in dt.Rows)
            {
                #region 填充内容
                IRow dataRow = sheet.CreateRow(rowIndex);
                foreach (DataColumn column in dt.Columns)
                {
                    ICell newCell = dataRow.CreateCell(column.Ordinal + 1);
                    string drValue = row[column].ToString();
                    switch (column.DataType.ToString())
                    {
                        case "System.String"://字符串类型
                            newCell.SetCellValue(drValue.Trim());
                            break;
                        case "System.DateTime"://日期类型
                            DateTime dateV;
                            DateTime.TryParse(drValue.Trim(), out dateV);
                            newCell.SetCellValue(drValue.Trim());

                            newCell.CellStyle = dateStyle;//格式化显示
                            break;
                        case "System.Boolean"://布尔型
                            bool boolV = false;
                            bool.TryParse(drValue.Trim(), out boolV);
                            newCell.SetCellValue(boolV);
                            break;
                        case "System.Int16"://整型
                        case "System.Int32":
                        case "System.Int64":
                        case "System.Byte":
                            int intV = 0;
                            int.TryParse(drValue.Trim(), out intV);
                            newCell.SetCellValue(intV);
                            break;
                        case "System.Decimal"://浮点型
                        case "System.Double":
                            double doubV = 0;
                            double.TryParse(drValue.Trim(), out doubV);
                            newCell.SetCellValue(doubV);
                            break;
                        case "System.DBNull"://空值处理
                            newCell.SetCellValue("");
                            break;
                        default:
                            newCell.SetCellValue("");
                            break;
                    }
                    newCell.CellStyle = contentStyle;
                }
                #endregion
                rowIndex++;
            }
        }
        using (MemoryStream ms = new MemoryStream())
        {
            workbook.Write(ms);
            ms.Flush();
            ms.Position = 0;
            //workbook.Dispose();//一般只用写这一个就OK了，他会遍历并释放所有资源，但当前版本有问题所以只释放sheet
            return ms;
        }
    }
    /// <summary>
    /// 用于Web导出
    /// </summary>
    /// <param name="dtSource">源DataTable</param>
    /// <param name="strHeaderText">表头文本</param>
    /// <param name="strFileName">文件名</param>
    /// <param name="sheetName">单元表名称</param>
    public static void ExportByWeb(DataTable dtSource, string strHeaderText, string strFileName, string sheetName)
    {

        HttpContext curContext = HttpContext.Current;

        // 设置编码和附件格式
        curContext.Response.ContentType = "application/vnd.ms-excel";
        curContext.Response.ContentEncoding = Encoding.UTF8;
        curContext.Response.Charset = "";
        curContext.Response.AppendHeader("Content-Disposition",
            "attachment;filename=" + HttpUtility.UrlEncode(strFileName, Encoding.UTF8));
        curContext.Response.Clear();
        curContext.Response.BinaryWrite(Export(dtSource, strHeaderText, sheetName).GetBuffer());
        curContext.Response.End();

    }/// <summary>
     /// 用于Web导出
     /// </summary>
     /// <param name="dtSource">源DataTable</param>
     /// <param name="strHeaderText">表头文本</param>
     /// <param name="strFileName">文件名</param>
     /// <param name="sheetName">单元表名称</param>
    public static void ExportByWeb(DataTable dtSource, string strHeaderText, List<List<string>> addTitles, string strFileName, string sheetName)
    {

        HttpContext curContext = HttpContext.Current;

        // 设置编码和附件格式
        curContext.Response.ContentType = "application/vnd.ms-excel";
        curContext.Response.ContentEncoding = Encoding.UTF8;
        curContext.Response.Charset = "";
        curContext.Response.AppendHeader("Content-Disposition",
            "attachment;filename=" + HttpUtility.UrlEncode(strFileName, Encoding.UTF8));
        curContext.Response.Clear();
        curContext.Response.BinaryWrite(Export(dtSource, strHeaderText, addTitles, sheetName).GetBuffer());
        curContext.Response.End();

    }
    /// <summary>
    /// 导出Excel多个单元表
    /// </summary>
    /// <param name="dtSources">源DataTable数组</param>
    /// <param name="strFileName">文件名</param>
    public static void ExportByWeb(DataTable[] dtSources, string strFileName)
    {

        HttpContext curContext = HttpContext.Current;

        // 设置编码和附件格式
        curContext.Response.ContentType = "application/vnd.ms-excel";
        curContext.Response.ContentEncoding = Encoding.UTF8;
        curContext.Response.Charset = "";
        curContext.Response.AppendHeader("Content-Disposition",
            "attachment;filename=" + HttpUtility.UrlEncode(strFileName, Encoding.UTF8));
        curContext.Response.Clear();
        curContext.Response.BinaryWrite(Export(dtSources).GetBuffer());
        curContext.Response.End();

    }
    /// <summary>
    /// 使用模板导出Excel多个单元表
    /// </summary>
    /// <param name="dtSources">源DataTable数组</param>
    /// <param name="strFileName">文件名</param>
    public static void ExportByTmp(DataTable[] dtSources, string strFileName)
    {

        HttpContext curContext = HttpContext.Current;

        // 设置编码和附件格式
        curContext.Response.ContentType = "application/vnd.ms-excel";
        curContext.Response.ContentEncoding = Encoding.UTF8;
        curContext.Response.Charset = "";
        curContext.Response.AppendHeader("Content-Disposition",
            "attachment;filename=" + HttpUtility.UrlEncode(strFileName, Encoding.UTF8));
        curContext.Response.Clear();
        curContext.Response.BinaryWrite(ExportByTmp(dtSources).GetBuffer());
        curContext.Response.End();

    }

   
   
    /// <summary>
    /// 通过文件路径生成工作表
    /// </summary>
    /// <param name="filePath">文件路径</param>
    /// <returns></returns>
    public static IWorkbook CreateWorkbook(string filePath)
    {
        IWorkbook workbook;
        using (Stream file = new FileStream(filePath, FileMode.Open, FileAccess.Read))
        {
            workbook = WorkbookFactory.Create(file);
        }
        return workbook;
    }
    /// <summary>
    /// 判断文件是否存在
    /// </summary>
    /// <param name="FilePath">文件路径</param>
    /// <returns></returns>
    public static int CheckFileExists(string FilePath)
    {
        if (!File.Exists(FilePath))
        {
            return -1;
        }
        else
            return 1;
    }
    /// <summary>
    /// 返回sheet在excel中索引值。-1为不存在
    /// </summary>
    /// <param name="workbook"></param>
    /// <param name="sheetName"></param>
    /// <returns></returns>
    public static int CheckSheetContains(IWorkbook workbook, string sheetName)
    {
        return workbook.GetSheetIndex(sheetName);
    }
    /// <summary>
    /// 返回sheet在excel中索引值。-1为不存在
    /// </summary>
    /// <param name="FilePath">文件路径</param>
    /// <param name="sheetName">单元表名</param>
    /// <returns></returns>
    public static int CheckSheetContains(string FilePath, string sheetName)
    {
        IWorkbook workbook = CreateWorkbook(FilePath);
        return workbook.GetSheetIndex(sheetName);
    }
    /// <summary>读取excel
    /// 默认第一行为标头
    /// </summary>
    /// <param name="strFileName">excel文档路径</param>
    /// <returns></returns>
    public static DataTable Import(string strFileName)
    {
        DataTable dt = new DataTable();

        HSSFWorkbook hssfworkbook;
        using (FileStream file = new FileStream(strFileName, FileMode.Open, FileAccess.Read))
        {
            hssfworkbook = new HSSFWorkbook(file);
        }
        ISheet sheet = hssfworkbook.GetSheetAt(0);
        System.Collections.IEnumerator rows = sheet.GetRowEnumerator();

        IRow headerRow = sheet.GetRow(0);
        int cellCount = headerRow.LastCellNum;

        for (int j = 0; j < cellCount; j++)
        {
            ICell cell = headerRow.GetCell(j);
            dt.Columns.Add(cell.ToString());
        }

        for (int i = (sheet.FirstRowNum + 1); i <= sheet.LastRowNum; i++)
        {
            IRow row = sheet.GetRow(i);
            DataRow dataRow = dt.NewRow();

            for (int j = row.FirstCellNum; j < cellCount; j++)
            {
                if (row.GetCell(j) != null)
                    dataRow[j] = row.GetCell(j).ToString();
            }

            dt.Rows.Add(dataRow);
        }
        return dt;
    }
    /// <summary>
    /// 将excel中的数据导入到DataTable中
    /// </summary>
    /// <param name="sheetName">excel工作薄sheet的名称</param>
    /// <param name="isFirstRowColumn">第一行是否是DataTable的列名</param>
    /// <returns>返回的DataTable</returns>
    public DataTable ExcelToDataTable(string sheetName, bool isFirstRowColumn, string fileName, IWorkbook workbook)
    {

        ISheet sheet = null;
        DataTable data = new DataTable();
        int startRow = 0;
        Stream fs = new FileStream(fileName, FileMode.Open, FileAccess.Read);
        try
        {
            fs = new FileStream(fileName, FileMode.Open, FileAccess.Read);
            if (fileName.IndexOf(".xlsx") > 0) // 2007版本
                workbook = new XSSFWorkbook(fs);
            else if (fileName.IndexOf(".xls") > 0) // 2003版本
                workbook = new HSSFWorkbook(fs);
            if (sheetName != null)
            {
                sheet = workbook.GetSheet(sheetName);
            }
            else
            {
                sheet = workbook.GetSheetAt(0);
            }
            if (sheet != null)
            {
                IRow firstRow = sheet.GetRow(0);
                int cellCount = firstRow.LastCellNum; //一行最后一个cell的编号 即总的列数

                if (isFirstRowColumn)
                {
                    for (int i = firstRow.FirstCellNum; i < cellCount; ++i)
                    {
                        DataColumn column = new DataColumn(firstRow.GetCell(i).StringCellValue);
                        data.Columns.Add(column);
                    }
                    startRow = sheet.FirstRowNum + 1;
                }
                else
                {
                    startRow = sheet.FirstRowNum;
                }

                //最后一列的标号
                int rowCount = sheet.LastRowNum;
                for (int i = startRow; i <= rowCount; ++i)
                {
                    IRow row = sheet.GetRow(i);
                    if (row == null) continue; //没有数据的行默认是null　　　　　　　

                    DataRow dataRow = data.NewRow();
                    for (int j = row.FirstCellNum; j < cellCount; ++j)
                    {
                        if (row.GetCell(j) != null) //同理，没有数据的单元格都默认是null
                            dataRow[j] = row.GetCell(j).ToString();
                    }
                    data.Rows.Add(dataRow);
                }
            }

            return data;
        }
        catch (Exception ex)
        {
            Console.WriteLine("Exception: " + ex.Message);
            return null;
        }
    }
    /// <summary>  
    /// 从Excel中获取数据到DataTable  
    /// </summary>  
    /// <param name="workbook">要处理的工作薄</param>  
    /// <param name="SheetName">要获取数据的工作表名称</param>  
    /// <param name="HeaderRowIndex">工作表标题行所在行号(从0开始)</param>  
    /// <returns></returns>  
    public static DataTable RenderDataTableFromExcel(IWorkbook workbook, string SheetName, int HeaderRowIndex)
    {
        ISheet sheet = workbook.GetSheet(SheetName);
        DataTable table = new DataTable();
        try
        {
            IRow headerRow = sheet.GetRow(HeaderRowIndex);
            int cellCount = headerRow.LastCellNum;

            for (int i = headerRow.FirstCellNum; i < cellCount; i++)
            {
                DataColumn column = new DataColumn(headerRow.GetCell(i).StringCellValue);
                table.Columns.Add(column);
            }

            int rowCount = sheet.LastRowNum;

            #region 循环各行各列,写入数据到DataTable
            for (int i = (sheet.FirstRowNum + 1); i < sheet.LastRowNum; i++)
            {
                IRow row = sheet.GetRow(i);
                DataRow dataRow = table.NewRow();
                for (int j = row.FirstCellNum; j < cellCount; j++)
                {
                    ICell cell = row.GetCell(j);
                    if (cell == null)
                    {
                        dataRow[j] = null;
                    }
                    else
                    {
                        //dataRow[j] = cell.ToString();  
                        switch (cell.CellType)
                        {
                            case CellType.Blank:
                                dataRow[j] = null;
                                break;
                            case CellType.Boolean:
                                dataRow[j] = cell.BooleanCellValue;
                                break;
                            case CellType.Numeric:
                                if (DateUtil.IsCellDateFormatted(cell))
                                    dataRow[j] = cell.DateCellValue.ToString("yyyy/M/d");
                                else
                                    dataRow[j] = cell.NumericCellValue.ToString().Trim();
                                break;
                            case CellType.String:
                                dataRow[j] = cell.StringCellValue;
                                break;
                            case CellType.Error:
                                dataRow[j] = cell.ErrorCellValue;
                                break;
                            case CellType.Formula:
                            default:
                                dataRow[j] = "=" + cell.CellFormula;
                                break;
                        }
                    }
                }
                table.Rows.Add(dataRow);
                //dataRow[j] = row.GetCell(j).ToString();  
            }
            #endregion
        }
        catch (System.Exception ex)
        {
            table.Clear();
            table.Columns.Clear();
            table.Columns.Add("出错了");
            DataRow dr = table.NewRow();
            dr[0] = ex.Message;
            table.Rows.Add(dr);
            return table;
        }
        finally
        {
            //sheet.Dispose();  
            workbook = null;
            sheet = null;
        }
        #region 清除最后的空行
        for (int i = table.Rows.Count - 1; i > 0; i--)
        {
            bool isnull = true;
            for (int j = 0; j < table.Columns.Count; j++)
            {
                if (table.Rows[i][j] != null)
                {
                    if (table.Rows[i][j].ToString() != "")
                    {
                        isnull = false;
                        break;
                    }
                }
            }
            if (isnull)
            {
                table.Rows[i].Delete();
            }
        }
        #endregion
        return table;
    }
    /// <summary>  
    /// 从Excel中获取数据到DataTable  
    /// </summary>  
    /// <param name="workbook">要处理的工作薄</param>  
    /// <param name="SheetName">要获取数据的工作表名称</param>  
    /// <param name="HeaderRowIndex">工作表标题行所在行号(从0开始)</param>  
    /// <param name="FetchTitle">是否获取标题</param>  
    /// <param name="StartRowIndex">数据开始行号(从0开始)</param>  
    /// <param name="StartCellIndex">数据开始列号(从0开始)</param>  
    /// <returns></returns>  
    public static DataTable RenderDataTableFromExcel(IWorkbook workbook, string SheetName, int HeaderRowIndex, bool FetchTitleFlag, int StartRowIndex, int StartCellIndex)
    {
        ISheet sheet = workbook.GetSheet(SheetName);
        DataTable table = new DataTable(SheetName);
        try
        {
            IRow headerRow = sheet.GetRow(HeaderRowIndex);
            int cellCount = headerRow.LastCellNum;
            //获取列名
            for (int i = StartCellIndex; i < cellCount; i++)
            {
                string columnName = "column" + i.ToString();
                if (FetchTitleFlag)
                    columnName = headerRow.GetCell(i).StringCellValue;
                columnName = string.IsNullOrEmpty(columnName) ? "column" + i.ToString() : columnName;
                table.Columns.Add(columnName);
            }

            int rowCount = sheet.LastRowNum;

            #region 循环各行各列,写入数据到DataTable
            for (int i = StartRowIndex; i < sheet.LastRowNum; i++)
            {
                IRow row = sheet.GetRow(i);
                DataRow dataRow = table.NewRow();
                for (int j = StartCellIndex; j < cellCount; j++)
                {
                    int columnIndex = j - StartCellIndex;
                    ICell cell = row.GetCell(j);
                    if (cell == null)
                    {
                        dataRow[columnIndex] = null;
                    }
                    else
                    {
                        //dataRow[j] = cell.ToString();  
                        switch (cell.CellType)
                        {
                            case CellType.Blank:
                                dataRow[columnIndex] = null;
                                break;
                            case CellType.Boolean:
                                dataRow[columnIndex] = cell.BooleanCellValue;
                                break;
                            case CellType.Numeric:
                                if (DateUtil.IsCellDateFormatted(cell))
                                    dataRow[columnIndex] = cell.DateCellValue.ToString("yyyy/M/d");
                                else
                                    dataRow[columnIndex] = cell.NumericCellValue.ToString().Trim();
                                break;
                            case CellType.String:
                                dataRow[columnIndex] = cell.StringCellValue;
                                break;
                            case CellType.Error:
                                dataRow[columnIndex] = cell.ErrorCellValue;
                                break;
                            case CellType.Formula:
                            default:
                                dataRow[columnIndex] = "=" + cell.CellFormula;
                                break;
                        }
                    }
                }
                table.Rows.Add(dataRow);
                //dataRow[j] = row.GetCell(j).ToString();  
            }
            #endregion

        }
        catch (System.Exception ex)
        {
            table.Clear();
            table.Columns.Clear();
            table.Columns.Add("Error");
            table.TableName = "Error";
            DataRow dr = table.NewRow();
            dr[0] = "单元表:\"" + SheetName + "\"出错，错误信息为：" + ex.Message;
            table.Rows.Add(dr);
            return table;
        }
        finally
        {
            //sheet.Dispose();  
            workbook = null;
            sheet = null;
        }
        #region 清除最后的空行
        for (int i = table.Rows.Count - 1; i > 0; i--)
        {
            bool isnull = true;
            for (int j = 0; j < table.Columns.Count; j++)
            {
                if (table.Rows[i][j] != null)
                {
                    if (table.Rows[i][j].ToString() != "")
                    {
                        isnull = false;
                        break;
                    }
                }
            }
            if (isnull)
            {
                table.Rows[i].Delete();
            }
        }
        #endregion
        return table;
    }
    /// <summary>  
    /// 从Excel中获取数据到DataTable  
    /// </summary>  
    /// <param name="FilePath">文件路径</param>  
    /// <param name="SheetName">要获取数据的工作表名称</param>  
    /// <param name="HeaderRowIndex">工作表标题行所在行号(从0开始)</param>  
    /// <param name="FetchTitle">是否获取标题</param>  
    /// <param name="StartRowIndex">数据开始行号(从0开始)</param>  
    /// <param name="StartCellIndex">数据开始列号(从0开始)</param>  
    /// <returns></returns>  
    public static DataTable RenderDataTableFromExcel(string FilePath, string SheetName, int HeaderRowIndex, bool FetchTitleFlag, int StartRowIndex, int StartCellIndex)
    {
        IWorkbook workbook = CreateWorkbook(FilePath);
        ISheet sheet = workbook.GetSheet(SheetName);
        DataTable table = new DataTable(SheetName);
        try
        {
            IRow headerRow = sheet.GetRow(HeaderRowIndex);
            int cellCount = headerRow.LastCellNum;
            //获取列名
            for (int i = StartCellIndex; i < cellCount; i++)
            {
                string columnName = "column" + i.ToString();
                if (FetchTitleFlag)
                    columnName = headerRow.GetCell(i).StringCellValue;
                columnName = string.IsNullOrEmpty(columnName) ? "column" + i.ToString() : columnName;
                table.Columns.Add(columnName);
            }

            int rowCount = sheet.LastRowNum;

            #region 循环各行各列,写入数据到DataTable
            for (int i = StartRowIndex; i < sheet.LastRowNum + 1; i++)
            {
                IRow row = sheet.GetRow(i);
                DataRow dataRow = table.NewRow();
                for (int j = StartCellIndex; j < cellCount; j++)
                {
                    int columnIndex = j - StartCellIndex;
                    ICell cell = row.GetCell(j);
                    if (cell == null)
                    {
                        dataRow[columnIndex] = null;
                    }
                    else
                    {
                        dataRow[columnIndex] = cell.ToString();
                        switch (cell.CellType)
                        {
                            case CellType.Blank:
                                dataRow[columnIndex] = null;
                                break;
                            case CellType.Boolean:
                                dataRow[columnIndex] = cell.BooleanCellValue;
                                break;
                            case CellType.Numeric:
                                if (DateUtil.IsCellDateFormatted(cell))
                                    dataRow[columnIndex] = cell.DateCellValue.ToString("yyyy/M/d");
                                else
                                    dataRow[columnIndex] = cell.NumericCellValue.ToString().Trim(); //cell.ToString().Trim();
                                break;
                            case CellType.String:
                                dataRow[columnIndex] = cell.StringCellValue.Trim();
                                break;
                            case CellType.Error:
                                dataRow[columnIndex] = cell.ErrorCellValue;
                                break;
                            case CellType.Formula:
                                //dataRow[columnIndex] = cell.NumericCellValue.ToString().Trim();
                                //计算公式
                                IFormulaEvaluator e = workbook.GetCreationHelper().CreateFormulaEvaluator();
                                dataRow[columnIndex] = e.Evaluate(cell).NumberValue;
                                break;
                            default:
                                dataRow[columnIndex] = cell.StringCellValue;
                                break;
                        }
                    }
                }
                table.Rows.Add(dataRow);
                //dataRow[j] = row.GetCell(j).ToString();  
            }
            #endregion

        }
        catch (System.Exception ex)
        {
            table.Clear();
            table.Columns.Clear();
            table.Columns.Add("Error");
            table.TableName = "Error";
            DataRow dr = table.NewRow();
            dr[0] = "单元表:“" + SheetName + "”出错，错误信息为：" + ex.Message;
            table.Rows.Add(dr);
            return table;
        }
        finally
        {
            //sheet.Dispose();  
            workbook = null;
            sheet = null;
        }
        #region 清除最后的空行
        for (int i = table.Rows.Count - 1; i > 0; i--)
        {
            bool isnull = true;
            for (int j = 0; j < table.Columns.Count; j++)
            {
                if (table.Rows[i][j] != null)
                {
                    if (table.Rows[i][j].ToString() != "")
                    {
                        isnull = false;
                        break;
                    }
                }
            }
            if (isnull)
            {
                table.Rows[i].Delete();
            }
        }
        #endregion
        return table;
    }
    /// <summary>  
    /// 从Excel中获取数据到DataTable  
    /// </summary>  
    /// <param name="FilePath">文件路径</param>  
    /// <param name="SheetName">要获取数据的工作表名称</param>  
    /// <param name="HeaderRowIndex">工作表标题行所在行号(从0开始)</param>  
    /// <param name="FetchTitle">是否获取标题</param>  
    /// <param name="StartRowIndex">数据开始行号(从0开始)</param>  
    /// <param name="StartCellIndex">数据开始列号(从0开始)</param>  
    /// <param name="DateFormat">日期格式</param>
    /// <returns></returns>
    public static DataTable RenderDataTableFromExcel(string FilePath, string SheetName, int HeaderRowIndex, bool FetchTitleFlag, int StartRowIndex, int StartCellIndex, string DateFormat)
    {
        IWorkbook workbook = CreateWorkbook(FilePath);
        ISheet sheet = workbook.GetSheet(SheetName);
        DataTable table = new DataTable(SheetName);
        try
        {
            IRow headerRow = sheet.GetRow(HeaderRowIndex);
            int cellCount = headerRow.LastCellNum;
            //获取列名
            for (int i = StartCellIndex; i < cellCount; i++)
            {
                string columnName = "column" + i.ToString();
                if (FetchTitleFlag)
                    columnName = headerRow.GetCell(i).StringCellValue;
                columnName = string.IsNullOrEmpty(columnName) ? "column" + i.ToString() : columnName;
                table.Columns.Add(columnName);
            }

            int rowCount = sheet.LastRowNum;

            #region 循环各行各列,写入数据到DataTable
            for (int i = StartRowIndex; i < sheet.LastRowNum + 1; i++)
            {
                IRow row = sheet.GetRow(i);
                DataRow dataRow = table.NewRow();
                for (int j = StartCellIndex; j < cellCount; j++)
                {
                    int columnIndex = j - StartCellIndex;
                    ICell cell = row.GetCell(j);
                    if (cell == null)
                    {
                        dataRow[columnIndex] = null;
                    }
                    else
                    {
                        dataRow[columnIndex] = cell.ToString();
                        switch (cell.CellType)
                        {
                            case CellType.Blank:
                                dataRow[columnIndex] = null;
                                break;
                            case CellType.Boolean:
                                dataRow[columnIndex] = cell.BooleanCellValue;
                                break;
                            case CellType.Numeric:
                                if (DateUtil.IsCellDateFormatted(cell))
                                    dataRow[columnIndex] = cell.DateCellValue.ToString(DateFormat);
                                else
                                    dataRow[columnIndex] = cell.NumericCellValue.ToString().Trim(); //cell.ToString().Trim();
                                break;
                            case CellType.String:
                                dataRow[columnIndex] = cell.StringCellValue.Trim();
                                break;
                            case CellType.Error:
                                dataRow[columnIndex] = cell.ErrorCellValue;
                                break;
                            case CellType.Formula:
                                dataRow[columnIndex] = "=" + cell.CellFormula.Trim();
                                break;
                            default:
                                dataRow[columnIndex] = cell.StringCellValue;
                                break;
                        }
                    }
                }
                table.Rows.Add(dataRow);
            }
            #endregion

        }
        catch (System.Exception ex)
        {
            table.Clear();
            table.Columns.Clear();
            table.Columns.Add("Error");
            table.TableName = "Error";
            DataRow dr = table.NewRow();
            dr[0] = "单元表:“" + SheetName + "”出错，错误信息为：" + ex.Message;
            table.Rows.Add(dr);
            return table;
        }
        finally
        {
            //sheet.Dispose();  
            workbook = null;
            sheet = null;
        }
        #region 清除最后的空行
        for (int i = table.Rows.Count - 1; i > 0; i--)
        {
            bool isnull = true;
            for (int j = 0; j < table.Columns.Count; j++)
            {
                if (table.Rows[i][j] != null)
                {
                    if (table.Rows[i][j].ToString() != "")
                    {
                        isnull = false;
                        break;
                    }
                }
            }
            if (isnull)
            {
                table.Rows[i].Delete();
            }
        }
        #endregion
        return table;
    }
}