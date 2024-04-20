using EBook_Data.Common;
using EBook_Data.Dtos;
using EBook_Models.App_Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualBasic;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Globalization;
using System.IdentityModel.Tokens.Jwt;
using System.Reflection;
using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using static EBook_Data.Dtos.AppEnum;

namespace EBook_Data.DataAccess
{
    public class Globals
    {
        public static int GetRemainingSecondsInDay(DateTime utcdateTime)
        {
            // Calculate the remaining time until the end of the day
            DateTime endOfDay = utcdateTime.Date.AddDays(1); // Start of the next day
            TimeSpan remainingTime = endOfDay - utcdateTime;

            // Return the remaining seconds
            return (int)remainingTime.TotalSeconds;
        }
        public static int GetRemainingSecondsInHour(DateTime utcdateTime)
        {
            // Calculate the remaining time until the end of the day
            DateTime endOfHour = utcdateTime.Date.AddHours(1); // Start of the next day
            TimeSpan remainingTime = endOfHour - utcdateTime;

            // Return the remaining seconds
            return (int)remainingTime.TotalSeconds;
        }
        public static ContentResult GetJsonReturn(object? _Data, int _StatusCode = 200, JsonSerializerSettings? _JsonSerializerSettings = null, bool isexcludefilebase64field = false, string _ContentType = "application/json", bool isoriginalmembername = false)
        {
            return Globals.GetContentResult(Globals.GetResponseJson(_Data, _JsonSerializerSettings, isexcludefilebase64field, isoriginalmembername), _StatusCode, _JsonSerializerSettings, _ContentType);
        }
        public static ContentResult GetAjaxJsonReturn(object? _Data, int _StatusCode = 200, JsonSerializerSettings? _JsonSerializerSettings = null, bool isexcludefilebase64field = false, string _ContentType = "application/json", bool isoriginalmembername = true)
        {
            return Globals.GetContentResult(Globals.GetResponseJson(_Data, _JsonSerializerSettings, isexcludefilebase64field, isoriginalmembername), _StatusCode, _JsonSerializerSettings, _ContentType);
        }
        /// <summary>
        /// Get Content Result
        /// </summary>
        /// <param name="json">Json string.</param>
        /// <param name="_StatusCode">Result StatusCode. Default value 200 OK Response</param>
        /// <param name="_JsonSerializerSettings">JsonSerialization Setting. In case of null it will be consider *CustomContractResolverHideProperty* or CustomContractResolverNone if call is from swaggeradmin.</param>
        /// <param name="_ContentType">Result ContentType. Default value *application/json*</param>
        /// <returns>New ContentResult will be returned.</returns>
        public static ContentResult GetContentResult(string json, int _StatusCode = 200, JsonSerializerSettings? _JsonSerializerSettings = null, string _ContentType = "application/json")
        {
            ContentResult _ContentResult = new ContentResult
            {
                Content = json,
                ContentType = _ContentType,
                StatusCode = _StatusCode
            };
            return _ContentResult;
        }
        /// <summary>
        /// Get Content Result
        /// </summary>
        /// <param name="_Data">Result Object. In case of null it will be consider empty string.</param>
        /// <param name="_JsonSerializerSettings">JsonSerialization Setting. In case of null it will be consider *CustomContractResolverHideProperty* or CustomContractResolverNone if call is from swaggeradmin.</param>
        /// <returns>Response Json Will Be Returned</returns>
        public static string GetResponseJson(object? _Data, JsonSerializerSettings? _JsonSerializerSettings = null, bool isexcludefilebase64field = false, bool isoriginalmembername = false)
        {
            if (_JsonSerializerSettings == null)
            {
                int Type_ = AppEnum.JsonIgnorePropertyType.HideProperty;
                //if (StaticPublicObjects.ado.IsSwaggerCallAdmin() || (StaticPublicObjects.ado.IsAllowedDomain() && StaticPublicObjects.ado.IsSwaggerCall() == false))
                //{
                    Type_ = AppEnum.JsonIgnorePropertyType.None;
                //}
                _JsonSerializerSettings = GetCustomJsonDefaultSetting(Type_, isoriginalmembername, isexcludefilebase64field);
            }

            string json = (_Data == null ? "" : JsonConvert.SerializeObject(_Data, _JsonSerializerSettings));
            return json;
        }
        public static string GetRequestBodyHash(string body)
        {
            // hash the request body to generate a cache key
            // for simplicity, we're using SHA512 here, but you might want to use a stronger hash algorithm
            using (var _SHA512 = SHA512.Create())
            {
                //var serializedBody = JsonConvert.SerializeObject(body);
                var hash = _SHA512.ComputeHash(Encoding.UTF8.GetBytes(body));
                return BitConverter.ToString(hash).Replace("-", "").ToLower();
            }
        }
        public static DateTime? GetTokenExpiryTime(string bearerToken)
        {
            var handler = new JwtSecurityTokenHandler();
            var token = handler.ReadJwtToken(bearerToken);

            // Extract "exp" claim from token's payload
            var expiryTime = token.Claims.FirstOrDefault(c => c.Type == "exp")?.Value;

            if (!string.IsNullOrEmpty(expiryTime) && long.TryParse(expiryTime, out var epochTime))
            {
                // Convert epoch time to DateTime
                return DateTimeOffset.FromUnixTimeSeconds(epochTime).DateTime;
            }

            return null; // Return null if "exp" claim is not found or invalid
        }
        
        public static List<T> GetObjectListFromDataTable<T>(ref DataTable DT) where T : new()
        {
            List<T> _List = new List<T>();
            T item = new T();
            for (int i = 0; i <= DT.Rows.Count - 1; i++)
            {
                item = new T();
                item = StaticPublicObjects.map.Map<T>(DT.Rows[i]);
                _List.Add(item);
            }
            return _List;
        }
       
        public static object? ConvertDBNulltoNullIfExists(object? obj)
        {
            object? Ret = obj;
            if (Information.IsDBNull(Ret))
                Ret = null;
            return Ret;
        }
        public static string? ConvertDBNulltoNullIfExistsString(object? obj)
        {
            string? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
                Ret = obj.ToString();

            return Ret;
        }
        public static int? ConvertDBNulltoNullIfExistsInt(object? obj)
        {
            int? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
            {
                if (obj.ToString() != "")
                    Ret = Convert.ToInt32(Convert.ToDouble(obj));
            }

            return Ret;
        }
        public static double? ConvertDBNulltoNullIfExistsDouble(object? obj)
        {
            double? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
            {
                if (obj.ToString() != "")
                    Ret = Convert.ToDouble(obj);
            }

            return Ret;
        }
        public static bool? ConvertDBNulltoNullIfExistsBool(object? obj)
        {
            bool? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
            {
                if (obj.ToString() != "")
                    Ret = Convert.ToBoolean(obj);
            }

            return Ret;
        }
        public static string? ConvertDBNulltoNullIfExistsDate(object? obj, bool isyearfirst = false)
        {
            string? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
            {
                if (obj.ToString() != "")
                {
                    if (Information.IsDate(obj))
                    {
                        DateTime dateTime = Convert.ToDateTime(obj);
                        if (dateTime.Year <= 2000)
                        {
                            return Ret;
                        }
                        if (isyearfirst)
                            Ret = dateTime.ToString("yyyy-MM-dd");
                        else
                            Ret = dateTime.ToString("MM-dd-yyyy");
                    }
                }
            }

            return Ret;
        }
        public static string? ConvertDBNulltoNullIfExistsDateTime(object? obj, bool isyearfirst = false)
        {
            string? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
            {
                if (obj.ToString() != "")
                {
                    if (Information.IsDate(obj) == false && obj.ToString().Length >= 20)
                    {
                        obj = Strings.Left(obj.ToString(), obj.ToString().Length - 3).Trim().ToString();
                    }
                    DateTime dateTime = Convert.ToDateTime(obj);
                    if (dateTime.Year <= 2000)
                    {
                        return Ret;
                    }
                    if (isyearfirst)
                        Ret = dateTime.ToString("yyyy-MM-dd hh:mm:ss tt");
                    else
                        Ret = dateTime.ToString("MM-dd-yyyy hh:mm:ss tt");
                }
            }
            return Ret;
        }
        public static string? ConvertDBNulltoNullIfExists12HourTime(object? obj)
        {
            string? Ret = null;
            if (Information.IsDBNull(obj))
                obj = null;
            if (obj != null)
            {
                if (obj.ToString() != "")
                    Ret = Convert.ToDateTime(obj).ToString("hh:mm tt");
            }

            return Ret;
        }
        public static string ConvertNulltoEmptyString(string? obj)
        {
            string Ret = "";
            if (obj != null)
                Ret = obj.ToString();

            return Ret;
        }
        
        public static bool IsAnyListValueExists(string val, List<string>? listval)
        {
            bool result = false;
            if (val != "" && listval != null)
            {
                for (int i = 0; i <= listval.Count - 1; i++)
                {
                    if (val.ToLower().Contains(listval[i].ToLower()))
                        return result = true;
                }
            }
            return result;
        }
        public static List<string>? GetListofStringsFromString(List<string>? ReturnListString, string addstring)
        {
            List<string>? Ret = ReturnListString;
            if (addstring != "")
            {
                Ret = (Ret == null ? new List<string>() : Ret);
                List<string> manualPOMStext = new List<string>();
                manualPOMStext = addstring.Split(';').ToList();
                for (int az = 0; az < manualPOMStext.Count; az++)
                    Ret.Add(manualPOMStext[az].Trim());
            }
            return Ret;
        }
        public static List<string>? GetListofStringsFromString(object? addstring)
        {
            List<string>? Ret = new List<string>();
            addstring = (Information.IsDBNull(addstring) ? null : addstring);
            if (addstring == null)
                Ret = null;
            else if (addstring.ToString() == "")
                Ret = null;
            else if (addstring.ToString() != "")
            {
                List<string>? TempList = new List<string>();
                TempList = addstring.ToString().Split(';').ToList();
                foreach (string TempString in TempList)
                    Ret.Add(TempString.Trim());
            }
            return Ret;
        }
        public static DateTime GetCurrentUTCDateTimeFromEST(string ESTDateTime)
        {
            return TimeZoneInfo.ConvertTime(Convert.ToDateTime(ESTDateTime), TimeZoneInfo.FindSystemTimeZoneById("Eastern Standard Time"), TimeZoneInfo.FindSystemTimeZoneById("UTC"));
        }
        
