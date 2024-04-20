using EBook_Data.Common;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using Microsoft.AspNetCore.Http;
using System.Data;
using System.Security.Claims;

namespace EBook_Data.Interfaces
{
    public interface IADORepository
    {
        #region General
        public void P_CacheEntry_IU(string cacheKey, string cacheValue, DateTime? expirationTime, int? applicationID = null);
        public void P_CacheEntry_Delete(string cacheKey);
        public DataRow? P_Get_CacheEntry(string cacheKey);
        public string GetRequestPath();
        public string GetLocalIPAddress();
        public IHttpContextAccessor GetIHttpContextAccessor();
        public PublicClaimObjects GetPublicClaimObjects();
        public string GetRemoteDomain();
        public bool IsDevelopment();
        public string GetHostName();
        public string GetHostURL();
        public Task<string> GetRequestBodyString();
        public string GetVirtualDirectory();
        public bool GetIsCachingEnabled();
        public DataRow P_Common_DR_Procedure(string Query, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params);
        public P_ReturnMessage_Result P_SP_MultiParm_Result<T>(string Query, T res, string USERNAME, string IP = "");
        public P_ReturnMessage_Result P_SP_SingleParm_Result(string Query, string parmName, object parmValue, string USERNAME, string IP = "");
        public P_ReturnMessage_Result P_SP_Remove_Generic_Result(string TableName, string ColumnName, object ColumnValue);
        public string P_Get_SingleParm_String_Result(string Query, string parmName, object parmValue);
        public string P_Get_MultiParm_String_Result(string Query, List<Dynamic_SP_Params> List_Dynamic_SP_Params);
        public List<SelectDropDownList> Get_DropDownList_Result(string Query, List<Dynamic_SP_Params> List_Dynamic_SP_Params = null!);
        public T P_AddEditRemove_SP<T>(string Query, List<Dynamic_SP_Params> List_Dynamic_SP_Params) where T : new();
        public T P_Get_Generic_SP<T>(string Query, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool IsSP = true) where T : new();
        public List<T> P_Get_Generic_List_SP<T>(string Query, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool IsSP = true) where T : new();
        public string P_Get_SingleValue_String_SP(string Query, string parmName, object parmValue);
        public List<SelectDropDownList> Get_DropdownList_MT_ID(int MT_ID, string UserName);
        public List<SelectDropDownListWithEncryptionString> Get_DropdownList_MT_ID_With_Encryption(int MT_ID, string UserName, bool IsCodeRequired);
        #endregion General

        #region IDB         
        public int ExecuteNONQuery(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public int ExecuteNONQuery(string Query, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public int ExecuteNONQuery(string Query, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public int ExecuteNONQuery(string Query, params (string Name, object Value)[] ParamsNameValues);
        public DataSet ExecuteSelectDS(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataSet ExecuteSelectDS(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataSet ExecuteSelectDS(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public DataSet ExecuteSelectDS(string Query, params (string Name, object Value)[] ParamsNameValues);
        public DataTable ExecuteSelectDT(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataTable ExecuteSelectDT(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataTable ExecuteSelectDT(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public DataTable ExecuteSelectDT(string Query, params (string Name, object Value)[] ParamsNameValues);
        public DataRow? ExecuteSelectDR(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataRow? ExecuteSelectDR(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataRow? ExecuteSelectDR(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public DataRow? ExecuteSelectDR(string Query, params (string Name, object Value)[] ParamsNameValues);
        public object? ExecuteSelectObj(string Query, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public object? ExecuteSelectObj(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public object? ExecuteSelectObj(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public object? ExecuteSelectObj(string Query, params (string Name, object Value)[] ParamsNameValues);
        public int ExecuteStoreProcedureNONQuery(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public int ExecuteStoreProcedureNONQuery(string SPName, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public int ExecuteStoreProcedureNONQuery(string Query, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public int ExecuteStoreProcedureNONQuery(string Query, params (string Name, object Value)[] ParamsNameValues);
        public DataSet ExecuteStoreProcedureDS(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataSet ExecuteStoreProcedureDS(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataSet ExecuteStoreProcedureDS(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public DataSet ExecuteStoreProcedureDS(string Query, params (string Name, object Value)[] ParamsNameValues);
        public DataTable ExecuteStoreProcedureDT(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataTable ExecuteStoreProcedureDT(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataTable ExecuteStoreProcedureDT(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public DataTable ExecuteStoreProcedureDT(string Query, params (string Name, object Value)[] ParamsNameValues);
        public DataRow? ExecuteStoreProcedureDR(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataRow? ExecuteStoreProcedureDR(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public DataRow? ExecuteStoreProcedureDR(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public DataRow? ExecuteStoreProcedureDR(string Query, params (string Name, object Value)[] ParamsNameValues);
        public object? ExecuteStoreProcedureObj(string SPName, ref List<Dynamic_SP_Params> dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public object? ExecuteStoreProcedureObj(string SPName, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "");
        public object? ExecuteStoreProcedureObj(string Query, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, int CommandTimeOut = 0, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public object? ExecuteStoreProcedureObj(string Query, params (string Name, object Value)[] ParamsNameValues);
        public T ExecuteSelectSQLMap<T>(string Query, bool IsSP, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "") where T : new();
        public T ExecuteSelectSQLMap<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues) where T : new();
        public T ExecuteSelectSQLMap<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "") where T : new();
        public List<T> ExecuteSelectSQLMapList<T>(string Query, bool IsSP, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "") where T : new();
        public List<T> ExecuteSelectSQLMapList<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues) where T : new();
        public List<T> ExecuteSelectSQLMapList<T>(string Query, bool IsSP, int CommandTimeOut, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "") where T : new();
        public void ExecuteSelectSQLMapMultiple(string Query, bool IsSP, bool IsList, int CommandTimeOut, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, ref List<object> listofobject, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "");
        public void ExecuteSelectSQLMapMultiple(string Query, bool IsSP, bool IsList, int CommandTimeOut, ref List<object> listofobject, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "", params (string Name, object Value)[] ParamsNameValues);
        public void ExecuteSelectSQLMapMultiple(string Query, bool IsSP, bool IsList, int CommandTimeOut, ref List<object> listofobject, bool Read_Only = false, string Database_Name = AppEnum.Database_Name.POMS, string Config_Key = "");
        #endregion IDB 

        #region User
        public Task<P_UserLoginQueryModel> GetUserLoginCredentials(string UserName, CancellationToken cancellationToken);
        public ClaimsPrincipal? GetUserClaim();
        public bool P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(string Username, int PR_ID);
        public P_Get_User_Info P_Get_User_Info_Class(string UserName, int ApplicationID, MemoryCacheValueType? _MemoryCacheValueType = null);
        public P_ReturnMessageForJson_Result P_Create_User(string Json, string USERNAME, string IP = "");
        #endregion User
    }
}
