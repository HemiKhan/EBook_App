using EBook_Data.Common;
using EBook_Data.DataAccess;
using Newtonsoft.Json.Linq;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace EBook_Data.Dtos
{
    public delegate string GenrateTokenDelgate(P_Get_User_Info oUser, string Encrypted_Key);

    #region Login
    public class SignIn_Req
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "*UserName* is required")]
        public string UserName { get; set; } = "";
        [Required(AllowEmptyStrings = false, ErrorMessage = "*Password* is required")]
        public string Password { get; set; } = "";
        [IgnoreDataMemberAttribute]
        public bool RememberMe { get; set; } = false;
    }
    public class SignIn_Res
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
        public virtual P_Get_User_Info? UserInfo { get; set; } = null;
    }

    public class RefreshTokenReq
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "*token* is Required")]
        public string token { get; set; } = "";
        [Required(AllowEmptyStrings = false, ErrorMessage = "*refreshtoken* is Required")]
        public string refreshToken { get; set; } = "";
        [Required(AllowEmptyStrings = false, ErrorMessage = "*userid* is Required")]
        public string UserName { get; set; } = "";
    }
    public class RefreshTokenRes
    {
        public bool ResponseCode { get; set; } = false;
        public string JWToken { get; set; } = "";
        public string? JWTokenExpiry { get; set; } = null;
        public string RefreshToken { get; set; } = "";
        public string ErrorMsg { get; set; } = "";
        public string ErrorCode { get; set; } = "";
        public P_Get_User_Info? UserInfo { get; set; } = null;
    }

    public class P_Get_User_Info
    {
        public int User_ID { get; set; }
        public string? UserName { get; set; } = "";
        public string? Email { get; set; } = "";
        public string? FullName { get; set; } = "";
        public string? FirstName { get; set; } = "";
        public string? LastName { get; set; } = "";
        public string? UserType { get; set; } = "";
        public string? Department { get; set; } = "";
        public string? Designation { get; set; } = "";
        public string? PasswordExpiryDateTime { get; set; } = "";
        public bool IsBlocked { get; set; } = false;
        public bool IsAdmin { get; set; } = false;
        public int RoleID { get; set; } = 0;
        public bool IsGroupRoleID { get; set; } = false;
        public bool IsApplicationAccessAllowed { get; set; } = false;
        [JsonIgnore]
        [IgnoreDataMember]
        [NotMapped]
        public string encrypted_key { get; set; } = "";
    }
    public class P_UserLoginPasswordModel
    {
        public string PasswordHash { get; set; }
        public string PasswordSalt { get; set; }
    }
    public class RefreshToken
    {
        public string JWToken { get; set; } = "";
        public DateTime? Expires { get; set; }
        public bool IsExpired => DateTime.UtcNow >= Expires;
        public DateTime? Created { get; set; }
        public DateTime? Revoked { get; set; }
        public bool IsActive => Revoked == null && !IsExpired;
    }
    public class User_Token_Expiry
    {
        public string? Username { get; set; } = null!;
        public string? Token { get; set; }
        public DateTime? TokenCreatedOn { get; set; }
        public DateTime? TokenExpiry { get; set; }
        public DateTime? TokenRevokedOn { get; set; }
        public string? Otp { get; set; }
        public DateTime? OtpExpiry { get; set; }
        public int? OtpStatus { get; set; }
    }
    public partial class TUser
    {
        public string? Username { get; set; } = null!;
        public string? Token { get; set; }
        public DateTime? TokenCreatedOn { get; set; }
        public DateTime? TokenExpiry { get; set; }
        public DateTime? TokenRevokedOn { get; set; }
        public string? Otp { get; set; }
        public DateTime? OtpExpiry { get; set; }
        public int? OtpStatus { get; set; }
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
}
