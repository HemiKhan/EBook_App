using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Swashbuckle.AspNetCore.Annotations;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Runtime.Serialization;
using static EBook_Data.Dtos.AppEnum;

namespace EBook_Data.Common
{
    #region Login
    public class P_Get_User_Info : P_Get_User_Info_SP
    {
        public string ip_address { get; set; } = "";
        public Int64 local_timezoneoffset { get; set; } = 0;
        public int local_timezone { get; set; } = 0;
        public string local_timezonename { get; set; } = "";
        public bool issecureconnection { get; set; } = false;
        public string browser { get; set; } = "";
        public bool ismobiledevice { get; set; } = false;
        public string userremotedomain { get; set; } = "";
        public int applicable_tz_id { get; set; } = 0;
        public Int64 applicable_offset { get; set; } = 0;
        public string applicable_timezonename { get; set; } = "";
    }
    public class P_Get_User_Info_SP
    {
        private int _User_ID = 0;
        public int User_ID
        {
            get
            {
                return this._User_ID;
            }
            set
            {
                this._User_ID = (Globals.ConvertDBNulltoNullIfExistsInt(value) == null ? 0 : value);
            }
        }
        private string _UserName = "";
        public string UserName
        {
            get
            {
                return this._UserName;
            }
            set
            {
                this._UserName = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value.ToUpper());
            }
        }
        private string _FullName = "";
        public string FullName
        {
            get
            {
                return this._FullName;
            }
            set
            {
                this._FullName = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value);
            }
        }
        private string _Designation = "";
        public string Designation
        {
            get
            {
                return this._Designation;
            }
            set
            {
                this._Designation = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value);
            }
        }
        private int _DepartmentID = 0;
        public int DepartmentID
        {
            get
            {
                return this._DepartmentID;
            }
            set
            {
                this._DepartmentID = (Globals.ConvertDBNulltoNullIfExistsInt(value) == null ? 0 : value);
            }
        }
        private string _DepartmentName = "";
        public string DepartmentName
        {
            get
            {
                return this._DepartmentName;
            }
            set
            {
                this._DepartmentName = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value);
            }
        }
        private bool _IsAdmin = false;
        public bool IsAdmin
        {
            get
            {
                return this._IsAdmin;
            }
            set
            {
                this._IsAdmin = (Globals.ConvertDBNulltoNullIfExistsBool(value) == null ? false : value);
            }
        }
        private bool _IsBlocked = false;
        public bool IsBlocked
        {
            get
            {
                return this._IsBlocked;
            }
            set
            {
                this._IsBlocked = (Globals.ConvertDBNulltoNullIfExistsBool(value) == null ? false : value);
            }
        }
        private string _TempBlockTillDateTime = "";
        public string TempBlockTillDateTime
        {
            get
            {
                return this._TempBlockTillDateTime;
            }
            set
            {
                string? Ret = Globals.ConvertDBNulltoNullIfExistsDateTime(value, true);
                this._TempBlockTillDateTime = (Ret == null ? "" : Ret);
            }
        }
        private string _PasswordExpiryDateTime = "";
        public string PasswordExpiryDateTime
        {
            get
            {
                return this._PasswordExpiryDateTime;
            }
            set
            {
                string? Ret = Globals.ConvertDBNulltoNullIfExistsDateTime(value, true);
                this._PasswordExpiryDateTime = (Ret == null ? "" : Ret);
            }
        }
        private string _TimeRegion = "";
        public string TimeRegion
        {
            get
            {
                return this._TimeRegion;
            }
            set
            {
                this._TimeRegion = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value);
            }
        }
        private string _TimeRegionShortName = "";
        public string TimeRegionShortName
        {
            get
            {
                return this._TimeRegionShortName;
            }
            set
            {
                this._TimeRegionShortName = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value);
            }
        }
        private int _TimeZoneID = 13;
        public int TimeZoneID
        {
            get
            {
                return this._TimeZoneID;
            }
            set
            {
                this._TimeZoneID = (Globals.ConvertDBNulltoNullIfExistsInt(value) == null ? 0 : value);
            }
        }
        private int _TimeOffset = -18000000;
        public int TimeOffset
        {
            get
            {
                return this._TimeOffset;
            }
            set
            {
                this._TimeOffset = (Globals.ConvertDBNulltoNullIfExistsInt(value) == null ? -18000000 : value);
            }
        }
        private string _NavUserName = "";
        public string NavUserName
        {
            get
            {
                return this._NavUserName;
            }
            set
            {
                this._NavUserName = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value.ToUpper());
            }
        }
        private string _NavApproverUserName = "";
        public string NavApproverUserName
        {
            get
            {
                return this._NavApproverUserName;
            }
            set
            {
                this._NavApproverUserName = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value.ToUpper());
            }
        }
        private string _UserTypeMTVCode = "";
        public string UserTypeMTVCode
        {
            get
            {
                return this._UserTypeMTVCode;
            }
            set
            {
                this._UserTypeMTVCode = (Globals.ConvertDBNulltoNullIfExistsString(value) == null ? "" : value.ToUpper());
            }
        }
        private int _RoleID = 0;
        public int RoleID
        {
            get
            {
                return this._RoleID;
            }
            set
            {
                this._RoleID = (Globals.ConvertDBNulltoNullIfExistsInt(value) == null ? 0 : value);
            }
        }
        private bool _IsGroupRoleID = false;
        public bool IsGroupRoleID
        {
            get
            {
                return this._IsGroupRoleID;
            }
            set
            {
                this._IsGroupRoleID = (Globals.ConvertDBNulltoNullIfExistsBool(value) == null ? false : value);
            }
        }
        private bool _IsApplicationAccessAllowed = false;
        public bool IsApplicationAccessAllowed
        {
            get
            {
                return this._IsApplicationAccessAllowed;
            }
            set
            {
                this._IsApplicationAccessAllowed = (Globals.ConvertDBNulltoNullIfExistsBool(value) == null ? false : value);
            }
        }
        private bool _IsAPIAccessAllowed = false;
        public bool IsAPIAccessAllowed
        {
            get
            {
                return this._IsAPIAccessAllowed;
            }
            set
            {
                this._IsAPIAccessAllowed = (Globals.ConvertDBNulltoNullIfExistsBool(value) == null ? false : value);
            }
        }
        [JsonIgnore]
        [IgnoreDataMember]
        [NotMapped]
        public string encrypted_key { get; set; } = "";
    }
    public class UserInfoDTO : P_Get_User_Info_SP
    {
    }
    public class AccountSignInDTO
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "*UserID* is required")]
        public string UserID { get; set; } = "";
        [Required(AllowEmptyStrings = false, ErrorMessage = "*Password* is required")]
        public string Password { get; set; } = "";
        [IgnoreDataMemberAttribute]
        public bool RememberMe { get; set; } = false;
    }
    public class AccountSignInResDTO
    {
        public bool ResponseCode { get; set; } = false;
        public string UserName { get; set; } = "";
        public string JWToken { get; set; } = "";
        public string? JWTokenExpiry { get; set; } = null;

        public string RefreshToken { get; set; } = "";
        public string ErrorMsg { get; set; } = "";
        public string ErrorCode { get; set; } = "";
        [IgnoreDataMemberAttribute]
        public bool RememberMe { get; set; } = false;
        [IgnoreDataMemberAttribute]
        public virtual UserInfoDTO? UserInfo { get; set; } = null;
    }
    #endregion Login

    #region User Setup
    public class P_Users_Result
    {
        public int RowNo { get; set; } = 0;
        public int USER_ID { get; set; } = 0;
        public string Encrypted_USER_ID
        {
            get
            {
                return Crypto.EncryptNumericToStringWithOutNull(USER_ID);
            }
        }
        public string UserType_MTV_CODE { get; set; } = "";
        public int D_ID { get; set; } = 0;
        public int SecurityQuestion_MTV_ID { get; set; } = 0;
        public int BlockType_MTV_ID { get; set; } = 0;
        public string USERNAME { get; set; } = "";
        public string UserType { get; set; } = "";
        public string Department { get; set; } = "";
        public string Designation { get; set; } = "";
        public string FirstName { get; set; } = "";
        public string MiddleName { get; set; } = "";
        public string LastName { get; set; } = "";
        public string Company { get; set; } = "";
        public string Address { get; set; } = "";
        public string Address2 { get; set; } = "";
        public string City { get; set; } = "";
        public string State { get; set; } = "";
        public string Country { get; set; } = "";
        public string Email { get; set; } = "";
        public string Mobile { get; set; } = "";
        public string Phone { get; set; } = "";
        public string PhoneExt { get; set; } = "";
        public string SecurityQuestion { get; set; } = "";
        public string EncryptedAnswer { get; set; } = "";
        public int TIMEZONE_ID { get; set; } = 0;
        public string TIMEZONE_Name { get; set; } = "";
        public bool IsApproved { get; set; } = false;
        public string BlockType { get; set; } = "";
        public string PasswordExpiry { get; set; } = "";
        public bool IsAPIUser { get; set; } = false;
        public bool IsActive { get; set; } = false;
    }
    public class P_AddOrEdit_User_Response
    {
        public int USER_ID { get; set; } = 0;

        private string _USERNAME = "";
        public string USERNAME
        {
            get
            {
                return this._USERNAME;
            }
            set
            {
                this._USERNAME = (value == null ? "" : value.ToUpper());
            }
        }

        public string UserType_MTV_CODE { get; set; } = default!;
        public string Password { get; set; } = default!;
        public string ConfirmPassword { get; set; } = default!;
        public int D_ID { get; set; }
        public string Designation { get; set; } = default!;

        private string _FirstName = "";
        public string FirstName
        {
            get
            {
                return this._FirstName;
            }
            set
            {
                this._FirstName = (value == null ? "" : value);
            }
        }

        private string _MiddleName = "";
        public string MiddleName
        {
            get
            {
                return this._MiddleName;
            }
            set
            {
                this._MiddleName = (value == null ? "" : value);
            }
        }

        private string _LastName = "";
        public string LastName
        {
            get
            {
                return this._LastName;
            }
            set
            {
                this._LastName = (value == null ? "" : value);
            }
        }

        public string Company { get; set; } = default!;
        public string Address { get; set; } = default!;
        public string Address2 { get; set; } = default!;
        public string City { get; set; } = default!;
        public string State { get; set; } = default!;
        public string ZipCode { get; set; } = default!;
        public string Country { get; set; } = default!;

        private string _Email = "";
        public string Email
        {
            get
            {
                return this._Email;
            }
            set
            {
                this._Email = (value == null ? "" : value.ToLower());
            }
        }

        public string Mobile { get; set; } = default!;
        public string Phone { get; set; } = default!;
        public string PhoneExt { get; set; } = default!;
        public int SecurityQuestion_MTV_ID { get; set; }
        public string EncryptedAnswer { get; set; } = default!;
        public int TIMEZONE_ID { get; set; }
        public bool IsApproved { get; set; } = false;
        public int BlockType_MTV_ID { get; set; }
        public bool IsAPIUser { get; set; } = false;
        public bool IsActive { get; set; } = true;
    }
    public class P_Get_User_By_ID
    {
        public int USER_ID { get; set; } = 0;

        private string _USERNAME = "";
        public string USERNAME
        {
            get
            {
                return this._USERNAME;
            }
            set
            {
                this._USERNAME = (value == null ? "" : value.ToUpper());
            }
        }

        public string UserType_MTV_CODE { get; set; } = default!;
        public string UserType { get; set; } = default!;
        public string Password { get; set; } = default!;
        public string ConfirmPassword { get; set; } = default!;
        public int D_ID { get; set; }
        public string DepartmentName { get; set; }
        public string Designation { get; set; } = default!;

        private string _FirstName = "";
        public string FirstName
        {
            get
            {
                return this._FirstName;
            }
            set
            {
                this._FirstName = (value == null ? "" : value);
            }
        }

        private string _MiddleName = "";
        public string MiddleName
        {
            get
            {
                return this._MiddleName;
            }
            set
            {
                this._MiddleName = (value == null ? "" : value);
            }
        }

        private string _LastName = "";
        public string LastName
        {
            get
            {
                return this._LastName;
            }
            set
            {
                this._LastName = (value == null ? "" : value);
            }
        }

        public string Company { get; set; } = default!;
        public string Address { get; set; } = default!;
        public string Address2 { get; set; } = default!;
        public string City { get; set; } = default!;
        public string State { get; set; } = default!;
        public string ZipCode { get; set; } = default!;
        public string Country { get; set; } = default!;

        private string _Email = "";
        public string Email
        {
            get
            {
                return this._Email;
            }
            set
            {
                this._Email = (value == null ? "" : value.ToLower());
            }
        }

        public string Mobile { get; set; } = default!;
        public string Phone { get; set; } = default!;
        public string PhoneExt { get; set; } = default!;
        public int SecurityQuestion_MTV_ID { get; set; }
        public string Question { get; set; } = default!;
        public string EncryptedAnswer { get; set; } = default!;
        public int TIMEZONE_ID { get; set; }
        public string TIMEZONE { get; set; } = default!;
        public bool IsApproved { get; set; } = false;
        public int BlockType_MTV_ID { get; set; }
        public string BlockType { get; set; } = default!;
        public bool IsAPIUser { get; set; } = false;
        public bool IsActive { get; set; } = true;
    }
    public class P_Get_SearchUsersName
    {
        public int USER_ID { get; set; }
        public string USERNAME { get; set; }
    }
    public class UserValidator
    {
        public static P_ReturnMessage_Result ValidateUser(JObject obj)
        {
            try
            {
                P_ReturnMessage_Result messageResult = new P_ReturnMessage_Result();
                string? password = (string?)obj["UserDetails"]["PasswordHash"];
                string? confirmPassword = (string?)obj["UserDetails"]["PasswordHash"];
                string? email = (string)obj["UserDetails"]["Email"];
                string? username = (string?)obj["UserDetails"]["USERNAME"];
                string? userTypeMTVCode = (string?)obj["UserDetails"]["UserType_MTV_CODE"];
                int? dID = obj["UserDetails"]?["D_ID"] != null ? (int?)obj["UserDetails"]["D_ID"] : null;
                string? passwordSalt = (string?)obj["UserDetails"]["PasswordSalt"];
                string? designation = (string?)obj["UserDetails"]["Designation"];
                int? securityQuestionMTVID = (int?)obj["UserDetails"]["SecurityQuestion_MTV_ID"];
                string? encryptedAnswer = (string?)obj["UserDetails"]["EncryptedAnswer"];
                int? timezoneID = obj["UserDetails"]?["TIMEZONE_ID"] != null ? (int?)obj["UserDetails"]["TIMEZONE_ID"] : null;
                int? blockTypeMTVID = obj["UserDetails"]?["BlockType_MTV_ID"] != null ? (int?)obj["UserDetails"]["BlockType_MTV_ID"] : null;
                //string? navUsername = (string?)obj["UserDetails"]["ApplicationAccess"][0]["NAV_USERNAME"];
                //int? applicationMTVID = (int?)obj["UserDetails"]["ApplicationAccess"][0]["Application_MTV_ID"];

                JToken applicationAccessArray = obj["UserDetails"]["ApplicationAccess"];
                if (applicationAccessArray != null && applicationAccessArray.HasValues)
                {
                    foreach (JToken navUserName in applicationAccessArray)
                    {
                        int? applicationMTVID = (int?)navUserName["Application_MTV_ID"];
                        string? navUsername = (string?)navUserName["NAV_USERNAME"];

                        if (applicationMTVID == 148103 && string.IsNullOrEmpty(navUsername))
                        {
                            messageResult.ReturnText = "For NAV, the User Name is required";
                            messageResult.ReturnCode = false;
                            return messageResult;
                        }
                    }
                }

                JToken userSeller = obj["UserSeller"];
                if (userSeller != null && userSeller.HasValues)
                {
                    foreach (JToken userSellerObject in userSeller)
                    {
                        JToken usertoSeller = userSellerObject["UserToSeller"];
                        if (usertoSeller != null && usertoSeller.HasValues)
                        {
                            string? sellerKey = (string?)usertoSeller["SELLER_KEY"];

                            if (string.IsNullOrEmpty(sellerKey))
                            {
                                messageResult.ReturnText = "Seller  is Required"; ;
                                messageResult.ReturnCode = false;
                                return messageResult;
                            }
                        }

                        JToken billTo = userSellerObject["BillTo"];
                        if (billTo != null && billTo.HasValues)
                        {
                            foreach (JToken billToObject in billTo)
                            {
                                int? SBM_ID = (int?)billToObject["SBM_ID"];

                                if (SBM_ID <= 0 || SBM_ID == null)
                                {
                                    messageResult.ReturnText = "Please select BillTo or Remove Extra Row";
                                    messageResult.ReturnCode = false;
                                    return messageResult;
                                }
                            }
                        }

                        JToken partnerTo = userSellerObject["PartnerTo"];
                        if (partnerTo != null && partnerTo.HasValues)
                        {
                            foreach (JToken partnerToObject in partnerTo)
                            {
                                int? SPM_ID = (int?)partnerToObject["SPM_ID"];

                                if (SPM_ID <= 0 || SPM_ID == null)
                                {
                                    messageResult.ReturnText = "Please select PartnerTo or Remove Extra Row";
                                    messageResult.ReturnCode = false;
                                    return messageResult;
                                }
                            }
                        }

                        JToken subSeller = userSellerObject["SubSellerTo"];
                        if (subSeller != null && subSeller.HasValues)
                        {
                            foreach (JToken subSellerToObject in subSeller)
                            {
                                int? SSM_ID = (int?)subSellerToObject["SSM_ID"];

                                if (SSM_ID <= 0 || SSM_ID == null)
                                {
                                    messageResult.ReturnText = "Please select SubSeller or Remove Extra Row";
                                    messageResult.ReturnCode = false;
                                    return messageResult;
                                }
                            }
                        }

                        JToken tariffTo = userSellerObject["Tariff"];
                        if (tariffTo != null && tariffTo.HasValues)
                        {
                            foreach (JToken tariffToObject in tariffTo)
                            {
                                int? STM_ID = (int?)tariffToObject["STM_ID"];

                                if (STM_ID <= 0 && STM_ID == null)
                                {
                                    messageResult.ReturnText = "Please select Tariff or Remove Extra Row";
                                    messageResult.ReturnCode = false;
                                    return messageResult;
                                }
                            }
                        }
                    }
                }

                if (CustomFunctions.IsPasswordValid(password, 8) == false)
                {
                    messageResult.ReturnText = "Please Enter Password with At least 1 Capital Letter, 1 Small Letter, 1 Special Character, 1 Number. Minimum Length 8 Characters.";
                    messageResult.ReturnCode = false;
                    return messageResult;
                }
                else if (password != confirmPassword)
                {
                    messageResult.ReturnText = "Password and Confirm Password do not match.";
                    messageResult.ReturnCode = false;
                    return messageResult;
                }
                if (
                          string.IsNullOrEmpty(username) ||
                          string.IsNullOrEmpty(userTypeMTVCode) ||
                          string.IsNullOrEmpty(passwordSalt) ||
                          string.IsNullOrEmpty(designation) ||
                          string.IsNullOrEmpty(encryptedAnswer) ||
                          string.IsNullOrEmpty(encryptedAnswer) ||
                          string.IsNullOrEmpty(email) ||
                         dID == null || dID == 0 ||
                         securityQuestionMTVID == null || securityQuestionMTVID == 0 ||
                         timezoneID == null || timezoneID == 0 ||
                         blockTypeMTVID == null || blockTypeMTVID == 0)
                {
                    messageResult.ReturnText = "Please fill all required fields.";
                    messageResult.ReturnCode = false;
                    return messageResult;
                }
                if (CustomFunctions.IsValidEmail(email.ToLower()) == false)
                {
                    messageResult.ReturnText = "Please enter valid email.";
                    messageResult.ReturnCode = false;
                    return messageResult;
                }

                if (!password.Equals(confirmPassword))
                {
                    messageResult.ReturnText = "Password not match ";
                    messageResult.ReturnCode = false;
                    return messageResult;
                }

                messageResult.ReturnText = "Validation Passed";
                messageResult.ReturnCode = true;
                return messageResult;
            }
            catch (Exception ex)
            {
                P_ReturnMessage_Result exceptionMessage = new P_ReturnMessage_Result();
                exceptionMessage.ReturnCode = false;
                exceptionMessage.ReturnText = "Internal Error";
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "ValidateUser ", SmallMessage: ex.Message, Message: ex.ToString());
                return exceptionMessage;
            }
        }
    }
    #endregion User Setup

    #region App Setup
    
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
    public class P_ReturnMessage_Result
    {
        public bool ReturnCode { get; set; } = false;
        public string? ReturnText { get; set; } = "";
    }
    public class P_ReturnMessageForJson_Result
    {
        public bool ReturnCode { get; set; } = false;
        public string? ReturnText { get; set; } = "";
        public string? Execution_Error { get; set; } = "";
        public string? Error_Text { get; set; } = "";

    }
    public class SelectDropDownList
    {
        public object code { get; set; }
        public string name { get; set; }
    }
    public class SelectDropDownListWithEncryption
    {
        public int ID { get; set; }
        public string code
        {
            get
            {
                return Crypto.EncryptNumericToStringWithOutNull(this.ID);
            }
        }
        public string name { get; set; }
    }
    public class SelectDropDownListWithEncryptionString
    {
        private string _code = "";
        [SwaggerSchema(ReadOnly = true)]
        public string code
        {
            get
            {
                return this._code;
            }
            set
            {
                this._code = Globals.ConvertDBNulltoNullIfExistsString(value) ?? "";
            }
        }
        public string encryptedcode
        {
            get
            {
                return Crypto.EncryptString(code);
            }
        }
        public string name { get; set; }
    }
    public class Sorting_Result
    {
        public int New_Sort_Value { get; set; }
        public object Sort_ID { get; set; }
        public string Sort_Text { get; set; }
        public int Old_Sort_Value { get; set; }
    }
    public class LoginSaveCookie
    {
        public string UserName { get; set; } = "";
        public string Password { get; set; } = "";
        public bool RememberMe { get; set; } = false;
        public int LocalTimeZone { get; set; } = 0;
        public string LocalTimeZoneName { get; set; } = "";
    }
    public class GetModalDetail
    {
        /// <summary>
        /// Set Value from GetModalSize Struct
        /// </summary>
        public string getmodelsize { get; set; } = AppEnum.GetModalSize.modal_md;
        public string modalheaderclass { get; set; } = "Theme-Header";
        public string modaltitle { get; set; } = "";
        public string onclickmodalclose { get; set; } = "resetmodal('dynamic-modal1')";
        public string modalbodytabletbody { get; set; } = "";
        public string modalfooterclass { get; set; } = "";
        public string modalfootercancelbuttonname { get; set; } = "Cancel";
        public string modalfootersuccessbuttonname { get; set; } = "Change";
        public string modalfootersuccessbuttonclass { get; set; } = "Theme-button";
        public string onclickmodalsuccess { get; set; } = "";
        public List<ModalBodyTypeInfo> modalBodyTypeInfos { get; set; } = null;
    }
    public class ModalBodyTypeInfo
    {
        /// <summary>
        /// Set Value from GetModelBodyType Struct
        /// </summary>
        public string ModelBodyType { get; set; } = null;
        public string LabelColumnClass { get; set; } = "col-4";
        public string FieldColumnClass { get; set; } = "col-8";
        public string LabelName { get; set; } = "";
        public string LabelClass { get; set; } = "fw-light mb-2";
        public bool IsRequired { get; set; } = false;
        public bool IsHidden { get; set; } = false;
        /// <summary>
        /// Set Value from GetInputStringType Struct. Required if ModelBodyType is TRInput
        /// </summary>
        public string GetInputTypeString { get; set; } = null;
        public string PlaceHolder { get; set; } = "";
        public string id { get; set; } = "";
        public string ClassName { get; set; } = "";
        /// <summary>
        /// Required if ModelBodyType is TRInput
        /// </summary>
        public bool issmallformcontrol { get; set; } = true;
        public object value { get; set; } = null;
        public bool isdisabled { get; set; } = false;
        /// <summary>
        /// Set Value from JavascriptValidationType Struct
        /// </summary>
        public string datavalidationtypes { get; set; } = "";
        public List<AttributeList> AttributeList = new List<AttributeList>();
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool issmallformselect { get; set; } = true;
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool isselect { get; set; } = true;
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool ismultiselect { get; set; } = false;
        /// <summary>
        /// Optional when ismultiselect is true
        /// </summary>
        public List<object> listofobj { get; set; } = new List<object>();
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public List<SelectDropDownList> selectLists { get; set; } = null;
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool IsSelectOption { get; set; } = true;
        /// <summary>
        /// Required if ModelBodyType is TRTextArea
        /// </summary>
        public int rows { get; set; } = 5;
        /// <summary>
        /// Required if ModelBodyType is TRCheckBox
        /// </summary>
        public bool isratio { get; set; } = false;
        /// <summary>
        /// Required if ModelBodyType is TRCheckBox
        /// </summary>
        public bool ischecked { get; set; } = false;
        /// <summary>
        /// required for mobile and phone and phoneExt
        /// </summary>
        public int noOfInput { get; set; } = 0;
        public bool isMultiInput { get; set; } = false;
        public int inputSize { get; set; } = int.MaxValue;
        public int inputMaxlength { get; set; } = int.MaxValue;
        public string inputTypeForNumber { get; set; } = "";
        public string GetClassName
        {
            get
            {
                string Ret = "";
                if (this.ClassName != "")
                    Ret = this.ClassName;
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRInput)
                    Ret = "w-100 border-1";
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRselect)
                    Ret = "w-100 border-1 custom-select";
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRTextArea)
                    Ret = "w-100 border-1";
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRCheckBox)
                    Ret = "fw-light mb-2 me-2";
                return Ret;
            }
        }

    }
    public class AttributeList
    {
        public string Name { get; set; } = "";
        public object Value { get; set; } = null;
    }

    [AttributeUsage(AttributeTargets.Property)]
    public class ExcludeFromDynamicSPParamsAttribute : Attribute
    {

    }
    public class CaptchaResponse
    {
        public bool success = false;
        public string challenge_ts = "";
        public string hostname = "";
        public double score = 0.00;
        public string action = "";
        public List<string> error_codes = new List<string>();
    }
    public class ListofErrors
    {
        public string errorcode { get; set; } = "";
        public string errormessage { get; set; } = "";
        public string detailmessage { get; set; } = "";
    }
    public class RequestDocs
    {
        [SwaggerSchema(Nullable = false, ReadOnly = true)]
        [JsonIgnore]
        [IgnoreDataMemberAttribute]
        [HideProperty(IsHideSerialize = true)]
        public string path { get; set; } = "";
        [SwaggerSchema(Nullable = false)]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *filename* is Required")]
        [CustomValidationAttribute2(maxlength: 100, minlength: 1, maxlenerrormessage: "*{BaseTypeName}filename* invalid value"
            , minlenerrormessage: "*{BaseTypeName}filename* invalid value"
            , ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}filename* is Required", isshowbasetype: true)]
        public string filename { get; set; } = "";
        private string _fileext = "";
        [SwaggerSchema(Description = "Required", Nullable = false)]
        //[Required(AllowEmptyStrings = false, ErrorMessage = "*{BaseTypeName}fileext* is required")]
        [CustomValidationAttribute2(maxlength: 10, minlength: 1, maxlenerrormessage: "*{BaseTypeName}fileext* invalid value"
            , minlenerrormessage: "*{BaseTypeName}fileext* invalid value"
            , allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}fileext* is Required", isshowbasetype: true)]
        public string fileext
        {
            get
            {
                return this._fileext;
            }
            set
            {
                this._fileext = (value == null ? "" : value.Replace(".", "").ToLower());
            }
        }
        [SwaggerSchema(Description = "Required. On Item Level Only Image Document Type is Acceptable.", Nullable = false, Required = new string[] { "111100 = Document", "111101 = Pickup BOL", "111102 = Client BOL", "111103 = Image", "111106 = Other" })]
        [Range(111100, 111999, ErrorMessage = "Ignore Error: *documenttype* invalid value")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *documenttype* is required")]
        [CustomValidationAttribute2(rangestart: 111100, rangeend: 111999, rangeerrormessage: "*{BaseTypeName}documenttype* invalid value"
            , rangeapplicable: true, isshowbasetype: true
            , ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}documenttype* is Required")]
        public int documenttype { get; set; } = 0;
        private string _description = "";
        [SwaggerSchema(Description = "Optional", Nullable = true)]
        public string description
        {
            get
            {
                return this._description;
            }
            set
            {
                this._description = (value == null ? "" : value);
            }
        }
        [SwaggerSchema(Description = "Default is 128100 = Order Level Attachment", Nullable = false, Required = new string[] { "128100 = Order Level Attachment", "128101 = Item Level Attachment", "128102 = Item Scan Level Attachment" })]
        [Range(128100, 128102, ErrorMessage = "Ignore Error: *attachmenttype* invalid value")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *attachmenttype* is required")]
        [CustomValidationAttribute2(rangestart: 128100, rangeend: 128102, rangeerrormessage: "*{BaseTypeName}attachmenttype* invalid value"
            , rangeapplicable: true, isshowbasetype: true
            , ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}attachmenttype* is Required")]
        public int attachmenttype { get; set; } = 128100;
        [SwaggerSchema(Description = "Optional. Default value is true", Nullable = false)]
        public bool ispublic { get; set; } = true;
        private string _filebase64 = "";
        [SwaggerSchema(Description = "Required. File Base64 is required", Nullable = false)]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *filebase64* is required")]
        [CustomValidationAttribute2(ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}filebase64* invalid value", isshowbasetype: true)]
        public string filebase64
        {
            get
            {
                return this._filebase64;
            }
            set
            {
                this._filebase64 = Globals.ExtractBase64String(value) ?? "";
            }
        }
        private string _filepath = "";
        [SwaggerSchema(Nullable = true, ReadOnly = true)]
        public string filepath
        {
            get
            {
                return this._filepath;
            }
            set
            {
                this._filepath = (value == null ? "" : value);
            }
        }
        [SwaggerSchema(Nullable = false, ReadOnly = true)]
        [JsonIgnore]
        [IgnoreDataMemberAttribute]
        [HideProperty(IsHideSerialize = true)]
        public int filesize { get; set; } = 0;
    }
    #endregion App Setup

    #region echarts
    public class ECharts_Result
    {
        public string charttitle { get; set; } = "";
        public string chartid { get; set; } = "";
        public List<ECharts_ResultData> ResultData { get; set; } = new List<ECharts_ResultData>();
    }
    public class ECharts_ResultData
    {
        public bool is_xaxis { get; set; } = true;
        public List<ECharts_ResultList> data { get; set; } = new List<ECharts_ResultList>();
    }
    public class ECharts_ResultList
    {
        public string value { get; set; } = "";
        public string name { get; set; } = "";
        public ECharts_ExtraValues extra { get; set; } = new ECharts_ExtraValues();
    }
    public class ECharts_ExtraValues
    {
        public string hiddenValue { get; set; } = "";
    }
    #endregion echarts

    #region ReportReqResJson
    public class ReportGridColumns
    {
        public int position { get; set; } = 0;
        public string field { get; set; } = "";
        public bool showinexcel { get; set; } = true;
        public string title { get; set; } = "";
        public string excelcolumntype { get; set; } = "";
    }
    public class RequestDataForDetailsTemplate
    {
        public int Id { get; set; } = 0;
        public ReportParams ReportParams { get; set; }
    }
    public class ReportParams
    {
        public int PageIndex { get; set; } = 0;
        public int PageSize { get; set; } = 0;
        private string _SortExpression = "";
        public string SortExpression
        {
            get
            {
                return this._SortExpression;
            }
            set
            {
                this._SortExpression = (value == null ? "" : value);
            }
        }
        private string _FilterClause = "";
        public string FilterClause
        {
            get
            {
                return this._FilterClause;
            }
            set
            {
                this._FilterClause = (value == null ? "" : value);
            }
        }
        public List<ReportFilterObject> ReportFilterObjectList { get; set; } = new List<ReportFilterObject>();
        public List<ReportColumnObject> ReportColumnObjectList { get; set; } = new List<ReportColumnObject>();

    }
    public class kendo_option_data_filter
    {
        public string logic { get; set; } = "and";
        public List<kendo_option_data_filter2> filters { get; set; } = new List<kendo_option_data_filter2>();
    }
    public class kendo_option_data_filter2
    {
        public string logic { get; set; } = "and";
        public List<kendo_option_data_filter_filters> filters { get; set; } = new List<kendo_option_data_filter_filters>();
    }
    public class kendo_option_data_filter_filters
    {
        public string field { get; set; } = "";
        public string operator_ { get; set; } = "";
        public string value { get; set; } = "";
    }
    public class ReportFilterDropDownList
    {
        public string text { get; set; }
        public object value { get; set; }
    }
    public class ReportFilterObject
    {
        private string _Code = "";
        public string Code
        {
            get
            {
                return this._Code;
            }
            set
            {
                this._Code = (value == null ? "" : value);
            }
        }
        private string _Name = "";
        public string Name
        {
            get
            {
                return this._Name;
            }
            set
            {
                this._Name = (value == null ? "" : value);
            }
        }
        public bool IsFilterApplied { get; set; } = false;
        private string _FieldType = "";
        public string FieldType
        {
            get
            {
                return this._FieldType;
            }
            set
            {
                this._FieldType = (value == null ? "" : value.ToLower());
            }
        }
        private string _SRFieldType = "";
        public string SRFieldType
        {
            get
            {
                return this._SRFieldType;
            }
            set
            {
                this._SRFieldType = (value == null ? "" : value.ToLower());
            }
        }
        public List<ReportFilterObjectArry> reportFilterObjectArry { get; set; } = new List<ReportFilterObjectArry>();
        public List<SQLReportFilterObjectArry> sQLReportFilterObjectArry { get; set; } = new List<SQLReportFilterObjectArry>();
    }
    public class ReportFilterObjectArry
    {
        private string _Logic = "";
        public string Logic
        {
            get
            {
                return this._Logic;
            }
            set
            {
                string Ret = "";
                if (value != null)
                {
                    Ret = (value.ToUpper() == "OR" || value.ToUpper() == "AND" ? value.ToUpper() : "");
                }
                this._Logic = Ret;
            }
        }
        private object _Value = "";
        public object Value
        {
            get
            {
                return this._Value;
            }
            set
            {
                this._Value = (value == null ? "" : value);
            }
        }
        private string _Type = "";
        public string Type
        {
            get
            {
                return this._Type;
            }
            set
            {
                this._Type = (value == null ? "" : value.ToLower());
            }
        }
        private string _FieldType = "";
        public string FieldType
        {
            get
            {
                return this._FieldType;
            }
            set
            {
                this._FieldType = (value == null ? "" : value.ToLower());
            }
        }
        private string _SRFieldType = "";
        public string SRFieldType
        {
            get
            {
                return this._SRFieldType;
            }
            set
            {
                this._SRFieldType = (value == null ? "" : value.ToLower());
            }
        }
        public bool IsList { get; set; } = false;
        public int ListType { get; set; } = 0;
        public string Code { get; set; } = "";

    }
    public class SQLReportFilterObjectArry
    {
        private object _Value = "";
        public object Value
        {
            get
            {
                return this._Value;
            }
            set
            {
                this._Value = (value == null ? "" : value);
            }
        }
        private string _Type = "";
        public string Type
        {
            get
            {
                return this._Type;
            }
            set
            {
                this._Type = (value == null ? "" : value.ToLower());
            }
        }

    }
    public class ShowHideReportColumnObject
    {
        public string kendoid { get; set; } = "";
        public string kendofunctionname { get; set; } = "";
        public bool iscollapse { get; set; } = false;
        public List<ReportColumnObject> reportColumnObjectList { get; set; } = new List<ReportColumnObject>();
        public bool IsColumnsIsExists
        {
            get
            {
                bool Ret = false;
                if (reportColumnObjectList?.Find(component => component.IsHidden == false) != null)
                    Ret = true;
                return Ret;
            }
        }
        public bool SetValue
        {
            get
            {
                bool Ret = false;
                if (reportColumnObjectList?.Find(component => component.IsHidden == false && component.IsChecked == true) == null
                    && reportColumnObjectList?.Find(component => component.IsHidden == false && component.IsChecked == false) != null)
                    Ret = true;

                return Ret;
            }
        }
        public string SetValueName
        {
            get
            {
                string Ret = "Uncheck All";
                if (SetValue)
                    Ret = "Check All";

                return Ret;
            }
        }
    }
    public class ReportColumnObject
    {
        private string _Code = "";
        public string Code
        {
            get
            {
                return this._Code;
            }
            set
            {
                this._Code = (value == null ? "" : value);
            }
        }
        private string _Name = "";
        public string Name
        {
            get
            {
                return this._Name;
            }
            set
            {
                this._Name = (value == null ? "" : value);
            }
        }
        public bool IsColumnRequired { get; set; } = true;
        public bool IsHidden { get; set; } = false;
        public bool IsChecked { get; set; } = false;
        public int SortPosition { get; set; } = 0;
        public string uiid { get; set; } = Guid.NewGuid().ToString().ToLower();

    }
    public class ReportResponsePageSetup : ReportResponse
    {
    }
    public class ReportResponseSellerAllocation : ReportResponse
    {
        public bool sellerallocationtlistview { get; set; } = false;
        public bool sellerallocationtlisttabview { get; set; } = false;
        public bool sellerallocationtlisttabedit { get; set; } = false;
        public bool sellerallocationtlisttabadd { get; set; } = false;
        public bool sellerallocationtlisttabdelete { get; set; } = false;
        public bool sellerallocationtmappingtabview { get; set; } = false;
        public bool sellerallocationtmappingtabedit { get; set; } = false;
        public bool sellerallocationtmappingtabadd { get; set; } = false;
        public bool sellerallocationtmappingtabdelete { get; set; } = false;
        public bool usersellerallocationtmappingtabview { get; set; } = false;
        public bool usersellerallocationtmappingtabedit { get; set; } = false;
        public bool usersellerallocationtmappingtabadd { get; set; } = false;
        public bool usersellerallocationtmappingtabdelete { get; set; } = false;
    }

    public class ReportResponse
    {
        public bool response_code { get; set; } = false;
        public string errormsg { get; set; } = "";
        public string errorcode { get; set; } = "";
        public string warningtext { get; set; } = "";
        public Int64 _TotalRowCount = 0;
        public Int64 TotalRowCount
        {
            get
            {
                return this._TotalRowCount;
            }
            set
            {
                this._TotalRowCount = (value == null ? 0 : value);
            }
        }
        public object? ResultData { get; set; } = null;

    }
    #endregion ReportReqResJson

    #region Export To Excel
    public class DownloadLastFile
    {
        public bool isfileavailable { get; set; }
        public string filename { get; set; }
        public string fileext { get; set; }
        public string filedatetime { get; set; }
    }
    public class SetColumnType
    {
        public int columnindex { get; set; } = 0;
        public string columnname { get; set; } = "";
        public string columntype { get; set; } = ExcelColumnType.General;
    }
    #endregion Export To Excel

    public delegate string GenrateTokenDelgate(UserInfoDTO oUser, string Encrypted_Key);
    public class RefreshToken
    {
        public string JWToken { get; set; } = "";
        public DateTime? Expires { get; set; }
        public bool IsExpired => DateTime.UtcNow >= Expires;
        public DateTime? Created { get; set; }
        public DateTime? Revoked { get; set; }
        public bool IsActive => Revoked == null && !IsExpired;
    }
    public class P_UserLoginQueryModel
    {
        public string PasswordHash { get; set; }
        public string PasswordSalt { get; set; }
    }
}