        public static DateTime GetCurrentESTDateTime()
        {
            return TimeZoneInfo.ConvertTime(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("UTC"), TimeZoneInfo.FindSystemTimeZoneById("Eastern Standard Time"));
        }
        public static string GetCurrentESTDateTimeToString(bool IsIncludeTime)
        {
            DateTime Ret = GetCurrentESTDateTime();
            if (IsIncludeTime)
                return Ret.ToString("yyyy-MM-dd HH:mm:ss.fff");
            else
                return Ret.ToString("yyyy-MM-dd");
        }
        public static JsonSerializerSettings GetCustomJsonDefaultSetting(int Type_, bool isoriginalmembername, bool isexcludefilebase64field)
        {
            JsonSerializerSettings settings = new JsonSerializerSettings();
            if (Type_ == JsonIgnorePropertyType.Standard)
                settings.ContractResolver = new CustomContractResolverStandard(true, isoriginalmembername, isexcludefilebase64field);
            else if (Type_ == JsonIgnorePropertyType.None)
                settings.ContractResolver = new CustomContractResolverNone(isoriginalmembername, isexcludefilebase64field);
            else if (Type_ == JsonIgnorePropertyType.HideProperty)
                settings.ContractResolver = new CustomContractResolverHideProperty(false, isoriginalmembername, isexcludefilebase64field);
            return settings;
        }
        public static double GetMiles(double oLat, double oLon, double dLat, double dLon)
        {
            double Miles;

            double SinDLat;
            double SinOLat;
            double CosDLat;
            double CosOLat;
            double CosOLon;
            double CosDLon;

            SinDLat = Math.Sin(Radians(dLat));
            SinOLat = Math.Sin(Radians(oLat));
            CosDLat = Math.Cos(Radians(dLat));
            CosOLat = Math.Cos(Radians(oLat));
            CosOLon = Radians(oLon);
            CosDLon = Radians(dLon);

            Miles = Math.Acos((SinDLat * SinOLat) + ((CosDLat * CosOLat) * Math.Cos(CosOLon - CosDLon))) * 3959;
            return Miles;
        }
        public static object? GetValueFromReturnFieldDynamicCondition(List<Dynamic_SP_Params> Dynamic_SP_Params_List, string fieldname, bool IsReturnParam = true)
        {
            object? obj = "";
            if (Dynamic_SP_Params_List != null)
            {
                if (Dynamic_SP_Params_List.Count > 0)
                {
                    for (int i = 0; i <= Dynamic_SP_Params_List.Count - 1; i++)
                    {
                        if (Dynamic_SP_Params_List[i].ParameterName == fieldname && IsReturnParam == true && Dynamic_SP_Params_List[i].IsInputType == false)
                        {
                            obj = Dynamic_SP_Params_List[i].Val;
                            break;
                        }
                    }
                }
            }

            return obj;
        }
        private static double Radians(double v)
        {
            double pi;
            pi = 22 / 7.00;
            return (v * pi) / 180.00;
        }
        public static string GetStringJoin(List<string>? strings, string joiner)
        {
            string Ret = "";
            if (strings != null)
            {
                List<string> NewList = new List<string>();
                for (int i = 0; i <= strings.Count - 1; i++)
                {
                    if (strings[i].Trim() != "")
                        NewList.Add(strings[i].Trim());
                }
                if (NewList.Count > 0)
                    Ret = string.Join(joiner, NewList);
            }
            return Ret;
        }
        public static string GetStringJoin(string[]? strings, string joiner)
        {
            string Ret = "";
            if (strings != null)
            {
                List<string> NewList = new List<string>();
                for (int i = 0; i <= strings.Length - 1; i++)
                {
                    if (strings[i].Trim() != "")
                        NewList.Add(strings[i].Trim());
                }
                if (NewList.Count > 0)
                    Ret = string.Join(joiner, NewList);
            }
            return Ret;
        }
        public static bool IsPasswordValid(string password, int passwordlength)
        {
            // Define regular expressions for each criterion
            var hasCapitalLetter = new Regex(@"[A-Z]").IsMatch(password);
            var hasSmallLetter = new Regex(@"[a-z]").IsMatch(password);
            var hasSpecialCharacter = new Regex(@"[!@#$%^&*()_+{}\[\]:;<>,.?~\\/\-=]").IsMatch(password);
            var hasNumber = new Regex(@"\d").IsMatch(password);
            var haslength = password.Length < passwordlength ? false : true;

            // Check if all criteria are met
            return hasCapitalLetter && hasSmallLetter && hasSpecialCharacter && hasNumber && haslength;
        }
        public static bool IsValidEmail(string originalemail)
        {
            bool isvalidemail = false;
            if (string.IsNullOrWhiteSpace(originalemail))
                return false;

            try
            {
                string[] emailobj;
                emailobj = originalemail.Split(';');
                // Normalize the domain
                foreach (string s in emailobj)
                {
                    string email = s;
                    email = Regex.Replace(email, @"(@)(.+)$", DomainMapper,
                                      RegexOptions.None, TimeSpan.FromMilliseconds(200));

                    // Examines the domain part of the email and normalizes it.
                    string DomainMapper(Match match)
                    {
                        // Use IdnMapping class to convert Unicode domain names.
                        var idn = new IdnMapping();

                        // Pull out and process domain name (throws ArgumentException on invalid)
                        string domainName = idn.GetAscii(match.Groups[2].Value);

                        return match.Groups[1].Value + domainName;
                    }
                    isvalidemail = Regex.IsMatch(email,
                    @"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                    RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(250));
                    if (isvalidemail == false)
                        break;
                }
            }
            catch (RegexMatchTimeoutException e)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValidEmail", SmallMessage: e.Message, Message: e.ToString());
                return false;
            }
            catch (ArgumentException e)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValidEmail 1", SmallMessage: e.Message, Message: e.ToString());
                return false;
            }

