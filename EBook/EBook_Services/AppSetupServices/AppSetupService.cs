using AutoMapper.Configuration;
using EBook_Data.Common;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using EBook_Data.Interfaces;
using EBook_Models.App_Models;
using Microsoft.AspNetCore.Http;
using System.Security.Cryptography;

namespace EBook_Services.AppSetupServices
{
    public class AppSetupService : IAppSetupService
    {
        #region Constructor
        private IConfiguration _config;
        private IHttpContextAccessor _httpContextAccessor;
        private readonly string _bodystring = "";
        public AppSetupService(IConfiguration config, IHttpContextAccessor httpContextAccessor, IADORepository ado)
        {
            this._config = config;
            this._httpContextAccessor = httpContextAccessor;
            this._bodystring = StaticPublicObjects.ado.GetRequestBodyString().Result;
        }
        #endregion Constructor

        #region Login Service
        public async Task<AccountSignInResDTO> SignIn(AccountSignInDTO signInDTO, GenrateTokenDelgate tokenGenrator, CancellationToken cancellationToken, bool IsPasswordRequired = true)
        {
            AccountSignInResDTO res = new AccountSignInResDTO();
            try
            {
                var data = await StaticPublicObjects.ado.GetUserLoginCredentials(signInDTO.UserID, cancellationToken);
                if (data == null)
                {
                    res.ErrorMsg = "Invalid UserName";
                    return res;
                }

                string PasswordHash = Crypto.EncodePassword(1, signInDTO.Password, data.PasswordSalt);

                if ((PasswordHash != null && PasswordHash.Equals(data.PasswordHash) && IsPasswordRequired) || IsPasswordRequired == false)
                {
                    P_Get_User_Info_SP user_Info = new P_Get_User_Info_SP();
                    user_Info = StaticPublicObjects.ado.P_Get_User_Info_Class(signInDTO.UserID, AppEnum.ApplicationId.AppID);
                    //user_Info = await POMS_DB_UnitOfWork.StoredProcedures_Repo.GetUserInfo(signInDTO.UserID, cancellationToken);
                    if (user_Info == null)
                    {
                        res.ErrorMsg = "You Don't Have Rights In This Application1";
                        return res;
                    }
                    else if (user_Info.IsApplicationAccessAllowed == false && user_Info.IsAPIAccessAllowed == false && user_Info.IsAdmin == false)
                    {
                        res.ErrorMsg = "You Don't Have Rights In This Application2";
                        return res;
                    }
                    else if (user_Info.IsBlocked == true)
                    {
                        res.ErrorMsg = "User is Blocked";
                        return res;
                    }
                    else
                    {
                        string EncryptedKey = Globals.GetRequestBodyHash(Crypto.EncryptPasswordHashSalt(data.PasswordHash, data.PasswordSalt));
                        var userInfoDTO = new UserInfoDTO();//mapper.Map<UserInfoDTO>(user_Info);
                        res.UserInfo = new UserInfoDTO();
                        res.UserInfo = userInfoDTO;
                        res.JWToken = tokenGenrator(userInfoDTO, EncryptedKey);
                        DateTime? jwtokenexpiry = Globals.GetTokenExpiryTime(res.JWToken);
                        if (jwtokenexpiry != null)
                            res.JWTokenExpiry = Convert.ToDateTime(jwtokenexpiry).ToString("yyyy-MM-dd HH:mm:ss.fff");
                        res.UserName = userInfoDTO.UserName;

                        var user = new TUser();// await POMSDB_Context_13.DBContext_Instance.Set<TUser>().FindAsync(signInDTO.UserID);
                        if (user == null)
                        {
                            user = new TUser();
                            user.Username = signInDTO.UserID.ToUpper();
                            //await POMSDB_Context_13.DBContext_Instance.Set<TUser>().AddAsync(user);
                            //await POMSDB_Context_13.DBContext_Instance.SaveAsync();
                            //user = await POMSDB_Context_13.DBContext_Instance.Set<TPOMSUser>().FindAsync(signInDTO.UserID);
                        }

                        if (string.IsNullOrWhiteSpace(user.Token) || (user.TokenExpiry != null && DateTime.UtcNow > user.TokenExpiry))
                        {
                            var oNewToken = GenerateRefreshToken();
                            user.Token = oNewToken.JWToken;
                            user.TokenExpiry = oNewToken.Expires;
                            user.TokenCreatedOn = oNewToken.Created;
                        }
                        //await POMSDB_Context_13.DBContext_Instance.SaveAsync();
                        res.RefreshToken = user.Token;
                        res.ErrorMsg = "";
                        res.RememberMe = signInDTO.RememberMe;
                        res.ResponseCode = true;
                    }
                }
                else
                {
                    res.ErrorMsg = "Invalid User Password";
                    return res;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "SignIn", SmallMessage: ex.Message, Message: ex.ToString());
                throw new Exception("Internal Server Error");
            }
            return res;
        }
        private RefreshToken GenerateRefreshToken()
        {
            return new RefreshToken
            {
                JWToken = RandomTokenString(),
                Expires = DateTime.UtcNow.AddYears(1),
                Created = DateTime.UtcNow
            };
        }
        private string RandomTokenString()
        {
            using var rngCryptoServiceProvider = new RNGCryptoServiceProvider();
            var randomBytes = new byte[40];
            rngCryptoServiceProvider.GetBytes(randomBytes);
            return BitConverter.ToString(randomBytes).Replace("-", "");
        }
        public async Task<RefreshToken> GetRefreshToken(string userID)
        {
            var oUser = new TUser(); //await POMSDB_Context_13.DBContext_Instance.Set<TUser>().FindAsync(userID);
            if (oUser == null)
            {
                return null;
            }
            return new RefreshToken
            {
                JWToken = oUser.Token,
                Created = oUser.TokenCreatedOn,
                Expires = oUser.TokenExpiry,
                Revoked = oUser.TokenRevokedOn,
            };
        }
        public async Task<RefreshToken> SaveNewRefreshToken(string userID)
        {
            var oUser = new TUser();// await POMSDB_Context_13.DBContext_Instance.Set<TUser>().FindAsync(userID);
            var oNewToken = GenerateRefreshToken();
            oUser.Token = oNewToken.JWToken;
            oUser.TokenExpiry = oNewToken.Expires;
            oUser.TokenCreatedOn = oNewToken.Created;
            //await POMSDB_Context_13.DBContext_Instance.SaveAsync();
            return oNewToken;
        }
        #endregion Login Service
    }
}
