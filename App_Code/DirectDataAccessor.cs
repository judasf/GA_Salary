using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
	/// <summary>
	/// 数据库操作
	/// </summary>
	public class DirectDataAccessor
	{
		private static string ConnectString = "";

		static DirectDataAccessor()
		{
			ConnectString = ConfigurationManager.AppSettings["connectionString"];
		}

		static int connectionCount = 0;
		
		public static int ConnectionCount() 
		{
			return connectionCount;
		}
		
		private static string GetConnectString()
		{
			return ConnectString;
		}
		
		/// <summary>
        /// 执行一条SQL语句,如果失败则返回-1
		/// </summary>
		/// <param name="ExecuteSQL">Sql语句</param>
		/// <returns>返回本次执行影响的行数，如果失败则返回-1</returns>
		public static int Execute(string ExecuteSQL)
		{
			SqlCommand dsCommand = GetConnection(ExecuteSQL);
			dsCommand.Connection.Open();			
			
			SqlTransaction myTrans = dsCommand.Connection.BeginTransaction();	
			try 
			{			
				dsCommand.Transaction = myTrans;
				int InfectionRows = dsCommand.ExecuteNonQuery();
				myTrans.Commit();
				dsCommand.Connection.Close();
				return InfectionRows;
			}
			catch(Exception   ex) 
			{
				myTrans.Rollback();
				dsCommand.Connection.Close();
				//return -1;
                throw ex;
			}
			finally 
			{
				dsCommand.Connection.Close();
				dsCommand.Connection.Dispose();
				dsCommand.Dispose();
			}
		}

		private static SqlCommand GetConnection(string SQL) 
		{
			SqlCommand dsCommand = new SqlCommand();
			dsCommand.Connection =  new SqlConnection(GetConnectString());
			dsCommand.CommandType = CommandType.Text;
			dsCommand.CommandText = SQL;
			dsCommand.CommandTimeout = 120;
			dsCommand.Connection.StateChange += new StateChangeEventHandler(WhenStateChanged);
			return dsCommand;
		}

		private static void WhenStateChanged(object sender, StateChangeEventArgs args) 
		{
			if (args.CurrentState == ConnectionState.Closed) 
			{
				connectionCount--;
			}
			if (args.CurrentState == ConnectionState.Open) 
			{
				connectionCount++;
			}
		}

		public static DataSet QueryForDataSet(string QuerySQL) 
		{
			SqlCommand dsCommand = GetConnection(QuerySQL);
			SqlDataAdapter dataAdapter= new SqlDataAdapter();
			dataAdapter.SelectCommand =dsCommand;
			DataSet ds = new DataSet();
			dataAdapter.Fill(ds);
			dsCommand.Connection.Close();
			dsCommand.Connection.Dispose();
			dsCommand.Dispose();
			return ds;
		}
		
		public static DataSet QueryForDataSet(string QuerySQL,string TableName) 
		{
			SqlCommand dsCommand = GetConnection(QuerySQL);
			SqlDataAdapter dataAdapter= new SqlDataAdapter();
			dataAdapter.SelectCommand =dsCommand;
			DataSet ds = new DataSet();
			dataAdapter.Fill(ds,TableName);
			dsCommand.Connection.Close();
			dsCommand.Connection.Dispose();
			dsCommand.Dispose();
			return ds;
		}

		public static DataView QueryForDataView(string QuerySQL,string TableName) 
		{
			DataSet ds = QueryForDataSet(QuerySQL,TableName);
			DataView dv = new DataView(ds.Tables[TableName]);
			return dv;
		}

		public static SqlDataAdapter QueryForDataAdapter(string QuerySQL) 
		{
			SqlCommand dsCommand = GetConnection(QuerySQL);
			SqlDataAdapter dataAdapter= new SqlDataAdapter();
			dataAdapter.SelectCommand =dsCommand;
			return dataAdapter;
		}
	}