            try
            {
                return isvalidemail;
            }
            catch (RegexMatchTimeoutException e)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValidEmail 2", SmallMessage: e.Message, Message: e.ToString());
                return false;
            }
        }
        public static void SetReportFilterClause(ref ReportParams reportParams)
        {
            string FilterClause = " ";
            for (int i = 0; i <= reportParams.ReportFilterObjectList.Count - 1; i++)
            {
                List<SQLReportFilterObjectArry> ListSQLReportFilterObjectArry = new List<SQLReportFilterObjectArry>();
                string TempFilterClause = " ";
                for (int z = 0; z <= reportParams.ReportFilterObjectList[i].reportFilterObjectArry.Count - 1; z++)
                {
                    string setCode = reportParams.ReportFilterObjectList[i].Code;
                    if (z > 0)
                    {
                        setCode = reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Code;
                    }
                    SQLReportFilterObjectArry sQLReportFilterObjectArry = new SQLReportFilterObjectArry();
                    GetSQLReportFilterOperator(ref sQLReportFilterObjectArry, reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z]);
                    ListSQLReportFilterObjectArry.Add(sQLReportFilterObjectArry);
                    string code = setCode;
                    if (reportParams.ReportFilterObjectList[i].SRFieldType == KendoGridFilterSRFieldType.LowerString && reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Value.ToString() != "")
                    {
                        code = $"lower({setCode})";
                    }
                    else if (reportParams.ReportFilterObjectList[i].SRFieldType == KendoGridFilterSRFieldType.UpperString && reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Value.ToString() != "")
                    {
                        code = $"upper({setCode})";
                    }
                    else if (reportParams.ReportFilterObjectList[i].SRFieldType == KendoGridFilterSRFieldType.Date)
                    {
                        code = $"cast({setCode} as date)";
                    }
                    if (reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Type == KendoGridFilterType.isnullorempty || reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Type == KendoGridFilterType.isnotnullorempty)
                        code = $"isnull({code},'')";

                    if (z == 0)
                    {
                        TempFilterClause = $" {code} {sQLReportFilterObjectArry.Type} {sQLReportFilterObjectArry.Value} ";
                    }
                    else
                    {
                        TempFilterClause += $" {reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Logic} {code} {sQLReportFilterObjectArry.Type} {sQLReportFilterObjectArry.Value} ";
                    }
                }
                if (TempFilterClause.Trim() != "")
                    FilterClause += $" AND ({TempFilterClause}) ";

                reportParams.ReportFilterObjectList[i].sQLReportFilterObjectArry = ListSQLReportFilterObjectArry;
            }
            reportParams.FilterClause = FilterClause;

        }
        public static void GetSQLReportFilterOperator(ref SQLReportFilterObjectArry sQLReportFilterObjectArry, ReportFilterObjectArry reportFilterObjectArry)
        {
            sQLReportFilterObjectArry = new SQLReportFilterObjectArry();
            object val = reportFilterObjectArry.Value;
            if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.Date)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "1900-01-01";
                else if (Information.IsDate(reportFilterObjectArry.Value))
                    val = Convert.ToDateTime(reportFilterObjectArry.Value.ToString()).ToString("yyyy-MM-dd");
            }
            else if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.Datetime)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "1900-01-01";
                else if (Information.IsDate(reportFilterObjectArry.Value))
                    val = Convert.ToDateTime(reportFilterObjectArry.Value.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            }
            else if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.Float)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = 0.00;
                else if (Information.IsNumeric(reportFilterObjectArry.Value))
                    val = Convert.ToDouble(reportFilterObjectArry.Value.ToString());
            }
            else if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.Int)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = 0;
                else if (Information.IsNumeric(reportFilterObjectArry.Value))
                    val = Convert.ToInt64(reportFilterObjectArry.Value.ToString());
            }
            else if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.LowerString)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "";
                else
                    val = reportFilterObjectArry.Value.ToString().ToLower();
            }
            else if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.UpperString)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "";
                else
                    val = reportFilterObjectArry.Value.ToString().ToUpper();
            }
            else if (reportFilterObjectArry.SRFieldType == KendoGridFilterSRFieldType.Boolean)
            {
                if (Convert.ToBoolean(reportFilterObjectArry.Value.ToString()))
                    val = 1;
                else
                    val = 0;
            }

            if (reportFilterObjectArry.Type == KendoGridFilterType.inlistfilter || reportFilterObjectArry.Type == KendoGridFilterType.notinlistfilter)
            {
                if (val.ToString() == "")
                    val = "''";
                else
                    val = SetOrders(val.ToString(), true);
            }

            if (reportFilterObjectArry.Type == KendoGridFilterType.contains)
            {
                sQLReportFilterObjectArry.Type = " like ";
                sQLReportFilterObjectArry.Value = $"'%{val}%'";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.doesnotcontain)
            {
                sQLReportFilterObjectArry.Type = " not like ";
                sQLReportFilterObjectArry.Value = $"'%{val}%'";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.notequal)
            {
                sQLReportFilterObjectArry.Type = " not in ";
                sQLReportFilterObjectArry.Value = $"('{val}')";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.equal && reportFilterObjectArry.FieldType != KendoGridFilterFieldType.Boolean && reportFilterObjectArry.FieldType != KendoGridFilterFieldType.Number)
            {
                sQLReportFilterObjectArry.Type = " in ";
                sQLReportFilterObjectArry.Value = $"('{val}')";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.equal && reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Number)
            {
                sQLReportFilterObjectArry.Type = " in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.equal && reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Boolean)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = val;
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.startswith)
            {
                sQLReportFilterObjectArry.Type = " like ";
                sQLReportFilterObjectArry.Value = $"'{val}%'";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.endswith)
            {
                sQLReportFilterObjectArry.Type = " like ";
                sQLReportFilterObjectArry.Value = $"'%{val}'";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isnull)
            {
                sQLReportFilterObjectArry.Type = " is ";
                sQLReportFilterObjectArry.Value = $"null";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isnotnull)
            {
                sQLReportFilterObjectArry.Type = " is not ";
                sQLReportFilterObjectArry.Value = $"null";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.orderno)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isempty)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isnotempty)
            {
                sQLReportFilterObjectArry.Type = " <> ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isnullorempty)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isnotnullorempty)
            {
                sQLReportFilterObjectArry.Type = " <> ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isequalorgreather)
            {
                sQLReportFilterObjectArry.Type = " >= ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.greather)
            {
                sQLReportFilterObjectArry.Type = " > ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.isequalorless)
            {
                sQLReportFilterObjectArry.Type = " <= ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.less)
            {
                sQLReportFilterObjectArry.Type = " < ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.notinlistfilter)
            {
                sQLReportFilterObjectArry.Type = " not in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
            else if (reportFilterObjectArry.Type == KendoGridFilterType.inlistfilter)
            {
                sQLReportFilterObjectArry.Type = " in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
        }
        public static void GetKendoFilter(ref ReportParams _ReportParams, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, P_Get_User_Info userinfo)
        {
            ReportResponse reportResponse = new ReportResponse();
            SetReportFilterClause(ref _ReportParams);

            int pagesize = _ReportParams.PageSize;
            int pageindex = _ReportParams.PageIndex;
            string sortExpression = _ReportParams.SortExpression;

            List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "PageIndex";
            Dynamic_SP_Params.Val = pageindex;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "PageSize";
            Dynamic_SP_Params.Val = pagesize;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "SortExpression";
            Dynamic_SP_Params.Val = sortExpression;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "FilterClause";
            Dynamic_SP_Params.Val = _ReportParams.FilterClause;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "TotalRowCount";
            Dynamic_SP_Params.Val = 0;
            Dynamic_SP_Params.IsInputType = false;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "TimeZoneID";
            Dynamic_SP_Params.Val = userinfo.TimeZoneID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "FilterObject";
            Dynamic_SP_Params.Val = JsonConvert.SerializeObject(_ReportParams.ReportFilterObjectList);
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "ColumnObject";
            Dynamic_SP_Params.Val = JsonConvert.SerializeObject(_ReportParams.ReportColumnObjectList);
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

        }
        public static string SetOrders(string StrOrder, bool Seperation_Logic_Is_Text)
        {
            StrOrder = StrOrder.Replace("'", "");
            StrOrder = StrOrder.Replace(',', Strings.Chr(13));
            StrOrder = StrOrder.Replace(' ', Strings.Chr(13));
            StrOrder = StrOrder.Replace(Strings.Chr(10), Strings.Chr(13));
            string StrRet = "";
            string[] A;
            A = StrOrder.Split(Strings.Chr(13));
            foreach (var OrderNo in A)
            {
                if (OrderNo.Trim() != "")
                {
                    if (StrRet == "")
                    {
                        if (Seperation_Logic_Is_Text)
                            StrRet = string.Format("'{0}'", OrderNo.Trim());
                        else
                            StrRet = string.Format("{0}", OrderNo.Trim());
                    }
                    else if (Seperation_Logic_Is_Text)
                        StrRet = string.Format("{0},'{1}'", StrRet, OrderNo.Trim());
                    else
                        StrRet = string.Format("{0},{1}", StrRet, OrderNo.Trim());
                }
            }
            if (!Seperation_Logic_Is_Text)
            {
            }
            return StrRet;
        }
        public static List<ReportFilterDropDownList> GetReportFilterDropDownListFromDataTable(DataTable DT, ref List<ReportFilterDropDownList> reportFilterDropDownLists, string TextFieldColName = "text", string ValueFieldColName = "value", bool IsAddedSelectOption = true, bool IsAddedSelectAll = false)
        {
            reportFilterDropDownLists = new List<ReportFilterDropDownList>();
            if (IsAddedSelectOption)
            {
                ReportFilterDropDownList reportFilterDropDown = new ReportFilterDropDownList();
                reportFilterDropDown.text = "[Select Option]";
                reportFilterDropDown.value = "";
                reportFilterDropDownLists.Add(reportFilterDropDown);
            }
            if (DT.Rows.Count > 0)
            {
                if (IsAddedSelectAll)
                {
                    ReportFilterDropDownList reportFilterDropDown = new ReportFilterDropDownList();
                    reportFilterDropDown.text = "All";
                    reportFilterDropDown.value = "ALL";
                    reportFilterDropDownLists.Add(reportFilterDropDown);
                }
                for (var i = 0; i <= DT.Rows.Count - 1; i++)
                {
                    ReportFilterDropDownList reportFilterDropDown = new ReportFilterDropDownList();
                    reportFilterDropDown.text = DT.Rows[i][TextFieldColName].ToString();
                    reportFilterDropDown.value = DT.Rows[i][ValueFieldColName];
                    reportFilterDropDownLists.Add(reportFilterDropDown);
                }
            }
            return reportFilterDropDownLists;
        }
        public static void SetKendoOptionDataFilter(ref kendo_option_data_filter kendo_Option_Data_Filter, kendo_option_data_filter_filters kendo_Option_Data_Filter_Filters, string logic = "and")
        {
            //kendo_option_data_filter kendo_Option_Data_Filter = new kendo_option_data_filter();
            kendo_option_data_filter2 kendo_Option_Data_Filter2 = new kendo_option_data_filter2();
            kendo_Option_Data_Filter2.logic = logic;
            //kendo_option_data_filter_filters kendo_Option_Data_Filter_Filters = new kendo_option_data_filter_filters();
            kendo_Option_Data_Filter2.filters.Add(kendo_Option_Data_Filter_Filters);
            kendo_Option_Data_Filter.filters.Add(kendo_Option_Data_Filter2);


        }
        public static int? SetPositiveNumericValueInt32(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname)
        {
            int? retval = null;
            double? retdoublevalue = null;
            retdoublevalue = SetNumericValue(obj, ref listofErrors, isnullable, fieldname, typeof(Int32), false);
            if (retdoublevalue != null)
            {
                retval = Convert.ToInt32(retdoublevalue);
            }
            return retval;
        }
        public static int SetPositiveNumericValueInt32NullToZero(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname)
        {
            int retval = 0;
            double? retdoublevalue = null;
            retdoublevalue = SetNumericValue(obj, ref listofErrors, isnullable, fieldname, typeof(Int32), false);
            if (retdoublevalue != null)
            {
                retval = Convert.ToInt32(retdoublevalue);
            }

            return retval;
        }
        public static double? SetPositiveNumericValueDouble(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname)
        {
            double? retdoublevalue = null;
            retdoublevalue = SetNumericValue(obj, ref listofErrors, isnullable, fieldname, typeof(double), false);
            return retdoublevalue;
        }
        public static double SetPositiveNumericValueDoubleNullToZero(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname)
        {
            double retdoublevalue = 0;
            double? tempretdoublevalue = null;
            tempretdoublevalue = SetNumericValue(obj, ref listofErrors, isnullable, fieldname, typeof(double), false);
            if (tempretdoublevalue != null)
            {
                retdoublevalue = Convert.ToDouble(tempretdoublevalue);
            }
            return retdoublevalue;
        }
        public static double? SetNumericValue(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, Type type, bool canbenegative)
        {
            ListofErrors errors = new ListofErrors();
            double? retval = null;
            if (obj == null && isnullable)
            {
                retval = null;
                return retval;
            }
            else if (obj == null && isnullable == false)
            {
                errors = new ListofErrors();
                errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                errors.detailmessage = $"*{fieldname}* invalid value. Value cannot be null";
                listofErrors.Add(errors);
                return retval;
            }
            else if (Information.IsNumeric(obj))
            {
                double? val = null;
                retval = null;
                try
                {
                    val = Convert.ToDouble(obj);
                }
                catch
                {
                    val = null;
                    errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    object maxval = Int32.MaxValue;
                    if (type == typeof(double))
                        maxval = double.MaxValue;
                    else if (type == typeof(Int64))
                        maxval = Int64.MaxValue;
                    else if (type == typeof(long))
                        maxval = long.MaxValue;

                    errors.detailmessage = $"*{fieldname}* invalid value. Value should be between 0 to {maxval.ToString()}. Current Value is {obj}";
                    listofErrors.Add(errors);
                    return retval;
                }
                if (val != null)
                {
                    if (((double)val > 0 && canbenegative == false) || canbenegative)
                    {
                        retval = val;
                        return retval;
                    }
                    else
                    {
                        retval = null;
                        errors = new ListofErrors();
                        errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                        errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                        errors.detailmessage = $"*{fieldname}* invalid value. Must be Positive Numeric value. Current Value is {obj}";
                        listofErrors.Add(errors);
                        return retval;
                    }
                }
            }
            else if (Information.IsNumeric(obj) == false)
            {
                retval = null;
                errors = new ListofErrors();
                errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                errors.detailmessage = $"*{fieldname}* invalid value. Must be Numeric value. Current Value is {obj}";
                listofErrors.Add(errors);
                return retval;
            }
            return retval;
        }
        public static bool? SetBoolValue(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool iswarning, ref List<string> warninglist)
        {
            ListofErrors errors = new ListofErrors();
            bool? retval = null;
            if (obj == null && isnullable)
            {
                retval = null;
                return retval;
            }
            else if (obj == null && isnullable == false)
            {
                if (iswarning)
                {
                    warninglist.Add($"*{fieldname}* invalid value. Value cannot be null");
                    return retval;
                }
                else
                {
                    errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    errors.detailmessage = $"*{fieldname}* invalid value. Value cannot be null";
                    listofErrors.Add(errors);
                    return retval;
                }
            }
            bool rettempvalue = false;
            if (Information.IsNumeric(obj))
            {
                obj = Convert.ToDouble(obj).ToString();
                retval = Convert.ToBoolean(Convert.ToInt32(obj));
                return retval;
            }

            if (bool.TryParse(obj.ToString(), out rettempvalue))
            {
                retval = rettempvalue;
            }
            else
            {
                if (iswarning)
                {
                    warninglist.Add($"*{fieldname}* invalid value. Must be Bool Type. Current Value is {obj}");
                    return retval;
                }
                else
                {
                    retval = null;
                    errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    errors.detailmessage = $"*{fieldname}* invalid value. Must be Bool Type. Current Value is {obj}";
                    listofErrors.Add(errors);
                    return retval;
                }
            }

            return retval;
        }
        public static bool SetBoolValueNullToFalse(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool iswarning, ref List<string> warninglist)
        {
            bool? tempretval = SetBoolValue(obj, ref listofErrors, isnullable, fieldname, iswarning, ref warninglist);
            bool retval = false;
            if (retval && tempretval != null)
            {
                if (tempretval != true)
                {
                    retval = true;
                }
            }
            return retval;
        }
        public static bool SetBoolValueNullToTrue(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool iswarning, ref List<string> warninglist)
        {
            bool? tempretval = SetBoolValue(obj, ref listofErrors, isnullable, fieldname, iswarning, ref warninglist);
            bool retval = true;
            if (retval && tempretval != null)
            {
                if (tempretval != false)
                {
                    retval = false;
                }
            }
            return retval;
        }
        public static string SetStringValueNullToEmpty(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool isnullerror)
        {
            string retval = "";
            if (obj == null)
            {
                if (isnullerror)
                {
                    ListofErrors errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    errors.detailmessage = $"*{fieldname}* invalid value. Value cannot be null";
                    listofErrors.Add(errors);
                }
            }
            else if (obj != null)
            {
                retval = obj.ToString();
            }
            return retval;
        }
        public static string SetNumericStringValueNullToEmpty(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool isnullerror)
        {
            string retval = "";
            if (obj == null)
            {
                if (isnullerror)
                {
                    ListofErrors errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    errors.detailmessage = $"*{fieldname}* invalid value. Value cannot be null";
                    listofErrors.Add(errors);
                }
            }
            else if (obj != null)
            {
                retval = SetNumericStringValue(obj);
            }
            return retval;
        }
        public static string? SetNumericStringValue(string? obj)
        {
            string? retval = null;
            if (obj != null)
            {
                string pattern = "[^0-9]";
                string numericOnly = Regex.Replace(obj, pattern, "");
                retval = numericOnly;
            }

            return retval;
        }
        public static string? IsValidEmail(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool isnullerror)
        {
            string? retval = null;
            ListofErrors errors = new ListofErrors();
            if (obj == null)
            {
                if (isnullerror)
                {
                    errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    errors.detailmessage = $"*{fieldname}* invalid value. Value cannot be null";
                    listofErrors.Add(errors);
                }
            }
            else if (obj != null)
            {
                retval = obj.Replace(",", ";").Replace(" ", ";").Replace(":", ";");
                retval = string.Join(";", retval.Trim().Split(";")).Trim();
                if (Globals.IsValidEmail(retval) == false)
                {
                    errors = new ListofErrors();
                    errors.errorcode = ErrorList.ErrorListInvalidReq.ErrorCode;
                    errors.errormessage = ErrorList.ErrorListInvalidReq.ErrorMsg;
                    errors.errorcode = $"*{fieldname}* invalid value or email format. Current Value is {obj}";
                    listofErrors.Add(errors);
                }
            }
            return retval;
        }
        public static string IsValidEmailNullToEmpty(string? obj, ref List<ListofErrors> listofErrors, bool isnullable, string fieldname, bool isnullerror)
        {
            string? tempretval = null;
            string retval = "";
            tempretval = IsValidEmail(obj, ref listofErrors, isnullable, fieldname, isnullerror);
            if (tempretval != null)
            {
                retval = tempretval;
            }
            return retval;
        }
        public static string GetPinnacleOrderSource(int newordersource)
        {
            string oldordersource = "";
            if (newordersource == 101100)
                oldordersource = "WEB";
            else if (newordersource == 101101)
                oldordersource = "API";
            else if (newordersource == 101102)
                oldordersource = "ASN";
            else if (newordersource == 101103)
                oldordersource = "MOBILE";
            else if (newordersource == 101104)
                oldordersource = "GUEST";
            else if (newordersource == 101105 || newordersource == 101106)
                oldordersource = "IMPORT";
            else if (newordersource == 101107)
                oldordersource = "PPLUS";
            return oldordersource;
        }
        public static string GetPinnacleClientType(string newusertype)
        {
            string oldclienttype = "";
            if (newusertype.ToUpper() == "METRO-USER")
                oldclienttype = "Metro";
            else if (newusertype.ToUpper() == "CLIENT-USER")
                oldclienttype = "Client";
            else if (newusertype.ToUpper() == "GUEST-USER")
                oldclienttype = "Guest";
            return oldclienttype;
        }
        public static int GetPinnacleOrderType(int newordertype)
        {
            int oldordertype = newordertype;
            if (newordertype == 146100)
                oldordertype = 10000;
            else if (newordertype == 146101)
                oldordertype = 20000;
            else if (newordertype == 146102)
                oldordertype = 30000;
            else if (newordertype == 146103)
                oldordertype = 40000;
            else if (newordertype == 146104)
                oldordertype = 50000;
            else if (newordertype == 146105)
                oldordertype = 60000;
            else if (newordertype == 146106)
                oldordertype = 70000;
            else if (newordertype == 146107)
                oldordertype = 80000;
            else if (newordertype == 146108)
                oldordertype = 90000;
            else if (newordertype == 146109)
                oldordertype = 10000;
            else if (newordertype == 146110)
                oldordertype = 110000;
            else if (newordertype == 146111)
                oldordertype = 120000;
            else if (newordertype == 146112)
                oldordertype = 130000;
            else if (newordertype == 146113)
                oldordertype = 140000;

            return oldordertype;
        }
        public static int GetPinnacleSubOrderType(int newordertype, int? newsubordertype)
        {
            int oldsubordertype = (newsubordertype == null ? 0 : (int)newsubordertype);
            if (newsubordertype == null)
                return oldsubordertype;

            if (newordertype == 146101)
            {
                if (newsubordertype == 0)
                    oldsubordertype = 0;
                else if (newsubordertype == 1)
                    oldsubordertype = 1;
                else if (newsubordertype == 2)
                    oldsubordertype = 2;
                else if (newsubordertype == 3)
                    oldsubordertype = 3;
                else if (newsubordertype == 4)
                    oldsubordertype = 4;
                else if (newsubordertype == 5)
                    oldsubordertype = 5;
                else if (newsubordertype == 6)
                    oldsubordertype = 6;
                else if (newsubordertype == 7)
                    oldsubordertype = 7;
                else if (newsubordertype == 8)
                    oldsubordertype = 8;
                else if (newsubordertype == 9)
                    oldsubordertype = 9;
                else if (newsubordertype == 10)
                    oldsubordertype = 10;
                else if (newsubordertype == 11)
                    oldsubordertype = 11;
                else if (newsubordertype == 12)
                    oldsubordertype = 12;
            }
            else if (newordertype == 146102)
            {
                if (newsubordertype == 0)
                    oldsubordertype = 0;
                else if (newsubordertype == 1)
                    oldsubordertype = 1;
                else if (newsubordertype == 2)
                    oldsubordertype = 2;
                else if (newsubordertype == 3)
                    oldsubordertype = 3;
                else if (newsubordertype == 4)
                    oldsubordertype = 4;
                else if (newsubordertype == 5)
                    oldsubordertype = 5;
                else if (newsubordertype == 6)
                    oldsubordertype = 6;
                else if (newsubordertype == 7)
                    oldsubordertype = 7;
                else if (newsubordertype == 8)
                    oldsubordertype = 8;
                else if (newsubordertype == 9)
                    oldsubordertype = 9;
                else if (newsubordertype == 10)
                    oldsubordertype = 10;
                else if (newsubordertype == 11)
                    oldsubordertype = 11;
                else if (newsubordertype == 12)
                    oldsubordertype = 12;
            }

            return oldsubordertype;
        }
        public static string GetPinnacleItemTypeCode(string newitemcode)
        {
            string Ret = newitemcode;
            if (newitemcode.ToUpper() == "VTY".ToUpper())
                Ret = "CG";
            else if (newitemcode.ToUpper() == "PAT".ToUpper())
                Ret = "CG";

            return Ret;
        }
        public static string GetPinnacleItemTypeName(string newitemcode)
        {
            string Ret = "-";
            if (newitemcode.ToUpper() == "OTH".ToUpper())
                Ret = "Other";
            else if (newitemcode.ToUpper() == "CG".ToUpper())
                Ret = "CaseGood";
            else if (newitemcode.ToUpper() == "UP".ToUpper())
                Ret = "Upholstery";
            else if (newitemcode.ToUpper() == "C-AR".ToUpper())
                Ret = "Carpet or Area Rugs";
            else if (newitemcode.ToUpper() == "LIGHTING".ToUpper())
                Ret = "Lighting";
            else if (newitemcode.ToUpper() == "VTY".ToUpper())
                Ret = "CaseGood";
            else if (newitemcode.ToUpper() == "PAT".ToUpper())
                Ret = "CaseGood";

            return Ret;
        }
        public static string GetPinnacleItemPackedByShipperRequired(string newpackingcode)
        {
            string Ret = "";
            if (newpackingcode.ToUpper() == "PK-SP".ToUpper())
                Ret = "Yes";
            else if (newpackingcode.ToUpper() == "PK-REQ".ToUpper())
                Ret = "No";
            else if (newpackingcode.ToUpper() == "BW-REQ".ToUpper())
                Ret = "Yes";
            else if (newpackingcode.ToUpper() == "CR-REQ".ToUpper())
                Ret = "Yes";
            else if (newpackingcode.ToUpper() == "BW-PK-REQ".ToUpper())
                Ret = "No";
            else if (newpackingcode.ToUpper() == "PK-CR-REQ".ToUpper())
                Ret = "Yes";
            else if (newpackingcode.ToUpper() == "BW-PK-CR-REQ".ToUpper())
                Ret = "No";
            else if (newpackingcode.ToUpper() == "BW-CR-REQ".ToUpper())
                Ret = "Yes";

            return Ret;
        }
        public static string GetPinnacleBlanketWrapRequired(string newpackingcode)
        {
            string Ret = "N";
            if (newpackingcode.ToUpper() == "PK-SP".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "PK-REQ".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "BW-REQ".ToUpper())
                Ret = "Y";
            else if (newpackingcode.ToUpper() == "CR-REQ".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "BW-PK-REQ".ToUpper())
                Ret = "Y";
            else if (newpackingcode.ToUpper() == "PK-CR-REQ".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "BW-PK-CR-REQ".ToUpper())
                Ret = "Y";
            else if (newpackingcode.ToUpper() == "BW-CR-REQ".ToUpper())
                Ret = "Y";

            return Ret;
        }
        public static string GetPinnacleCrateRequired(string newpackingcode)
        {
            string Ret = "N";
            if (newpackingcode.ToUpper() == "PK-SP".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "PK-REQ".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "BW-REQ".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "CR-REQ".ToUpper())
                Ret = "Y";
            else if (newpackingcode.ToUpper() == "BW-PK-REQ".ToUpper())
                Ret = "N";
            else if (newpackingcode.ToUpper() == "PK-CR-REQ".ToUpper())
                Ret = "Y";
            else if (newpackingcode.ToUpper() == "BW-PK-CR-REQ".ToUpper())
                Ret = "Y";
            else if (newpackingcode.ToUpper() == "BW-CR-REQ".ToUpper())
                Ret = "Y";

            return Ret;
        }
        public static string GetPOMSItemsToShipCode(string OldItemtemsToShip)
        {
            string Ret = "OTH";
            if (OldItemtemsToShip.ToUpper() == "NF".ToUpper())
                Ret = "NEW";
            else if (OldItemtemsToShip.ToUpper() == "HH".ToUpper())
                Ret = "USED";
            else if (OldItemtemsToShip.ToUpper() == "OTH".ToUpper())
                Ret = "OTH";

            return Ret;
        }
        public static string GetPinnacleItemsToShipName(string OldItemtemsToShip)
        {
            string Ret = "";
            if (OldItemtemsToShip.ToUpper() == "NF".ToUpper())
                Ret = "New Furniture";
            else if (OldItemtemsToShip.ToUpper() == "HH".ToUpper())
                Ret = "Household/Used items";
            else if (OldItemtemsToShip.ToUpper() == "OTH".ToUpper())
                Ret = "Other";

            return Ret;
        }
        public static string GetPinnacleItemsToShipCode(string OldItemtemsToShip)
        {
            string Ret = "";
            if (OldItemtemsToShip.ToUpper() == "NF".ToUpper())
                Ret = "New Furniture";
            else if (OldItemtemsToShip.ToUpper() == "HH".ToUpper())
                Ret = "Household/Used items";
            else if (OldItemtemsToShip.ToUpper() == "OTH".ToUpper())
                Ret = "Other";

            return Ret;
        }
        public static string? GetDateTime24HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (Information.IsDate(obj))
                {
                    if (Convert.ToDateTime(obj).Year > 2000)
                        ReturnText = Convert.ToDateTime(obj.ToString()).ToString("yyyy-MM-dd HH:mm:ss.fff");
                }
                else if (Information.IsNumeric(obj))
                {
                    TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                    DateTime baseDate = new DateTime(1900, 1, 1);
                    DateTime dateTime = baseDate + timeSpan;
                    if (dateTime.Year > 2000)
                        ReturnText = dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff");
                }
            }

            return ReturnText;
        }
        public static string? GetDateTime12HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (Information.IsDate(obj))
                {
                    if (Convert.ToDateTime(obj).Year > 2000)
                        ReturnText = Convert.ToDateTime(obj.ToString()).ToString("yyyy-MM-dd hh:mm:ss.fff tt");
                }
                else if (Information.IsNumeric(obj))
                {
                    TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                    DateTime baseDate = new DateTime(1900, 1, 1);
                    DateTime dateTime = baseDate + timeSpan;
                    if (dateTime.Year > 2000)
                        ReturnText = dateTime.ToString("yyyy-MM-dd hh:mm:ss.fff tt");
                }
            }

            return ReturnText;
        }
        public static string? GetDate(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (Information.IsDate(obj))
                {
                    if (Convert.ToDateTime(obj).Year > 2000)
                        ReturnText = Convert.ToDateTime(obj.ToString()).ToString("yyyy-MM-dd");
                }
                else if (Information.IsNumeric(obj))
                {
                    TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                    DateTime baseDate = new DateTime(1900, 1, 1);
                    DateTime dateTime = baseDate + timeSpan;
                    if (dateTime.Year > 2000)
                        ReturnText = dateTime.ToString("yyyy-MM-dd");
                }
            }

            return ReturnText;
        }
        public static string? GetTimeWithMilliSeconds24HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (DateTime.TryParseExact(obj.ToString(), "HH:mm:ss.fff", null, System.Globalization.DateTimeStyles.None, out DateTime result) && Information.IsNumeric(obj) == false)
                {
                    ReturnText = result.ToString("HH:mm:ss.fff");
                }
                else if (Information.IsNumeric(obj))
                {
                    if (Convert.ToDouble(obj) > 0)
                    {
                        if (Convert.ToDouble(obj) < 1900)
                            obj = Convert.ToDouble(obj) + Math.Round((1900 - Convert.ToDouble(obj)), 0);
                        TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                        DateTime baseDate = new DateTime(1900, 1, 1);
                        DateTime dateTime = baseDate + timeSpan;
                        ReturnText = dateTime.ToString("HH:mm:ss.fff");
                    }
                }
            }

            return ReturnText;
        }
        public static string? GetTimeWithMilliSeconds12HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (DateTime.TryParseExact(obj.ToString(), "hh:mm:ss.fff tt", null, System.Globalization.DateTimeStyles.None, out DateTime result) && Information.IsNumeric(obj) == false)
                {
                    ReturnText = result.ToString("hh:mm:ss.fff tt");
                }
                else if (Information.IsNumeric(obj))
                {
                    if (Convert.ToDouble(obj) > 0)
                    {
                        if (Convert.ToDouble(obj) < 1900)
                            obj = Convert.ToDouble(obj) + Math.Round((1900 - Convert.ToDouble(obj)), 0);
                        TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                        DateTime baseDate = new DateTime(1900, 1, 1);
                        DateTime dateTime = baseDate + timeSpan;
                        ReturnText = dateTime.ToString("hh:mm:ss.fff tt");
                    }
                }
            }

            return ReturnText;
        }
        public static string? GetTimeWithSeconds24HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (DateTime.TryParseExact(obj.ToString(), "HH:mm:ss", null, System.Globalization.DateTimeStyles.None, out DateTime result) && Information.IsNumeric(obj) == false)
                {
                    ReturnText = result.ToString("HH:mm:ss");
                }
                else if (Information.IsNumeric(obj))
                {
                    if (Convert.ToDouble(obj) > 0)
                    {
                        if (Convert.ToDouble(obj) < 1900)
                            obj = Convert.ToDouble(obj) + Math.Round((1900 - Convert.ToDouble(obj)), 0);
                        TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                        DateTime baseDate = new DateTime(1900, 1, 1);
                        DateTime dateTime = baseDate + timeSpan;
                        ReturnText = dateTime.ToString("HH:mm:ss");
                    }
                }
            }

            return ReturnText;
        }
        public static string? GetTimeWithSeconds12HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (DateTime.TryParseExact(obj.ToString(), "hh:mm:ss tt", null, System.Globalization.DateTimeStyles.None, out DateTime result) && Information.IsNumeric(obj) == false)
                {
                    ReturnText = result.ToString("hh:mm:ss tt");
                }
                else if (Information.IsNumeric(obj))
                {
                    if (Convert.ToDouble(obj) > 0)
                    {
                        if (Convert.ToDouble(obj) < 1900)
                            obj = Convert.ToDouble(obj) + Math.Round((1900 - Convert.ToDouble(obj)), 0);
                        TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                        DateTime baseDate = new DateTime(1900, 1, 1);
                        DateTime dateTime = baseDate + timeSpan;
                        ReturnText = dateTime.ToString("hh:mm:ss tt");
                    }
                }
            }

            return ReturnText;
        }
        public static string? GetTimeWithOutSeconds24HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (DateTime.TryParseExact(obj.ToString(), "HH:mm", null, System.Globalization.DateTimeStyles.None, out DateTime result) && Information.IsNumeric(obj) == false)
                {
                    ReturnText = result.ToString("HH:mm");
                }
                else if (Information.IsNumeric(obj))
                {
                    if (Convert.ToDouble(obj) > 0)
                    {
                        if (Convert.ToDouble(obj) < 1900)
                            obj = Convert.ToDouble(obj) + Math.Round((1900 - Convert.ToDouble(obj)), 0);
                        TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                        DateTime baseDate = new DateTime(1900, 1, 1);
                        DateTime dateTime = baseDate + timeSpan;
                        ReturnText = dateTime.ToString("HH:mm");
                    }
                }
            }

            return ReturnText;
        }
        public static string? GetTimeWithOutSeconds12HoursFormat(object? obj, bool IsReturnNull = true)
        {
            string? ReturnText = (IsReturnNull ? null : "");

            if (obj != null)
            {
                if (DateTime.TryParseExact(obj.ToString(), "hh:mm", null, System.Globalization.DateTimeStyles.None, out DateTime result) && Information.IsNumeric(obj) == false)
                {
                    ReturnText = result.ToString("hh:mm");
                }
                else if (Information.IsNumeric(obj))
                {
                    if (Convert.ToDouble(obj) > 0)
                    {
                        if (Convert.ToDouble(obj) < 1900)
                            obj = Convert.ToDouble(obj) + Math.Round((1900 - Convert.ToDouble(obj)), 0);
                        TimeSpan timeSpan = TimeSpan.FromDays(Convert.ToDouble(obj));
                        DateTime baseDate = new DateTime(1900, 1, 1);
                        DateTime dateTime = baseDate + timeSpan;
                        ReturnText = dateTime.ToString("hh:mm");
                    }
                }
            }

            return ReturnText;
        }
        public static string ConvertToStandardTime(string timeValue)
        {
            string formattedTime = "";
            if (timeValue.Length > 8)
            {
                throw new Exception("Unable to convert to Time");
            }
            if (timeValue.Length == 8)
            {
                // Extract components
                int hours = int.Parse(timeValue.Substring(0, 2));
                int minutes = int.Parse(timeValue.Substring(2, 2));
                int seconds = int.Parse(timeValue.Substring(4, 2));
                int hundredths = int.Parse(timeValue.Substring(6, 2));

                // Format the standard time
                formattedTime = $"{hours:D2}:{minutes:D2}:{seconds:D2}.{hundredths:D2}";

                return formattedTime;
            }
            else if (timeValue.Length == 6)
            {
                // Extract components
                int hours = int.Parse(timeValue.Substring(0, 2));
                int minutes = int.Parse(timeValue.Substring(2, 2));
                int seconds = int.Parse(timeValue.Substring(4, 2));

                // Format the standard time
                formattedTime = $"{hours:D2}:{minutes:D2}:{seconds:D2}";

                return formattedTime;
            }
            else if (timeValue.Length == 4)
            {
                // Extract components
                int hours = int.Parse(timeValue.Substring(0, 2));
                int minutes = int.Parse(timeValue.Substring(2, 2));

                // Format the standard time
                formattedTime = $"{hours:D2}:{minutes:D2}";

                return formattedTime;
            }
            else if (timeValue.Length > 0)
            {
                throw new Exception("Unable to convert to Time");
            }

            return formattedTime;
        }
        public static string? ExtractBase64String(string? inputString)
        {
            if (string.IsNullOrEmpty(inputString))
                return inputString;

            int indexOfBase64 = inputString.IndexOf(";base64,", StringComparison.OrdinalIgnoreCase);

            if (indexOfBase64 != -1 && indexOfBase64 + 8 < inputString.Length)
            {
                return inputString.Substring(indexOfBase64 + 8).Trim();
            }

            // If the delimiter is not found or there's nothing after the delimiter, return the original string
            return inputString;
        }
        public static DataRow[]? Get_Import_Order_File_Source_Setup_DR(DataTable DT, string? FileSource_MTV_CODE, string? OrderSubSource_MTV_CODE, string Code_MTV_CODE, string CODE2 = "")
        {
            DataRow[]? Dr_config = null;
            string Filtered = "";
            try
            {
                if (FileSource_MTV_CODE != null)
                    Filtered += $"{(Filtered == "" ? "" : " and ")}FileSource_MTV_CODE='{FileSource_MTV_CODE}'";

                if (OrderSubSource_MTV_CODE != null)
                    Filtered += $"{(Filtered == "" ? "" : " and ")}OrderSubSource_MTV_CODE='{OrderSubSource_MTV_CODE}'";

                Filtered += $"{(Filtered == "" ? "" : " and ")}Code_MTV_CODE='{Code_MTV_CODE}'";
                Filtered += $"{(Filtered == "" ? "" : " and ")}CODE2='{CODE2}'";

                Dr_config = DT.Select(string.Format($"{Filtered}"));
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Get_Import_Order_File_Source_Setup_DR", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return Dr_config;
        }
        public static string? Get_Import_Order_File_Source_Setup(DataTable DT, ref string? RefNo1, ref string? RefNo2, ref string? RefNo3, string? FileSource_MTV_CODE, string? OrderSubSource_MTV_CODE, string Code_MTV_CODE, string CODE2 = "")
        {
            RefNo1 = null;
            RefNo2 = null;
            RefNo3 = null;
            DataRow[]? Dr_config = null;
            Dr_config = Get_Import_Order_File_Source_Setup_DR(DT, FileSource_MTV_CODE, OrderSubSource_MTV_CODE, Code_MTV_CODE, CODE2);
            if (Dr_config != null)
            {
                if (Dr_config.Length > 0)
                {
                    RefNo1 = ConvertDBNulltoNullIfExistsString(Dr_config[0]["REFNO1"]);
                    RefNo2 = ConvertDBNulltoNullIfExistsString(Dr_config[0]["REFNO2"]);
                    RefNo3 = ConvertDBNulltoNullIfExistsString(Dr_config[0]["REFNO3"]);
                }
            }
            return RefNo1;
        }
        public static List<ValidationResult>? GetDistinctValidationResult(ref List<ValidationResult>? results, bool IsIncludeIgnoreError = false)
        {
            List<ValidationResult>? Ret = new List<ValidationResult>();
            if (results != null)
            {
                if (results.Count > 0)
                {
                    for (int i = 0; i <= results.Count - 1; i++)
                    {
                        string ErrorMsg = results[i].ErrorMessage.Trim();
                        if ((Strings.Left(ErrorMsg.ToLower(), 12) == "ignore error" && IsIncludeIgnoreError))
                        {
                            ErrorMsg = Strings.Mid(ErrorMsg, 15).Trim();
                            Ret.Add(new ValidationResult(ErrorMsg));
                        }
                        else if (Strings.Left(ErrorMsg.ToLower(), 12) != "ignore error" && IsIncludeIgnoreError == false)
                        {
                            Ret.Add(new ValidationResult(ErrorMsg));
                        }
                    }
                    if (Ret.Count > 1)
                    {
                        var ErrorsComparer = new DynamicEqualityComparer<ValidationResult>(c => c.ErrorMessage);
                        Ret = Ret.Distinct(ErrorsComparer).ToList();
                    }
                }
                else
                    Ret = results;
            }
            else
                Ret = results;

            return Ret;
        }
        public static void ValidateChildObjects(object obj, ref List<ValidationResult> results, ref bool isValid)
        {
            var resultstemp = new List<ValidationResult>();
            var context = new ValidationContext(obj);

            // Validate the current object
            var isValid2 = Validator.TryValidateObject(obj, context, resultstemp, true);

            if (isValid2 == false)
            {
                foreach (var validationResult in resultstemp)
                {
                    results.Add(validationResult);
                }
            }

            if (isValid == true && isValid2 == false)
                isValid = isValid2;

            // If the current object is not valid, stop further validation for this branch
            if (!isValid)
            {
                foreach (var property in obj.GetType().GetProperties())
                {
                    // Check if the property is an object and not a primitive type or string
                    if (property != null)
                    {
                        if (property.PropertyType.IsClass)
                        {
                            GetCustomAttributeValidationResult(property, obj, ref results);
                        }
                    }
                }
                return;
            }

            // Validate child properties recursively
            foreach (var property in obj.GetType().GetProperties())
            {
                // Check if the property is an object and not a primitive type or string
                if (property != null)
                {
                    if (property.PropertyType.IsClass)
                    {
                        if (property.PropertyType != typeof(string))
                        {
                            // Check if the property has parameters (indexers)
                            if (property.GetIndexParameters().Length == 0)
                            {
                                var childObject = property.GetValue(obj);

                                // Recursively validate child objects
                                if (childObject != null)
                                {
                                    ValidateChildObjects(childObject, ref results, ref isValid);
                                }
                            }
                        }

                        GetCustomAttributeValidationResult(property, obj, ref results);
                    }
                }
            }
        }
        public static void GetCustomAttributeValidationResult(PropertyInfo property, object obj, ref List<ValidationResult> results)
        {
            // Check for custom validation attributes
            var customAttributes = property.GetCustomAttributes(typeof(CustomValidationAttribute2), true);

            foreach (var attribute in customAttributes)
            {
                if (attribute is CustomValidationAttribute2 customValidationAttribute)
                {
                    // Get the current property value
                    var propertyValue = property.GetValue(obj);

                    // Check if customValidationAttribute is not null
                    if (customValidationAttribute != null)
                    {
                        // Get the Validate method using reflection with parameter types
                        var validateMethod = customValidationAttribute.GetType().GetMethod("Validate",
                            new[] { propertyValue?.GetType() ?? typeof(object), typeof(ValidationContext) });

                        // Check if the Validate method exists
                        if (validateMethod != null)
                        {
                            // Parameters for the Validate method (adjust as needed)
                            var parameters = new object[] { propertyValue, new ValidationContext(obj) };

                            try
                            {
                                // Invoke the Validate method
                                var validationResult = (ValidationResult)validateMethod.Invoke(customValidationAttribute, parameters);

                                // Check the result of the custom validation
                                if (validationResult != ValidationResult.Success)
                                {
                                    // Handle the validation failure (add to results list)
                                    results.Add(validationResult);
                                }
                            }
                            catch (Exception ex)
                            {
                                results.Add(new ValidationResult(ex.InnerException?.Message));
                            }

                        }
                        else
                        {
                            // Handle the case where the Validate method is not found
                            // You might want to log or throw an exception depending on your requirements
                        }
                    }
                }
            }
        }
        public static T? GetValueFromReturnParameter<T>(List<Dynamic_SP_Params> List_Dynamic_SP_Params, string ParameterName, Type type_)
        {
            object? returnvalue = null;
            for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
            {
                if (type_ == typeof(int))
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName && Information.IsNumeric(List_Dynamic_SP_Params[i].Val))
                        returnvalue = Convert.ToInt32(List_Dynamic_SP_Params[i].Val);
                }
                else if (type_ == typeof(long))
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName && Information.IsNumeric(List_Dynamic_SP_Params[i].Val))
                        returnvalue = Convert.ToInt64(List_Dynamic_SP_Params[i].Val);
                }
                else if (type_ == typeof(string))
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName && List_Dynamic_SP_Params[i].Val != null)
                        returnvalue = List_Dynamic_SP_Params[i].Val.ToString();
                }
                else
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName)
                        returnvalue = List_Dynamic_SP_Params[i].Val;
                }
            }
            return (T?)returnvalue;
        }
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

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = true;
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = true;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = true;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = true;

            return RetValue;
        }
        public static bool GetDefaultSetSQLCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static bool GetDefaultGetCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = true;
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = true;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = true;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = true;

            return RetValue;
        }
        public static bool GetDefaultGetSQLCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static bool GetDefaultRemoveCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static bool GetDefaultRemoveSQLCache(string? subtype)
        {
            bool DefaultValue = false;
            subtype = (subtype == null ? "" : subtype);
            bool RetValue = DefaultValue;

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = false;
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = false;

            return RetValue;
        }
        public static int GetDefaultCacheExpirySeconds(string? subtype)
        {
            int DefaultValue = 60;
            subtype = (subtype == null ? "" : subtype);
            int RetValue = DefaultValue;
            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
                RetValue = GetSeconds(hours: 6);
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
                RetValue = GetSeconds(minutes: 20);
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_RoleID)
                RetValue = GetSeconds(hours: 6);
            else if (subtype == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
                RetValue = GetSeconds(hours: 6);

            return RetValue;
        }
        public static List<string>? GetCacheType(string? subtype)
        {
            subtype = (subtype == null ? "" : subtype);
            List<string>? RetValue = new List<string>();

            if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_RoleID)
            {
                RetValue.Add(AppEnum.CacheType.TUsers);
            }
            else if (subtype == AppEnum.CacheSubType.P_Get_Role_Rights_From_Username)
            {
                RetValue.Add(AppEnum.CacheType.TUsers);
            }

            if (RetValue.Count == 0)
                RetValue = null;
            return RetValue;
        }
        public static List<string>? GetCacheSubType(string? type)
        {
            type = (type == null ? "" : type);
            List<string>? RetValue = new List<string>();

            if (type == AppEnum.CacheType.TAPIUserMapRequestLimit)
            {
                RetValue.Add(AppEnum.CacheSubType.P_Is_Has_Right_From_Username);
            }
            else if (type == AppEnum.CacheSubType.P_Is_Has_Right_From_Username)
            {
                RetValue.Add(AppEnum.CacheSubType.P_Is_Has_Right_From_Username);
            }

            if (RetValue.Count == 0)
                RetValue = null;
            return RetValue;
        }
    }

    public class CustomContractResolverStandard : DefaultContractResolver
    {
        private readonly bool _useCustomContractResolver;
        private readonly bool _isoriginalmembername;
        private readonly bool _isexcludefilebase64field;
        public CustomContractResolverStandard(bool useCustomContractResolver, bool isoriginalmembername, bool isexcludefilebase64field) : base()
        {
            _useCustomContractResolver = useCustomContractResolver;
            _isoriginalmembername = isoriginalmembername;
            _isexcludefilebase64field = isexcludefilebase64field;
            NamingStrategy = new CamelCaseNamingStrategy();
        }
        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);

            if (property != null && _useCustomContractResolver)
            {
                if (_isoriginalmembername && property.PropertyName != null)
                    property.PropertyName = member.Name;
                // Check if the IgnoreDataMemberAttribute is defined on the member
                if (member.GetCustomAttributes(typeof(IgnoreDataMemberAttribute), true).Length > 0)
                {
                    // Only ignore the property during serialization
                    if (memberSerialization == MemberSerialization.Fields || memberSerialization == MemberSerialization.OptIn || memberSerialization == MemberSerialization.OptOut)
                        //if (memberSerialization != MemberSerialization.OptIn)
                        property.Ignored = false;
                }

                // Check if the JsonIgnoreAttribute is defined on the member
                if (member.GetCustomAttributes(typeof(JsonIgnoreAttribute), true).Length > 0)
                {
                    // Only ignore the property during serialization
                    if (memberSerialization == MemberSerialization.Fields || memberSerialization == MemberSerialization.OptIn || memberSerialization == MemberSerialization.OptOut)
                        //if (memberSerialization != MemberSerialization.OptIn)
                        property.Ignored = false;
                }
                if (_isexcludefilebase64field && (property.PropertyName?.ToLower() == "filebase64" || property.PropertyName?.ToLower() == "filedatabase64"))
                    property.Ignored = true;
            }

            return property;
        }
        //protected override string ResolvePropertyName(string propertyName)
        //{
        //    return propertyName.ToLower();
        //}
    }
    public class CustomContractResolverNone : DefaultContractResolver
    {
        private readonly bool _isoriginalmembername;
        private readonly bool _isexcludefilebase64field;
        public CustomContractResolverNone(bool isoriginalmembername, bool isexcludefilebase64field) : base()
        {
            _isoriginalmembername = isoriginalmembername;
            _isexcludefilebase64field = isexcludefilebase64field;
            NamingStrategy = new CamelCaseNamingStrategy();
        }
        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);

            if (property != null)
            {
                if (_isoriginalmembername && property.PropertyName != null)
                    property.PropertyName = member.Name;

                property.Ignored = false;
                if (member.DeclaringType == typeof(RequestDocs) && member.Name.ToLower() == "filebase64")
                    property.Ignored = true;
                if (_isexcludefilebase64field && (property.PropertyName?.ToLower() == "filebase64" || property.PropertyName?.ToLower() == "filedatabase64"))
                    property.Ignored = true;
            }

            return property;
        }
        //protected override string ResolvePropertyName(string propertyName)
        //{
        //    return propertyName.ToLower();
        //}
    }
    public class CustomContractResolverHideProperty : DefaultContractResolver
    {
        private readonly bool _IsDeserialize;
        private readonly bool _isoriginalmembername;
        private readonly bool _isexcludefilebase64field;
        public CustomContractResolverHideProperty(bool IsDeserialize = false, bool isoriginalmembername = false, bool isexcludefilebase64field = false) : base()
        {
            _IsDeserialize = IsDeserialize;
            _isoriginalmembername = isoriginalmembername;
            _isexcludefilebase64field = isexcludefilebase64field;
            NamingStrategy = new CamelCaseNamingStrategy();
        }
        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);
            if (property != null)
            {
                if (_isoriginalmembername && property.PropertyName != null)
                    property.PropertyName = member.Name;
                if (_isexcludefilebase64field && (property.PropertyName?.ToLower() == "filebase64" || property.PropertyName?.ToLower() == "filedatabase64"))
                    property.Ignored = true;

                if (property.Ignored && !(_isexcludefilebase64field && (property.PropertyName?.ToLower() == "filebase64" || property.PropertyName?.ToLower() == "filedatabase64")))
                {
                    bool isDeserialize = _IsDeserialize;
                    HidePropertyAttribute hideAttribute = Attribute.GetCustomAttribute(member, typeof(HidePropertyAttribute)) as HidePropertyAttribute;
                    if (hideAttribute != null)
                    {
                        // Only ignore the property during serialization
                        if (((memberSerialization == MemberSerialization.OptIn || isDeserialize) && hideAttribute.IsHideDeSerialize) || ((memberSerialization == MemberSerialization.OptIn || isDeserialize == false) && hideAttribute.IsHideSerialize))
                        {
                            bool IsIgnored = property.Ignored;
                            if (isDeserialize == false && memberSerialization == MemberSerialization.OptIn)
                                isDeserialize = true;
                            string Propertyname = (property.PropertyName == null ? "" : property.PropertyName.ToLower());
                            VerifyHidePropertyAttributeValid(ref IsIgnored, hideAttribute, isDeserialize, Propertyname);
                            property.Ignored = IsIgnored;
                        }
                        else
                            property.Ignored = false;
                    }
                }
            }

            return property;
        }
        //protected override string ResolvePropertyName(string propertyName)
        //{
        //    return propertyName.ToLower();
        //}
        public void VerifyHidePropertyAttributeValid(ref bool IsIgnore, HidePropertyAttribute hidePropertyAttribute, bool isDeserialize, string Propertyname)
        {
            PublicClaimObjects _PublicClaimObjects = StaticPublicObjects.ado.GetPublicClaimObjects();
            string? remotedomain = "";
            try
            {
                remotedomain = StaticPublicObjects.ado.GetRemoteDomain();
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "VerifyHidePropertyValid", SmallMessage: ex.Message, Message: ex.ToString());
            }
            if (IsIgnore && hidePropertyAttribute.IsHideSerialize == false && isDeserialize == false)
            {
                IsIgnore = false;
                return;
            }
            else if (IsIgnore && hidePropertyAttribute.IsHideDeSerialize == false && isDeserialize)
            {
                IsIgnore = false;
                return;
            }

            if (hidePropertyAttribute.IsHideSerialize && isDeserialize == false)
            {
                if (hidePropertyAttribute.IsCheckHideSerializeFromPublicObject && _PublicClaimObjects.isignorejsonserializeproperty)
                {
                    IsIgnore = false;
                    return;
                }
                else if (hidePropertyAttribute.IsCheckHideSerializeFromPublicObjectList && _PublicClaimObjects.ignorejsonserializepropertylist != null)
                {
                    if (ValueExistsInArry(_PublicClaimObjects.ignorejsonserializepropertylist, Propertyname))
                    {
                        IsIgnore = false;
                        return;
                    }
                }
                else if (hidePropertyAttribute.RemoteDomainIncludeHideSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.RemoteDomainIncludeHideSerialize, remotedomain))
                    {
                        IsIgnore = false;
                        return;
                    }
                }
                else if (hidePropertyAttribute.RemoteDomainExcludeHideSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.RemoteDomainExcludeHideSerialize, remotedomain))
                    {
                        IsIgnore = true;
                        return;
                    }
                }
                else if (hidePropertyAttribute.RemoteDomainIncludeHideSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.RemoteDomainIncludeHideSerialize, _PublicClaimObjects.username))
                    {
                        IsIgnore = false;
                        return;
                    }
                }
                else if (hidePropertyAttribute.UserExcludeHideSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.UserExcludeHideSerialize, _PublicClaimObjects.username))
                    {
                        IsIgnore = true;
                        return;
                    }
                }
            }
            else if (hidePropertyAttribute.IsHideDeSerialize && isDeserialize)
            {
                if (hidePropertyAttribute.IsCheckHideDeSerializeFromPublicObject && _PublicClaimObjects.isignorejsondeserializeproperty)
                {
                    IsIgnore = false;
                    return;
                }
                else if (hidePropertyAttribute.IsCheckHideDeSerializeFromPublicObjectList && _PublicClaimObjects.ignorejsondeserializepropertylist != null)
                {
                    if (ValueExistsInArry(_PublicClaimObjects.ignorejsondeserializepropertylist, Propertyname))
                    {
                        IsIgnore = false;
                        return;
                    }
                }
                else if (hidePropertyAttribute.RemoteDomainIncludeHideDeSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.RemoteDomainIncludeHideDeSerialize, remotedomain))
                    {
                        IsIgnore = false;
                        return;
                    }
                }
                else if (hidePropertyAttribute.RemoteDomainExcludeHideDeSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.RemoteDomainExcludeHideDeSerialize, remotedomain))
                    {
                        IsIgnore = true;
                        return;
                    }
                }
                else if (hidePropertyAttribute.RemoteDomainIncludeHideDeSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.RemoteDomainIncludeHideDeSerialize, _PublicClaimObjects.username))
                    {
                        IsIgnore = false;
                        return;
                    }
                }
                else if (hidePropertyAttribute.UserExcludeHideDeSerialize != null)
                {
                    if (ValueExistsInArry(hidePropertyAttribute.UserExcludeHideDeSerialize, _PublicClaimObjects.username))
                    {
                        IsIgnore = true;
                        return;
                    }
                }
            }
        }
        public bool ValueExistsInArry(string[]? elements, string? comparevalue)
        {
            comparevalue = (comparevalue == null ? "" : comparevalue);
            if (elements != null)
            {
                foreach (string element in elements)
                {
                    if (element == comparevalue)
                        return true;
                }
            }
            return false;
        }
        public bool ValueExistsInArry(List<string>? elements, string? comparevalue)
        {
            comparevalue = (comparevalue == null ? "" : comparevalue);
            if (elements != null)
            {
                foreach (string element in elements)
                {
                    if (element == comparevalue)
                        return true;
                }
            }
            return false;
        }
    }
    public class IgnoreCasePropertyNamesContractResolver : DefaultContractResolver
    {
        protected override string ResolvePropertyName(string propertyName)
        {
            return propertyName.ToLower();
        }
    }
    public class CustomContractResolverMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IHttpContextAccessor httpContextAccessor;
        public CustomContractResolverMiddleware(RequestDelegate next, IHttpContextAccessor httpContextAccessor)
        {
            _next = next;
            this.httpContextAccessor = httpContextAccessor;
        }
        public async Task InvokeAsync(HttpContext context)
        {
            //if (context.Response.HasStarted == false && StaticPublicObjects.ado.IsSwaggerCall())
            //{
            //    // Get the serializer settings from the service provider
            //    var serializerSettings = (JsonSerializerSettings)context
            //        .RequestServices.GetService(typeof(JsonSerializerSettings));

            //    // Modify the serializer settings based on some logic
            //    if (StaticPublicObjects.ado.IsSwaggerCallAdmin())
            //    {
            //        serializerSettings.ContractResolver = new CustomContractResolverNone(false, false);
            //    }
            //    else
            //    {
            //        serializerSettings.ContractResolver = new CustomContractResolverHideProperty(true);
            //    }
            //}

            // Call the next middleware in the pipeline
            await _next(context);
        }
    }
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
    public class HidePropertyAttribute : Attribute
    {
        /// <summary>
        /// if true than other parameters will be check and based on that field will be hide or show in serialization (object to string). if no other conditions were applied then hide.
        /// </summary>
        public bool IsHideSerialize { get; set; } = false;
        /// <summary>
        /// if true than other parameters will be check and based on that field will be hide or show in deserialization (string to object). if no other conditions were applied then hide.
        /// </summary>
        public bool IsHideDeSerialize { get; set; } = false;
        /// <summary>
        /// if true then field will be checked from public object isignorejsonserializeproperty and if true then will be *show* during serialization. priority for this field is 2.
        /// </summary>
        public bool IsCheckHideSerializeFromPublicObject { get; set; } = false;
        /// <summary>
        /// if true then field will be checked from public object isignorejsondeserializeproperty and if true then will be *show* during deserialization. priority for this field is 2.
        /// </summary>
        public bool IsCheckHideDeSerializeFromPublicObject { get; set; } = false;
        /// <summary>
        /// if true then it will be checked that public object ignorejsonserializepropertylist is null or not. if not null and exists then field will not be *show* during serialization. priority for this field is 3.
        /// </summary>
        public bool IsCheckHideSerializeFromPublicObjectList { get; set; } = false;
        /// <summary>
        /// if true then it will be checked that public object ignorejsondeserializepropertylist is null or not. if not null and exists then field will not be *show* during deserialization. priority for this field is 3.
        /// </summary>
        public bool IsCheckHideDeSerializeFromPublicObjectList { get; set; } = false;

        private string[]? _RemoteDomainIncludeHideSerialize = null;
        /// <summary>
        /// if not null then it will be checked that RemoteDomain exists or not. if exists then field will be *show* during serialization. priority for this field is 3.
        /// </summary>
        public string[]? RemoteDomainIncludeHideSerialize
        {
            get
            {
                return _RemoteDomainIncludeHideSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _RemoteDomainIncludeHideSerialize = Ret;
            }
        }
        private string[]? _RemoteDomainExcludeHideSerialize = null;
        /// <summary>
        /// if not null then it will be checked that RemoteDomain exists or not. if exists then field will be *hide* during serialization. priority for this field is 4.
        /// </summary>
        public string[]? RemoteDomainExcludeHideSerialize
        {
            get
            {
                return _RemoteDomainExcludeHideSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _RemoteDomainExcludeHideSerialize = Ret;
            }
        }
        private string[]? _RemoteDomainIncludeHideDeSerialize = null;
        /// <summary>
        /// if not null then it will be checked that RemoteDomain exists or not. if exists then field will be *show* during deserialization. priority for this field is 3.
        /// </summary>
        public string[]? RemoteDomainIncludeHideDeSerialize
        {
            get
            {
                return _RemoteDomainIncludeHideDeSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _RemoteDomainIncludeHideDeSerialize = Ret;
            }
        }
        private string[]? _RemoteDomainExcludeHideDeSerialize = null;
        /// <summary>
        /// if not null then it will be checked that RemoteDomain exists or not. if exists then field will be *hide* during deserialization. priority for this field is 4.
        /// </summary>
        public string[]? RemoteDomainExcludeHideDeSerialize
        {
            get
            {
                return _RemoteDomainExcludeHideDeSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _RemoteDomainExcludeHideDeSerialize = Ret;
            }
        }
        private string[]? _UserIncludeHideSerialize = null;
        /// <summary>
        /// if not null then it will be checked that claim username exists or not. if exists then field will be *show* during serialization. priority for this field is 5.
        /// </summary>
        public string[]? UserIncludeHideSerialize
        {
            get
            {
                return _UserIncludeHideSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _UserIncludeHideSerialize = Ret;
            }
        }
        private string[]? _UserExcludeHideSerialize = null;
        /// <summary>
        /// if not null then it will be checked that claim username exists or not. if exists then field will be *hide* during serialization. priority for this field is 6.
        /// </summary>
        public string[]? UserExcludeHideSerialize
        {
            get
            {
                return _UserExcludeHideSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _UserExcludeHideSerialize = Ret;
            }
        }
        private string[]? _UserIncludeHideDeSerialize = null;
        /// <summary>
        /// if not null then it will be checked that claim username exists or not. if exists then field will be *show* during deserialization. priority for this field is 5.
        /// </summary>
        public string[]? UserIncludeHideDeSerialize
        {
            get
            {
                return _UserIncludeHideDeSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _UserIncludeHideDeSerialize = Ret;
            }
        }
        private string[]? _UserExcludeHideDeSerialize = null;
        /// <summary>
        /// if not null then it will be checked that claim username exists or not. if exists then field will be *hide* during dedeserialization. priority for this field is 6.
        /// </summary>
        public string[]? UserExcludeHideDeSerialize
        {
            get
            {
                return _UserExcludeHideDeSerialize;
            }
            set
            {
                string[]? Ret = value;
                if (Ret != null)
                {
                    for (int i = 0; i <= Ret.Length - 1; i++)
                    {
                        Ret[i] = Ret[i].ToLower();
                    }
                }
                _UserExcludeHideDeSerialize = Ret;
            }
        }

    }
}
