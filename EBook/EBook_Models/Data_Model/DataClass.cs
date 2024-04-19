using EBook_Models.App_Models;

namespace EBook_Models.Data_Model
{
    #region Global
    public class Constrant
    {
        public static string Authenticatekey = "This is key that will be used in encryption";
        public static string AuthenticateIssuer = "http://localhost:7274";
        public static string AuthenticateAudience = "http://localhost:7274";
        public static Uri AppUrl = new Uri("http://172.16.0.11/api/");
    }
    public class Dynamic_SP_Params
    {
        public string ParameterName { get; set; } = "";
        public object? Val { get; set; } = null;
        public bool IsInputType { get; set; } = true;
        public bool IsCustomSetValueType { get; set; } = true;
        private Type _SetValueType = typeof(object);
        public Type SetValueType
        {
            get
            {
                return this._SetValueType;
            }
            set
            {
                this._SetValueType = value;
            }
        }
        public Type GetValueType
        {
            get
            {
                if (this.IsCustomSetValueType)
                    return this._SetValueType;
                else
                    return this.Val.GetType();
            }
        }
        public int Size { get; set; } = -1;
    }
    public class GlobalsFunctions
    {
        public static int GetSeconds(int seconds = 0, int minutes = 0, int hours = 0)
        {
            return (seconds + (minutes * 60) + (hours * 60 * 60));
        }
        public static string GetTypeString(List<string>? _List)
        {
            string Ret = "";
            if (_List != null)
            {
                if (_List.Count > 0)
                {
                    for (int i = 0; i <= _List.Count - 1; i++)
                    {
                        Ret += "type:" + _List[i] + "|";
                    }
                }
            }
            return Ret;
        }
        public static bool GetDefaultSetCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = true;
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = true;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = true;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = true;

            return RetValue;
        }
        public static bool GetDefaultSetSQLCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static bool GetDefaultGetCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = true;
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = true;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = true;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = true;

            return RetValue;
        }
        public static bool GetDefaultGetSQLCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static bool GetDefaultRemoveCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static bool GetDefaultRemoveSQLCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static int GetDefaultCacheExpirySeconds(string? subtype)
        {
            int DefaultValue = 60;
            subtype = (subtype == null ? "" : subtype);
            int RetValue = DefaultValue;
            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = GetSeconds(hours: 6);
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = GetSeconds(minutes: 20);
            else if (subtype == CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = GetSeconds(hours: 6);
            else if (subtype == CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = GetSeconds(hours: 6);

            return RetValue;
        }
        public static List<string>? GetCacheType(string? subtype)
        {
            subtype = (subtype == null ? "" : subtype);
            List<string>? RetValue = new List<string>();

            if (subtype == CacheSubType.P_Get_Role_Rights_From_RoleID)
            {
                RetValue.Add(CacheType.TUsers);
            }
            else if (subtype == CacheSubType.P_Get_Role_Rights_From_Username)
            {
                RetValue.Add(CacheType.TUsers);
            }

            if (RetValue.Count == 0)
                RetValue = null;
            return RetValue;
        }
        public static List<string>? GetCacheSubType(string? type)
        {
            type = (type == null ? "" : type);
            List<string>? RetValue = new List<string>();

            if (type == CacheType.TAPIUserMapRequestLimit)
            {
                RetValue.Add(CacheSubType.P_Is_Has_Right_From_Username);
            }
            else if (type == CacheSubType.P_Is_Has_Right_From_Username)
            {
                RetValue.Add(CacheSubType.P_Is_Has_Right_From_Username);
            }

            if (RetValue.Count == 0)
                RetValue = null;
            return RetValue;
        }
    }
    
    #endregion Global
}
