using Dapper;
using EBook_Data.Common;
using EBook_Data.DataAccess;
using EBook_Data.DatabaseContext;
using EBook_Data.Dtos;
using EBook_Data.Interfaces;
using EBook_Services.MemoryCache;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using System.Data;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace EBook_Services.GlobalService
{
    public class ADORepository : IADORepository
    {
        #region Constructor
        private readonly DbStringCollection _dbStringCollection1;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly string _virtualdirectory;
        private readonly IMemoryCache _cache;
        private readonly IConfiguration _iconfig;
        private readonly string _swaggerhiddenversion;
        private readonly int _executiontimeout;
        private readonly bool _iscachingenable;

        public ADORepository(DbStringCollection dbStringCollection, IWebHostEnvironment env, IHttpContextAccessor httpContextAccessor, IConfiguration iconfig, IMemoryCache cache)
        {
            this._dbStringCollection1 = dbStringCollection;
            this._httpContextAccessor = httpContextAccessor;
            this._cache = cache;
            this._iconfig = iconfig;
            this._virtualdirectory = iconfig.GetValue<string>("VirtualDirectory").ToLower();
            //this._swaggerhiddenversion = iconfig.GetValue<string>("SwaggerHiddenVersion").ToLower();
            this._executiontimeout = iconfig.GetValue<int>("ExecutionTimeOut");
            this._iscachingenable = iconfig.GetValue<bool>("IsCachingEnabled");
        }
        #endregion Constructor

        #region General
        public void P_CacheEntry_IU(string cacheKey, string cacheValue, DateTime? expirationTime, int? applicationID = null)
        {
            try
            {

                if (cacheKey == "")
                    return;
                else if (expirationTime == null)
                    return;

                DateTime dateTime = (DateTime)expirationTime;

                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "applicationID";
                if (applicationID == null)
                    dynamic_SP_Params.Val = (GetPublicClaimObjects().iswebtoken == true ? AppEnum.ApplicationId.EBookAppID : AppEnum.ApplicationId.AppID);
                else
                    dynamic_SP_Params.Val = (int)applicationID;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "cacheKey";
                dynamic_SP_Params.Val = cacheKey;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "cacheValue";
                dynamic_SP_Params.Val = cacheValue;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "expirationTime";
                dynamic_SP_Params.Val = dateTime.ToString("yyyy-MM-dd HH:mm:ss.fffffff");
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                ExecuteStoreProcedureNONQuery("P_CacheEntry_IU", ref List_Dynamic_SP_Params);
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "P_CacheEntry_IU", SmallMessage: ex.Message, Message: ex.ToString());
            }
        }
        public void P_CacheEntry_Delete(string cacheKey)
        {
            try
            {
                if (cacheKey == "")
                    return;

                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "applicationID";
                dynamic_SP_Params.Val = (GetPublicClaimObjects().iswebtoken == true ? AppEnum.ApplicationId.EBookAppID : AppEnum.ApplicationId.AppID);
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "cacheKey";
                dynamic_SP_Params.Val = cacheKey;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                ExecuteStoreProcedureNONQuery("P_CacheEntry_Delete", ref List_Dynamic_SP_Params);
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "P_CacheEntry_Delete", SmallMessage: ex.Message, Message: ex.ToString());
            }
        }
        public DataRow? P_Get_CacheEntry(string cacheKey)
        {
            DataRow? DR = null;
            try
            {
                if (cacheKey == "")
                    return DR;

                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "applicationID";
                dynamic_SP_Params.Val = (GetPublicClaimObjects().iswebtoken == true ? AppEnum.ApplicationId.EBookAppID : AppEnum.ApplicationId.AppID);
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "cacheKey";
                dynamic_SP_Params.Val = cacheKey;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                DR = ExecuteStoreProcedureDR("P_Get_CacheEntry", ref List_Dynamic_SP_Params);
            }
            catch (Exception ex)
            {
                DR = null;
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "P_Get_CacheEntry", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return DR;
        }
        public PublicClaimObjects GetPublicClaimObjects()
        {
            PublicClaimObjects _PublicClaimObjects;
            _PublicClaimObjects = _httpContextAccessor?.HttpContext?.Items["PublicClaimObjects"] as PublicClaimObjects;
            if (_PublicClaimObjects == null)
                _PublicClaimObjects = new PublicClaimObjects();
            return _PublicClaimObjects;
        }
        public string GetLocalIPAddress()
        {
            string? Return = "";
            Return = this._httpContextAccessor?.HttpContext?.Connection?.RemoteIpAddress?.ToString();
            return (Return == null ? "" : Return);
        }
        public string GetRequestPath()
        {
            string? Return = "";
            Return = this._httpContextAccessor?.HttpContext?.Request?.Path.ToString();
            return Return = (Return == null ? "" : Return.ToLower().Replace("/v1", "").Replace("/" + GetSwaggerHiddenVersion(), ""));
        }
        public string GetSwaggerHiddenVersion()
        {
            return _swaggerhiddenversion;
        }
        public IHttpContextAccessor GetIHttpContextAccessor()
        {
            return _httpContextAccessor;
        }
        public IConfiguration GetIConfiguration()
        {
            return _iconfig;
        }
        public string GetRemoteDomain()
        {
            string? remotedomain = "";
            try
            {
                if (_httpContextAccessor?.HttpContext?.Request?.Method.ToUpper() != "GET")
                {
                    remotedomain = _httpContextAccessor?.HttpContext?.Request?.Headers?.Origin.ToString().ToLower();
                    if (Strings.Left(remotedomain, 8) == "https://")
                        remotedomain = Strings.Mid(remotedomain, 9, Strings.Len(remotedomain));
                    else if (Strings.Left(remotedomain, 7) == "http://")
                        remotedomain = Strings.Mid(remotedomain, 8, Strings.Len(remotedomain));
                }
                else
                {
                    remotedomain = _httpContextAccessor?.HttpContext?.Request?.Host.Value;

                }
                remotedomain = (remotedomain == null ? "" : remotedomain.ToLower());
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetRemoteDomain", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return remotedomain;
        }
        public bool IsDevelopment()
        {
            bool Ret = false;
            try
            {
                string hostname = GetHostName();
                if (hostname == "localhost")
                    Ret = true;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsDevelopment", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return Ret;
        }
        public string GetHostName()
        {
            string? hostname = "";
            try
            {
                hostname = _httpContextAccessor?.HttpContext?.Request?.Host.Host;
                hostname = (hostname == null ? "" : hostname.ToLower());
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetHostName", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return hostname;
        }
        public string GetHostURL()
        {
            string? hosturl = "";
            try
            {
                hosturl = _httpContextAccessor?.HttpContext?.Request?.Headers?.Referer.ToString();
                hosturl = (hosturl == null ? "" : (hosturl.ToString() == "null" ? "" : hosturl.ToString().ToLower()));
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetHostURL", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return hosturl;
        }
        public async Task<string> GetRequestBodyString()
        {
            string RequestBodyString = "";
            try
            {
                if (_httpContextAccessor?.HttpContext != null)
                {
                    _httpContextAccessor.HttpContext.Request.EnableBuffering();

                    using (var memoryStream = new MemoryStream())
                    {
                        await _httpContextAccessor.HttpContext.Request.Body.CopyToAsync(memoryStream);
                        memoryStream.Seek(0, SeekOrigin.Begin);

                        using (var reader = new StreamReader(memoryStream))
                        {
                            RequestBodyString = await reader.ReadToEndAsync();
                        }
                    }

                    // Reset the position of the original request body stream
                    _httpContextAccessor.HttpContext.Request.Body.Position = 0;
                }

            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetRequestBodyString", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return RequestBodyString;
        }
        public string GetVirtualDirectory()
        {
            return _virtualdirectory;
        }
        public bool GetIsCachingEnabled()
        {
            return _iscachingenable;
        }
        public ClaimsPrincipal? GetUserClaim()
        {
            ClaimsPrincipal? User = _httpContextAccessor?.HttpContext?.User;
            return User;
        }
        public DataRow P_Common_DR_Procedure(string Query, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params)
        {
            DataRow result = null;
            result = ExecuteStoreProcedureDR(Query, ref List_Dynamic_SP_Params)!;
            return result;
        }
        public P_ReturnMessage_Result P_SP_MultiParm_Result<T>(string Query, T res, string USERNAME, string IP = "")
        {
            P_ReturnMessage_Result result = new P_ReturnMessage_Result();
            List<Dynamic_SP_Params> dynamic_SP_Params_list = new List<Dynamic_SP_Params>();

            PropertyInfo[] properties = typeof(T).GetProperties();
            foreach (var property in properties)
            {
                if (property.GetCustomAttribute<ExcludeFromDynamicSPParamsAttribute>() == null) // Check if the property does not have the custom attribute
                {
                    Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
                    dynamic_SP_Params.ParameterName = property.Name;
                    dynamic_SP_Params.Val = property.GetValue(res);
                    dynamic_SP_Params_list.Add(dynamic_SP_Params);
                }
            }
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "Username", Val = USERNAME });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "IPAddress", Val = IP });

            DataRow DR = ExecuteStoreProcedureDR(Query, ref dynamic_SP_Params_list);
            result.ReturnCode = Convert.ToBoolean(DR["Return_Code"]);
            result.ReturnText = DR["Return_Text"].ToString();
            return result;
        }
        public P_ReturnMessage_Result P_SP_SingleParm_Result(string Query, string parmName, object parmValue, string USERNAME, string IP = "")
        {
            P_ReturnMessage_Result result = new P_ReturnMessage_Result();
            List<Dynamic_SP_Params> dynamic_SP_Params_list = new List<Dynamic_SP_Params>();
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = parmName, Val = parmValue });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "Username", Val = USERNAME });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "IPAddress", Val = IP });

            DataRow DR = ExecuteStoreProcedureDR(Query, ref dynamic_SP_Params_list);
            result.ReturnCode = Convert.ToBoolean(DR["Return_Code"]);
            result.ReturnText = DR["Return_Text"].ToString();
            return result;
        }
        public P_ReturnMessage_Result P_SP_Remove_Generic_Result(string TableName, string ColumnName, object ColumnValue)
        {
            P_ReturnMessage_Result result = new P_ReturnMessage_Result();
            List<Dynamic_SP_Params> dynamic_SP_Params_list = new List<Dynamic_SP_Params>();
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "TableName", Val = TableName });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "ColumnName", Val = ColumnName });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "ColumnValue", Val = ColumnValue });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "Username", Val = GetPublicClaimObjects().username });
            dynamic_SP_Params_list.Add(new Dynamic_SP_Params { ParameterName = "IPAddress", Val = "" });

            DataRow DR = ExecuteStoreProcedureDR("P_Remove_Generic", ref dynamic_SP_Params_list);
            result.ReturnCode = Convert.ToBoolean(DR["Return_Code"]);
            result.ReturnText = DR["Return_Text"].ToString();
            return result;
        }
        public string P_Get_SingleParm_String_Result(string Query, string parmName, object parmValue)
        {
            List<Dynamic_SP_Params> dynamic_SP_Params_list = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
            dynamic_SP_Params = new Dynamic_SP_Params();
            dynamic_SP_Params.ParameterName = parmName;
            dynamic_SP_Params.Val = parmValue;
            dynamic_SP_Params_list.Add(dynamic_SP_Params);
            object result = null;
            result = ExecuteStoreProcedureObj(Query, ref dynamic_SP_Params_list)!;
            return (result == null ? "" : result.ToString()!);
        }
        public string P_Get_MultiParm_String_Result(string Query, List<Dynamic_SP_Params> List_Dynamic_SP_Params)
        {
            object result = null;
            result = ExecuteStoreProcedureObj(Query, ref List_Dynamic_SP_Params)!;
            return (result == null ? "" : result.ToString()!);
        }
        public List<SelectDropDownList> Get_DropDownList_Result(string Query, List<Dynamic_SP_Params> List_Dynamic_SP_Params = null)
        {
            List<SelectDropDownList> result = ExecuteSelectSQLMapList<SelectDropDownList>(Query, false, 0, ref List_Dynamic_SP_Params);
            return result;
        }
        public T P_AddEditRemove_SP<T>(string Query, List<Dynamic_SP_Params> List_Dynamic_SP_Params) where T : new()
        {
            T result = new T();
            DataRow DR = ExecuteStoreProcedureDR(Query, ref List_Dynamic_SP_Params)!;
            if (DR != null)
            {
                var properties = typeof(T).GetProperties();
                foreach (var property in properties)
                {
                    if (DR.Table.Columns.Contains(property.Name))
                    {
                        object value = DR[property.Name];
                        property.SetValue(result, value == DBNull.Value ? null : value, null);
                    }
                }
            }
            return result;
        }
        public T P_Get_Generic_SP<T>(string Query, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool IsSP = true) where T : new()
        {
            return ExecuteSelectSQLMap<T>(Query, IsSP, 0, ref List_Dynamic_SP_Params);
        }
        public List<T> P_Get_Generic_List_SP<T>(string Query, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool IsSP = true) where T : new()
        {
            return ExecuteSelectSQLMapList<T>(Query, IsSP, 1000, ref List_Dynamic_SP_Params);
        }
        public string P_Get_SingleValue_String_SP(string Query, string parmName, object parmValue)
        {
            List<Dynamic_SP_Params> dynamic_SP_Params_list = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
            dynamic_SP_Params = new Dynamic_SP_Params();
            dynamic_SP_Params.ParameterName = parmName;
            dynamic_SP_Params.Val = parmValue;
            dynamic_SP_Params_list.Add(dynamic_SP_Params);
            object result = null;
            result = ExecuteStoreProcedureObj(Query, ref dynamic_SP_Params_list)!;
            return (result == null ? "" : result.ToString()!);
        }
        public List<SelectDropDownList> Get_DropdownList_MT_ID(int MT_ID, string UserName)
        {
            List<SelectDropDownList> lists = new List<SelectDropDownList>();

            DataTable dt = new DataTable();
            //dt = P_Get_List_By_ID_2(MT_ID, UserName);

            foreach (DataRow row in dt.Rows)
            {
                SelectDropDownList item = new SelectDropDownList
                {
                    code = row["MTV_CODE"],
                    name = row["SubName"].ToString()!
                };

                lists.Add(item);
            }

            return lists;
        }
        public List<SelectDropDownListWithEncryptionString> Get_DropdownList_MT_ID_With_Encryption(int MT_ID, string UserName, bool IsCodeRequired)
        {
            List<SelectDropDownListWithEncryptionString> lists = new List<SelectDropDownListWithEncryptionString>();

            DataTable dt = new DataTable();
            //dt = P_Get_List_By_ID_2(MT_ID, UserName);

            foreach (DataRow row in dt.Rows)
            {
                SelectDropDownListWithEncryptionString item = new SelectDropDownListWithEncryptionString
                {
                    code = (IsCodeRequired ? row["MTV_ID"].ToString() : row["MTV_CODE"].ToString()),
                    name = row["SubName"].ToString()
                };

                lists.Add(item);
            }

            return lists;
        }
        #endregion General

        #region DB         
        public int P_GetDBServerForDataRead_2(string ReadOnly_Config_Key = "", MemoryCacheValueType? _MemoryCacheValueType = null)
        {
            int Database_ID = 13;
            try
            {
                string paravalue = $"ReadOnly_Config_Key:{ReadOnly_Config_Key}";
                _MemoryCacheValueType = (_MemoryCacheValueType == null ? new MemoryCacheValueType() : _MemoryCacheValueType);
                _MemoryCacheValueType._GetMemoryCacheValueType.setkeyparavalues = paravalue;
                _MemoryCacheValueType._GetMemoryCacheValueType.subtype = CacheSubType.P_GetDBServerForDataRead_2;
                _MemoryCacheValueType._SetMemoryCacheValueType.subtype = CacheSubType.P_GetDBServerForDataRead_2;
                if (MemoryCaches.GetCacheValue(_MemoryCacheValueType, ref Database_ID, _cache, _iscachingenable))
                    return Database_ID;

                try
                {
                    List<Dynamic_SP_Params> Dynamic_SP_Params_List = new List<Dynamic_SP_Params>();
                    Dynamic_SP_Params _Dynamic_SP_Params = new Dynamic_SP_Params();
                    _Dynamic_SP_Params.ParameterName = "Config_Key";
                    _Dynamic_SP_Params.Val = ReadOnly_Config_Key;

                    object? return_obj = ExecuteStoreProcedureObjMainDB(SPName: "P_GetDBServerForDataRead_2", dynamic_SP_Params: ref Dynamic_SP_Params_List);
                    if (return_obj != null)
                    {
                        if (return_obj.ToString().ToUpper() == "PRIMARY")
                            Database_ID = 10;
                        else if (return_obj.ToString().ToUpper() == "SECONDARY")
                            Database_ID = 11;
                        else
                            Database_ID = 13;
                    }
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "P_GetDBServerForDataRead_2", SmallMessage: ex.Message, Message: ex.ToString());
                }
                MemoryCaches.SetCacheValue(_MemoryCacheValueType, Database_ID, _cache, _iscachingenable);
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "P_GetDBServerForDataRead_2 1", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return Database_ID;
        }
        public string GetDB(bool Is_Read_Only_DB = false, string Database_Name = "", string ReadOnly_Config_Key = "")
        {
            Database_Name = Database_Name.ToLower();
            int Database_ID = 13;
            string connectionString = "";
            if (Is_Read_Only_DB == true)
            {
                Database_ID = P_GetDBServerForDataRead_2(ReadOnly_Config_Key);
            }

            connectionString = GetDBConnectionString(Database_Name, Database_ID);

            return connectionString;
        }
        public string GetDBConnectionString(string Database_Name = "", int Database_ID = 10)
        {
            Database_Name = Database_Name.ToLower();
            string connectionString = "";

            if (Database_Name == "" || Database_Name == AppEnum.Database_Name.EBook)
                if (Database_ID == 10)
                    connectionString = _dbStringCollection1.EBook_DB_ConnectionModel_10.ConnectionString;
                else if (Database_ID == 11)
                    connectionString = _dbStringCollection1.EBook_DB_ConnectionModel_11.ConnectionString;
                else
                    connectionString = _dbStringCollection1.EBook_DB_ConnectionModel_11.ConnectionString;

            else
                connectionString = _dbStringCollection1.EBook_DB_ConnectionModel_10.ConnectionString;

            return connectionString;
        }
        public object? ExecuteSQL(string Query, bool IsSP, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool Read_Only, string Database_Name, bool IsReturnRecord, string Config_Key)
        {
            if (CommandTimeOut <= 0)
                CommandTimeOut = _executiontimeout;
            object? result = null;
            DataSet dataSet = new DataSet();
            string ConnectionString;
            ConnectionString = GetDB(Read_Only, Database_Name, Config_Key);
            bool IsOutPutParaExists = false;
            using (var connection = new SqlConnection(ConnectionString))
            {
                connection.Open();

                try
                {
                    if (IsReturnRecord)
                    {
                        result = dataSet;
                    }

                    if (IsReturnRecord)
                    {
                        var adapter = new SqlDataAdapter(Query, connection);
                        if (IsSP)
                            adapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                        else
                            adapter.SelectCommand.CommandType = CommandType.Text;
                        adapter.SelectCommand.CommandTimeout = CommandTimeOut;
                        if (List_Dynamic_SP_Params != null)
                        {
                            for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                            {
                                List_Dynamic_SP_Params[i].Val = (List_Dynamic_SP_Params[i].Val == null ? DBNull.Value : List_Dynamic_SP_Params[i].Val);
                                SqlParameter sqlParam = new SqlParameter("@" + List_Dynamic_SP_Params[i].ParameterName, List_Dynamic_SP_Params[i].GetValueType);
                                sqlParam.Value = List_Dynamic_SP_Params[i].Val;
                                if (List_Dynamic_SP_Params[i].Size > 0)
                                    sqlParam.Size = List_Dynamic_SP_Params[i].Size;
                                sqlParam.Direction = List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output;
                                IsOutPutParaExists = ((IsOutPutParaExists == false && List_Dynamic_SP_Params[i].IsInputType == false) ? true : IsOutPutParaExists);
                                adapter.SelectCommand.Parameters.Add(sqlParam);
                            }
                        }

                        dataSet = new DataSet();
                        adapter.Fill(dataSet);
                        result = dataSet;
                        if (IsOutPutParaExists)
                        {
                            for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                            {
                                if (List_Dynamic_SP_Params[i].IsInputType == false)
                                    List_Dynamic_SP_Params[i].Val = adapter.SelectCommand.Parameters["@" + List_Dynamic_SP_Params[i].ParameterName].Value;
                            }
                        }
                    }
                    else
                    {
                        var command = new SqlCommand(Query, connection);
                        if (IsSP)
                            command.CommandType = CommandType.StoredProcedure;
                        else
                            command.CommandType = CommandType.Text;
                        command.CommandTimeout = CommandTimeOut;
                        if (List_Dynamic_SP_Params != null)
                        {
                            for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                            {
                                List_Dynamic_SP_Params[i].Val = (List_Dynamic_SP_Params[i].Val == null ? DBNull.Value : List_Dynamic_SP_Params[i].Val);
                                SqlParameter sqlParam = new SqlParameter("@" + List_Dynamic_SP_Params[i].ParameterName, List_Dynamic_SP_Params[i].GetValueType);
                                sqlParam.Value = List_Dynamic_SP_Params[i].Val;
                                if (List_Dynamic_SP_Params[i].Size > 0)
                                    sqlParam.Size = List_Dynamic_SP_Params[i].Size;
                                sqlParam.Direction = List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output;
                                IsOutPutParaExists = ((IsOutPutParaExists == false && List_Dynamic_SP_Params[i].IsInputType == false) ? true : IsOutPutParaExists);
                                command.Parameters.Add(sqlParam);
                            }
                        }
                        result = command.ExecuteNonQuery();
                        if (IsOutPutParaExists)
                        {
                            for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                            {
                                if (List_Dynamic_SP_Params[i].IsInputType == false)
                                    List_Dynamic_SP_Params[i].Val = command.Parameters["@" + List_Dynamic_SP_Params[i].ParameterName].Value;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "ExecuteSQL", SmallMessage: ex.Message, Message: ex.ToString());
                    throw new Exception("Internal Server Error");
                }
                connection.Close();
            }
            return result;
        }
        public int ExecuteNONQuery(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            object? return_obj = null;
            int return_int = 0;
            return_obj = ExecuteSQL(Query, false, CommandTimeOut, ref dynamic_SP_Params, false, Database_Name, false, Config_Key);
            if (return_obj != null)
            {
                if (Information.IsNumeric(return_obj))
                    return return_int = Convert.ToInt32(return_obj);
            }
            return return_int;
        }
        public int ExecuteNONQuery(string Query, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteNONQuery(Query, ref dynamic_SP_Params, Database_Name, CommandTimeOut, Config_Key);
        }
        public int ExecuteNONQuery(string Query, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            return (int)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, false, Database_Name, false, Config_Key);
        }
        public int ExecuteNONQuery(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params_item = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params_item = new Dynamic_SP_Params();
                        dynamic_SP_Params_item.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params_item.Val = ParamsNameValues[i].Value;
                        dynamic_SP_Params.Add(dynamic_SP_Params_item);
                    }
                }
            }

            object? return_obj = null;
            int return_int = 0;
            return_obj = ExecuteSQL(Query, false, CommandTimeOut, ref dynamic_SP_Params, false, Database_Name, false, Config_Key);
            if (return_obj != null)
            {
                if (Information.IsNumeric(return_obj))
                    return return_int = Convert.ToInt32(return_obj);
            }
            return return_int;
        }
        public DataSet ExecuteSelectDS(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            DataSet dataSet = new DataSet();
            object? return_obj = null;
            return_obj = ExecuteSQL(Query, false, CommandTimeOut, ref dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (return_obj != null)
            {
                return dataSet = (DataSet)return_obj;
            }
            return dataSet;
        }
        public DataSet ExecuteSelectDS(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteSelectDS(Query, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public DataSet ExecuteSelectDS(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            dataSet = (DataSet)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            return dataSet;
        }
        public DataSet ExecuteSelectDS(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            dataSet = (DataSet)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            return dataSet;
        }
        public DataTable ExecuteSelectDT(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            DataSet dataSet = new DataSet();
            DataTable dataTable = new DataTable();
            object? return_obj = null;
            return_obj = ExecuteSQL(Query, false, CommandTimeOut, ref dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (return_obj != null)
            {
                dataSet = (DataSet)return_obj;
                if (dataSet.Tables.Count > 0)
                {
                    dataTable = dataSet.Tables[0];
                }
            }
            return dataTable;
        }
        public DataTable ExecuteSelectDT(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteSelectDT(Query, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public DataTable ExecuteSelectDT(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataTable dataTable = new DataTable();
            dataSet = (DataSet)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                dataTable = dataSet.Tables[0];
            }
            return dataTable;
        }
        public DataTable ExecuteSelectDT(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataTable dataTable = new DataTable();
            dataSet = (DataSet)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                dataTable = dataSet.Tables[0];
            }
            return dataTable;
        }
        public DataRow? ExecuteSelectDR(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            DataSet dataSet = new DataSet();
            DataRow? dataRow = null;
            object? return_obj = null;
            return_obj = ExecuteSQL(Query, false, CommandTimeOut, ref dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (return_obj != null)
            {
                dataSet = (DataSet)return_obj;
                if (dataSet.Tables.Count > 0)
                {
                    if (dataSet.Tables[0].Rows.Count > 0)
                        dataRow = dataSet.Tables[0].Rows[0];
                }
            }
            return dataRow;
        }
        public DataRow? ExecuteSelectDR(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteSelectDR(Query, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public DataRow? ExecuteSelectDR(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataRow? dataRow = null;
            dataSet = (DataSet)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                if (dataSet.Tables[0].Rows.Count > 0)
                    dataRow = dataSet.Tables[0].Rows[0];
            }
            return dataRow;
        }
        public DataRow? ExecuteSelectDR(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataRow? dataRow = null;
            dataSet = (DataSet)ExecuteSQL(Query, false, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                if (dataSet.Tables[0].Rows.Count > 0)
                    dataRow = dataSet.Tables[0].Rows[0];
            }
            return dataRow;
        }
        public object? ExecuteSelectObj(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            object? result = null;
            DataRow? dataRow;
            dataRow = ExecuteSelectDR(Query, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
            if (dataRow != null)
            {
                if (Information.IsDBNull(dataRow[0]) == false)
                    result = dataRow[0];
            }
            return result;
        }
        public object? ExecuteSelectObj(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteSelectDR(Query, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public object? ExecuteSelectObj(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object? result = null;
            DataRow? dataRow = null;
            dataRow = ExecuteSelectDR(Query, ref List_dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
            if (dataRow != null)
            {
                if (Information.IsDBNull(dataRow[0]) == false)
                    result = dataRow[0];
            }
            return result;
        }
        public object? ExecuteSelectObj(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object? result = null;
            DataRow? dataRow = null;
            dataRow = ExecuteSelectDR(Query, ref List_dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
            if (dataRow != null)
            {
                if (Information.IsDBNull(dataRow[0]) == false)
                    result = dataRow[0];
            }
            return result;
        }
        public object? ExecuteSelectObjMainDB(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            object? result = null;
            result = ExecuteSelectObj(Query, ref dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
            return result;
        }
        public object? ExecuteSelectObjMainDB(string Query, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteSelectObj(Query, ref dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
        }
        public object? ExecuteSelectObjMainDB(string Query, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object? result = null;
            result = ExecuteSelectObj(Query, ref List_dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
            return result;
        }
        public object? ExecuteSelectObjMainDB(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object? result = null;
            result = ExecuteSelectObj(Query, ref List_dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
            return result;
        }
        public int ExecuteStoreProcedureNONQuery(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            object? return_obj = null;
            int return_int = 0;
            return_obj = ExecuteSQL(SPName, true, CommandTimeOut, ref dynamic_SP_Params, false, Database_Name, false, Config_Key);
            if (return_obj != null)
            {
                if (Information.IsNumeric(return_obj))
                    return return_int = Convert.ToInt32(return_obj);
            }
            return return_int;
        }
        public int ExecuteStoreProcedureNONQuery(string SPName, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteStoreProcedureNONQuery(SPName, ref dynamic_SP_Params, Database_Name, CommandTimeOut, Config_Key);
        }
        public int ExecuteStoreProcedureNONQuery(string Query, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }
            return (int)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, false, Database_Name, false, Config_Key);
        }
        public int ExecuteStoreProcedureNONQuery(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }
            return (int)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, false, Database_Name, false, Config_Key);
        }
        public DataSet ExecuteStoreProcedureDS(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            DataSet dataSet = new DataSet();
            object? return_obj = null;
            return_obj = ExecuteSQL(SPName, true, CommandTimeOut, ref dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (return_obj != null)
            {
                return dataSet = (DataSet)return_obj;
            }
            return dataSet;
        }
        public DataSet ExecuteStoreProcedureDS(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteStoreProcedureDS(SPName, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public DataSet ExecuteStoreProcedureDS(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            dataSet = (DataSet)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            return dataSet;
        }
        public DataSet ExecuteStoreProcedureDS(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            dataSet = (DataSet)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            return dataSet;
        }
        public DataTable ExecuteStoreProcedureDT(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            DataSet dataSet = new DataSet();
            DataTable dataTable = new DataTable();
            object? return_obj = null;
            return_obj = ExecuteSQL(SPName, true, CommandTimeOut, ref dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (return_obj != null)
            {
                dataSet = (DataSet)return_obj;
                if (dataSet.Tables.Count > 0)
                {
                    dataTable = dataSet.Tables[0];
                }
            }
            return dataTable;
        }
        public DataTable ExecuteStoreProcedureDT(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteStoreProcedureDT(SPName, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public DataTable ExecuteStoreProcedureDT(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataTable dataTable = new DataTable();
            dataSet = (DataSet)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                dataTable = dataSet.Tables[0];
            }
            return dataTable;
        }
        public DataTable ExecuteStoreProcedureDT(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataTable dataTable = new DataTable();
            dataSet = (DataSet)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                dataTable = dataSet.Tables[0];
            }
            return dataTable;
        }
        public DataRow? ExecuteStoreProcedureDR(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            DataSet dataSet = new DataSet();
            DataRow? dataRow = null;
            object? return_obj = null;
            return_obj = ExecuteSQL(SPName, true, CommandTimeOut, ref dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (return_obj != null)
            {
                dataSet = (DataSet)return_obj;
                if (dataSet.Tables.Count > 0)
                {
                    if (dataSet.Tables[0].Rows.Count > 0)
                        dataRow = dataSet.Tables[0].Rows[0];
                }
            }
            return dataRow;
        }
        public DataRow? ExecuteStoreProcedureDR(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteStoreProcedureDR(SPName, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public DataRow? ExecuteStoreProcedureDR(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataRow? dataRow = null;
            dataSet = (DataSet)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                if (dataSet.Tables[0].Rows.Count > 0)
                    dataRow = dataSet.Tables[0].Rows[0];
            }
            return dataRow;
        }
        public DataRow? ExecuteStoreProcedureDR(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            DataSet dataSet = new DataSet();
            DataRow? dataRow = null;
            dataSet = (DataSet)ExecuteSQL(Query, true, CommandTimeOut, ref List_dynamic_SP_Params, Read_Only, Database_Name, true, Config_Key);
            if (dataSet.Tables.Count > 0)
            {
                if (dataSet.Tables[0].Rows.Count > 0)
                    dataRow = dataSet.Tables[0].Rows[0];
            }
            return dataRow;
        }
        public object? ExecuteStoreProcedureObj(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            object? result = null;
            DataRow? dataRow;
            dataRow = ExecuteStoreProcedureDR(SPName, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
            if (dataRow != null)
            {
                if (Information.IsDBNull(dataRow[0]) == false)
                    result = dataRow[0];
            }
            return result;
        }
        public object? ExecuteStoreProcedureObj(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteStoreProcedureObj(SPName, ref dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
        }
        public object? ExecuteStoreProcedureObj(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object result = null;
            DataRow? dataRow;
            dataRow = ExecuteStoreProcedureDR(Query, ref List_dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
            if (dataRow != null)
            {
                if (Information.IsDBNull(dataRow[0]) == false)
                    result = dataRow[0];
            }
            return result;
        }
        public object? ExecuteStoreProcedureObj(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            bool Read_Only = false;
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object result = null;
            DataRow? dataRow;
            dataRow = ExecuteStoreProcedureDR(Query, ref List_dynamic_SP_Params, Read_Only, Database_Name, CommandTimeOut, Config_Key);
            if (dataRow != null)
            {
                if (Information.IsDBNull(dataRow[0]) == false)
                    result = dataRow[0];
            }
            return result;
        }
        public object? ExecuteStoreProcedureObjMainDB(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            object? result = null;
            result = ExecuteStoreProcedureObj(SPName, ref dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
            return result;
        }
        public object? ExecuteStoreProcedureObjMainDB(string SPName, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "")
        {
            List<Dynamic_SP_Params> dynamic_SP_Params = null;
            return ExecuteStoreProcedureObjMainDB(SPName, ref dynamic_SP_Params, Database_Name, CommandTimeOut, Config_Key);
        }
        public object? ExecuteStoreProcedureObjMainDB(string Query, string Database_Name = AppEnum.Database_Name.EBook, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object? result = null;
            result = ExecuteStoreProcedureDR(Query, ref List_dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
            return result;
        }
        public object? ExecuteStoreProcedureObjMainDB(string Query, params (string Name, object Value)[] ParamsNameValues)
        {
            string Database_Name = AppEnum.Database_Name.EBook;
            int CommandTimeOut = 0;
            string Config_Key = "";
            List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            object? result = null;
            result = ExecuteStoreProcedureDR(Query, ref List_dynamic_SP_Params, false, Database_Name, CommandTimeOut, Config_Key);
            return result;
        }
        public T ExecuteSelectSQLMap<T>(string Query, bool IsSP, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "") where T : new()
        {
            bool IsList = false;
            if (CommandTimeOut <= 0)
                CommandTimeOut = 2000;
            T result = new T();
            string ConnectionString;
            ConnectionString = GetDB(Read_Only, Database_Name, Config_Key);
            bool IsOutPutParaExists = false;
            using (var connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                try
                {
                    var spParam = new DynamicParameters();
                    if (List_Dynamic_SP_Params != null)
                    {
                        for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                        {
                            List_Dynamic_SP_Params[i].Val = (List_Dynamic_SP_Params[i].Val == null ? DBNull.Value : List_Dynamic_SP_Params[i].Val);
                            if (List_Dynamic_SP_Params[i].Size > 0)
                            {
                                spParam.Add(name: "@" + List_Dynamic_SP_Params[i].ParameterName
                                    , value: List_Dynamic_SP_Params[i].Val
                                    , size: List_Dynamic_SP_Params[i].Size
                                    , direction: List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output);
                            }
                            else
                            {
                                spParam.Add(name: "@" + List_Dynamic_SP_Params[i].ParameterName
                                    , value: List_Dynamic_SP_Params[i].Val
                                    , direction: List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output);
                            }
                            if (List_Dynamic_SP_Params[i].IsInputType == false && IsOutPutParaExists == false)
                                IsOutPutParaExists = true;
                        }
                        result = connection.Query<T>(Query, param: spParam, commandType: (IsSP ? CommandType.StoredProcedure : CommandType.Text), commandTimeout: CommandTimeOut).FirstOrDefault();
                    }
                    else
                    {
                        result = connection.Query<T>(Query, commandType: (IsSP ? CommandType.StoredProcedure : CommandType.Text), commandTimeout: CommandTimeOut).FirstOrDefault();
                    }
                    if (IsOutPutParaExists)
                    {
                        for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                        {
                            if (List_Dynamic_SP_Params[i].IsInputType == false)
                                List_Dynamic_SP_Params[i].Val = spParam.Get<object>("@" + List_Dynamic_SP_Params[i].ParameterName);
                        }
                    }
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "ExecuteSelectSQLMap", SmallMessage: ex.Message, Message: ex.ToString());
                    throw new Exception("Internal Server Error");
                }

                connection.Close();
            }
            return result;
        }
        public T ExecuteSelectSQLMap<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues) where T : new()
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_Dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            return ExecuteSelectSQLMap<T>(Query, IsSP, CommandTimeOut, ref List_Dynamic_SP_Params, Read_Only, Database_Name, Config_Key);
        }
        public T ExecuteSelectSQLMap<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "") where T : new()
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;
            return ExecuteSelectSQLMap<T>(Query, IsSP, CommandTimeOut, ref List_Dynamic_SP_Params, Read_Only, Database_Name, Config_Key);
        }
        public List<T> ExecuteSelectSQLMapList<T>(string Query, bool IsSP, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "") where T : new()
        {
            bool IsList = true;
            if (CommandTimeOut <= 0)
                CommandTimeOut = 2000;
            List<T> result = new List<T>();
            string ConnectionString;
            ConnectionString = GetDB(Read_Only, Database_Name, Config_Key);
            bool IsOutPutParaExists = false;
            using (var connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                try
                {
                    var spParam = new DynamicParameters();
                    if (List_Dynamic_SP_Params != null)
                    {
                        for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                        {
                            List_Dynamic_SP_Params[i].Val = (List_Dynamic_SP_Params[i].Val == null ? DBNull.Value : List_Dynamic_SP_Params[i].Val);
                            if (List_Dynamic_SP_Params[i].Size > 0)
                            {
                                spParam.Add(name: "@" + List_Dynamic_SP_Params[i].ParameterName
                                    , value: List_Dynamic_SP_Params[i].Val
                                    , size: List_Dynamic_SP_Params[i].Size
                                    , direction: List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output);
                            }
                            else
                            {
                                spParam.Add(name: "@" + List_Dynamic_SP_Params[i].ParameterName
                                    , value: List_Dynamic_SP_Params[i].Val
                                    , direction: List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output);
                            }
                            if (List_Dynamic_SP_Params[i].IsInputType == false && IsOutPutParaExists == false)
                                IsOutPutParaExists = true;
                        }
                        result = connection.Query<T>(Query, param: spParam, commandType: (IsSP ? CommandType.StoredProcedure : CommandType.Text), commandTimeout: CommandTimeOut).ToList<T>();
                    }
                    else
                    {
                        result = connection.Query<T>(Query, commandType: (IsSP ? CommandType.StoredProcedure : CommandType.Text), commandTimeout: CommandTimeOut).ToList<T>();
                    }
                    if (IsOutPutParaExists)
                    {
                        for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                        {
                            if (List_Dynamic_SP_Params[i].IsInputType == false)
                                List_Dynamic_SP_Params[i].Val = spParam.Get<object>("@" + List_Dynamic_SP_Params[i].ParameterName);
                        }
                    }
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "ExecuteSelectSQLMapList", SmallMessage: ex.Message, Message: ex.ToString());
                    throw new Exception("Internal Server Error");
                }

                connection.Close();
            }
            return result;
        }
        public List<T> ExecuteSelectSQLMapList<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues) where T : new()
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_Dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            return ExecuteSelectSQLMapList<T>(Query, IsSP, CommandTimeOut, ref List_Dynamic_SP_Params, Read_Only, Database_Name, Config_Key);
        }
        public List<T> ExecuteSelectSQLMapList<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "") where T : new()
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;
            return ExecuteSelectSQLMapList<T>(Query, IsSP, CommandTimeOut, ref List_Dynamic_SP_Params, Read_Only, Database_Name, Config_Key);
        }
        public void ExecuteSelectSQLMapMultiple(string Query, bool IsSP, bool IsList, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, ref List<object> listofobject, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "")
        {
            if (CommandTimeOut <= 0)
                CommandTimeOut = 2000;
            SqlMapper.GridReader result;
            string ConnectionString;
            ConnectionString = GetDB(Read_Only, Database_Name, Config_Key);
            bool IsOutPutParaExists = false;
            using (var connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                try
                {
                    var spParam = new DynamicParameters();
                    if (List_Dynamic_SP_Params != null)
                    {
                        for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                        {
                            List_Dynamic_SP_Params[i].Val = (List_Dynamic_SP_Params[i].Val == null ? DBNull.Value : List_Dynamic_SP_Params[i].Val);
                            if (List_Dynamic_SP_Params[i].Size > 0)
                            {
                                spParam.Add(name: "@" + List_Dynamic_SP_Params[i].ParameterName
                                    , value: List_Dynamic_SP_Params[i].Val
                                    , size: List_Dynamic_SP_Params[i].Size
                                    , direction: List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output);
                            }
                            else
                            {
                                spParam.Add(name: "@" + List_Dynamic_SP_Params[i].ParameterName
                                    , value: List_Dynamic_SP_Params[i].Val
                                    , direction: List_Dynamic_SP_Params[i].IsInputType ? ParameterDirection.Input : ParameterDirection.Output);
                            }
                            if (List_Dynamic_SP_Params[i].IsInputType == false && IsOutPutParaExists == false)
                                IsOutPutParaExists = true;
                        }
                        result = connection.QueryMultiple(Query, param: spParam, commandType: (IsSP ? CommandType.StoredProcedure : CommandType.Text), commandTimeout: CommandTimeOut);
                    }
                    else
                        result = connection.QueryMultiple(Query, commandType: (IsSP ? CommandType.StoredProcedure : CommandType.Text), commandTimeout: CommandTimeOut);

                    for (int i = 0; i <= listofobject.Count - 1; i++)
                    {
                        listofobject[i] = result.Read<dynamic>().ToList();
                    }

                    if (IsOutPutParaExists)
                    {
                        for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
                        {
                            if (List_Dynamic_SP_Params[i].IsInputType == false)
                                List_Dynamic_SP_Params[i].Val = spParam.Get<object>("@" + List_Dynamic_SP_Params[i].ParameterName);
                        }
                    }
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "ExecuteSelectSQLMapMultiple", SmallMessage: ex.Message, Message: ex.ToString());
                    throw new Exception("Internal Server Error");
                }

                connection.Close();
            }
        }
        public void ExecuteSelectSQLMapMultiple(string Query, bool IsSP, bool IsList, int CommandTimeOut, ref List<object> listofobject, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues)
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;

            if ((ParamsNameValues != null))
            {
                if ((ParamsNameValues.Length > 0))
                {
                    List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
                    for (var i = 0; i <= ParamsNameValues.Length - 1; i++)
                    {
                        dynamic_SP_Params = new Dynamic_SP_Params();
                        dynamic_SP_Params.ParameterName = ParamsNameValues[i].Name;
                        dynamic_SP_Params.Val = ParamsNameValues[i].Value;
                        List_Dynamic_SP_Params.Add(dynamic_SP_Params);
                    }
                }
            }

            ExecuteSelectSQLMapMultiple(Query, IsSP, IsList, CommandTimeOut, ref List_Dynamic_SP_Params, ref listofobject, Read_Only, Database_Name, Config_Key);
        }
        public void ExecuteSelectSQLMapMultiple(string Query, bool IsSP, bool IsList, int CommandTimeOut, ref List<object> listofobject, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.EBook, string Config_Key = "")
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;
            ExecuteSelectSQLMapMultiple(Query, IsSP, IsList, CommandTimeOut, ref List_Dynamic_SP_Params, ref listofobject, Read_Only, Database_Name, Config_Key);
        }
        #endregion DB 

        #region User
        public async Task<P_UserLoginPasswordModel> GetUserLoginCredentials(string UserName, CancellationToken cancellationToken)
        {
            List<Dynamic_SP_Params> parms = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "UserName", Val = UserName.ToUpper()}
            };
            string query = "SELECT PasswordHash,PasswordSalt FROM [dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 AND UPPER(UserName) = @UserName";
            var result = P_Get_Generic_SP<P_UserLoginPasswordModel>(query, ref parms, false);
            return result;

        }
        public P_Get_User_Info P_Get_User_Info(string UserName, int ApplicationID, MemoryCacheValueType? _MemoryCacheValueType = null)
        {
            List<Dynamic_SP_Params> parms = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "UserName", Val = UserName},
                new Dynamic_SP_Params {ParameterName = "ApplicationID", Val = ApplicationID},
            };
            P_Get_User_Info result = ExecuteSelectSQLMap<P_Get_User_Info>("P_Get_User_Info", true, 0, ref parms);
            return result;
        }


        public DataTable P_Get_Role_Rights_From_Username(string Username, int P_ID = 0, int PR_ID = 0, string PageRightType_MTV_CODE = "", MemoryCacheValueType? _MemoryCacheValueType = null)
        {
            string paravalue = $"Username:{Username}|P_ID:{P_ID}|PR_ID:{PR_ID}|PageRightType_MTV_CODE:{PageRightType_MTV_CODE}".ToLower();
            _MemoryCacheValueType = (_MemoryCacheValueType == null ? new MemoryCacheValueType() : _MemoryCacheValueType);
            _MemoryCacheValueType._GetMemoryCacheValueType.setkeyparavalues = paravalue;
            _MemoryCacheValueType._GetMemoryCacheValueType.subtype = CacheSubType.P_Get_Role_Rights_From_Username;
            _MemoryCacheValueType._SetMemoryCacheValueType.subtype = CacheSubType.P_Get_Role_Rights_From_Username;
            DataTable result = new DataTable();
            if (MemoryCaches.GetCacheValue(_MemoryCacheValueType, ref result, _cache, _iscachingenable))
                return result;

            List<Dynamic_SP_Params> Dynamic_SP_Params_List = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params;

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Username";
            Dynamic_SP_Params.Val = Username.ToUpper();
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "P_ID";
            Dynamic_SP_Params.Val = P_ID;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "PR_ID";
            Dynamic_SP_Params.Val = PR_ID;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "PageRightType_MTV_CODE";
            Dynamic_SP_Params.Val = PageRightType_MTV_CODE;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            result = ExecuteStoreProcedureDT("P_Get_Role_Rights_From_Username", ref Dynamic_SP_Params_List);

            MemoryCaches.SetCacheValue(_MemoryCacheValueType, result, _cache, _iscachingenable);

            return result;
        }
        public DataTable P_Get_Role_Rights_From_Username(string Username, MemoryCacheValueType? _MemoryCacheValueType = null)
        {
            return P_Get_Role_Rights_From_Username(Username, 0, 0, "", _MemoryCacheValueType);
        }
        public bool P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(string Username, int PR_ID)
        {
            bool result = false;
            DataTable DT = new DataTable();
            DT = P_Get_Role_Rights_From_Username(Username, null);
            if (DT.Rows.Count > 0)
            {
                List<DataRow> DR = DT.Select($"PR_ID = {PR_ID}").AsEnumerable().ToList();
                if (DR.Count > 0)
                {
                    result = Convert.ToBoolean(DR[0]["IsRightActive"]);
                }
            }
            return result;
        }
        public P_ReturnMessageForJson_Result P_Create_User(string Json, string USERNAME, string IP = "")
        {
            P_ReturnMessageForJson_Result result = new P_ReturnMessageForJson_Result();

            List<Dynamic_SP_Params> Dynamic_SP_Params_List = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params;

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Json";
            Dynamic_SP_Params.Val = Json;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Username";
            Dynamic_SP_Params.Val = USERNAME;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "IP";
            Dynamic_SP_Params.Val = IP;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Return_Code";
            Dynamic_SP_Params.Val = 0;
            Dynamic_SP_Params.IsInputType = false;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Return_Text";
            Dynamic_SP_Params.Val = "";
            Dynamic_SP_Params.Size = 1000;
            Dynamic_SP_Params.IsInputType = false;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Execution_Error";
            Dynamic_SP_Params.Val = "";
            Dynamic_SP_Params.Size = int.MaxValue;
            Dynamic_SP_Params.IsInputType = false;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Error_Text";
            Dynamic_SP_Params.Val = "";
            Dynamic_SP_Params.Size = int.MaxValue;
            Dynamic_SP_Params.IsInputType = false;
            Dynamic_SP_Params_List.Add(Dynamic_SP_Params);

            DataTable DT = ExecuteStoreProcedureDT("P_Create_User", ref Dynamic_SP_Params_List)!;

            for (int i = 0; i <= Dynamic_SP_Params_List.Count - 1; i++)
            {
                if (Dynamic_SP_Params_List[i].ParameterName == "Return_Code")
                {
                    result.ReturnCode = Convert.ToBoolean(Dynamic_SP_Params_List[i].Val);
                }
                else if (Dynamic_SP_Params_List[i].ParameterName == "Return_Text")
                {
                    result.ReturnText = Dynamic_SP_Params_List[i].Val.ToString();
                }
                else if (Dynamic_SP_Params_List[i].ParameterName == "Execution_Error")
                {
                    result.Execution_Error = Dynamic_SP_Params_List[i].Val!.ToString();
                }
                else if (Dynamic_SP_Params_List[i].ParameterName == "Error_Text")
                {
                    result.Execution_Error = Dynamic_SP_Params_List[i].Val!.ToString();
                }
            }

            return result;
        }
        #endregion User
    }
}
