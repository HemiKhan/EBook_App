using AutoMapper;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace EBook_Services.AccountServices
{
    public class AccountService : IAccountService
    {
        private IConfiguration config;

        private readonly IHttpContextAccessor httpContextAccessor;
        public AccountService(IConfiguration config, IHttpContextAccessor httpContextAccessor)
        {
            this.config = config;
            this.httpContextAccessor = httpContextAccessor;
        }
        public async Task<SignIn_Res> LoginAsync(SignIn_Req req, GenrateTokenDelgate tokenGenrator, CancellationToken cancellationToken, bool IsPasswordRequired = true)
        {
            try
            {
                SignIn_Res res = new SignIn_Res();

                var credentials = await StaticPublicObjects.ado.GetUserLoginCredentials(req.UserName, cancellationToken);
                if (credentials == null)
                {
                    res.ErrorMsg = "Invalid UserName";
                    return res;
                }

                string PasswordHash = Crypto.EncodePassword(1, req.Password, credentials.PasswordSalt);

                if ((PasswordHash != null && PasswordHash.Equals(credentials.PasswordHash) && IsPasswordRequired) || IsPasswordRequired == false)
                {
                    P_Get_User_Info user_Info = new P_Get_User_Info();
                    user_Info = StaticPublicObjects.ado.P_Get_User_Info(req.UserName, AppEnum.ApplicationId.AppID);
                    if (user_Info == null)
                    {
                        res.ErrorMsg = "You Don't Have Rights In This Application1";
                        return res;
                    }
                    else if (user_Info.IsApplicationAccessAllowed == false && user_Info.IsAdmin == false)
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
                        string EncryptedKey = Globals.GetRequestBodyHash(Crypto.EncryptPasswordHashSalt(credentials.PasswordHash, credentials.PasswordSalt));

                        res.UserInfo = user_Info;
                        res.JWToken = tokenGenrator(user_Info, EncryptedKey);
                        
                        DateTime? jwtokenexpiry = Globals.GetTokenExpiryTime(res.JWToken);
                        if (jwtokenexpiry != null)
                            res.JWTokenExpiry = Convert.ToDateTime(jwtokenexpiry).ToString("yyyy-MM-dd HH:mm:ss.fff");

                        res.UserName = user_Info.UserName;

                        User_Token_Expiry user = new User_Token_Expiry();
                        user.Username = user_Info.UserName;

                        if (string.IsNullOrWhiteSpace(user.Token) || (user.TokenExpiry != null && DateTime.UtcNow > user.TokenExpiry))
                        {
                            var oNewToken = GenerateRefreshToken();
                            user.Token = oNewToken.JWToken;
                            user.TokenExpiry = oNewToken.Expires;
                            user.TokenCreatedOn = oNewToken.Created;
                        }

                        res.RefreshToken = user.Token;
                        res.ErrorMsg = "";
                        res.RememberMe = req.RememberMe;
                        res.ResponseCode = true;
                    }
                }
                else
                {
                    res.ErrorMsg = "Invalid User Password";
                    return res;
                }

                return res;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "LoginAsync", SmallMessage: ex.Message, Message: ex.ToString());
                throw new Exception("Internal Server Error");
            }
        }
        public string GenerateToken(P_Get_User_Info userInfo, string Encrypted_Key)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["Jwt:Key"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
            string issuer = config.GetValue<string>("Jwt:Issuer");
            string jitGUID = Guid.NewGuid().ToString();

            //Claims 
            var premClaims = new List<Claim>();
            premClaims.Add(new Claim(JwtRegisteredClaimNames.Jti, jitGUID));
            premClaims.Add(new Claim("username", userInfo.UserName.ToUpper()));
            premClaims.Add(new Claim("key", Encrypted_Key));
            //premClaims.Add(new Claim("isweb", StaticPublicObjects.ado.IsAllowedDomain().ToString().ToLower()));

            var token = new JwtSecurityToken(issuer, config["Jwt:Issuer"], premClaims,
              expires: DateTime.Now.AddDays(AppEnum.NewTokenExpiry.Days),
              signingCredentials: credentials);

            //if (StaticPublicObjects.ado.IsAllowedDomain())
            //    StaticPublicObjects.ado.AddTokenKeyCacheTime(true, jitGUID, Encrypted_Key, AppEnum.WebTokenExpiredTime.Seconds); //20 Minutes

            return new JwtSecurityTokenHandler().WriteToken(token);
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
    }
}
