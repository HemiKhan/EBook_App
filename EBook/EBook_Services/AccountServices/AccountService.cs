using AutoMapper;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.Data;
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
        public async Task<SignIn_Res> LoginAsync(SignIn_Req req, GenrateTokenDelgate tokenGenrator, CancellationToken cancellationToken)
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

                string EncryptedKey = Globals.GetRequestBodyHash(Crypto.EncryptPasswordHashSalt(credentials.PasswordHash, credentials.PasswordSalt));

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
                    string PasswordHash = Crypto.EncodePassword(1, req.Password, credentials.PasswordSalt);
                    if (PasswordHash != null && PasswordHash.Equals(credentials.PasswordHash))
                    {
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
                    else
                    {
                        res.ErrorMsg = "Invalid User Password";
                        return res;
                    }
                }
                return res;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "LoginAsync", SmallMessage: ex.Message, Message: ex.ToString());
                throw new Exception("Internal Server Error");
            }
        }
        public async Task<SignIn_Res> LoginFromCookiesAsync(RefreshTokenReq req, CancellationToken cancellationToken)
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

                string EncryptedKey = Globals.GetRequestBodyHash(Crypto.EncryptPasswordHashSalt(credentials.PasswordHash, credentials.PasswordSalt));

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
                    res.UserInfo = user_Info;
                    res.JWToken = GenerateToken(user_Info, EncryptedKey);
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
                    res.RememberMe = true;
                    res.ResponseCode = true;
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

            var token = new JwtSecurityToken(issuer, config["Jwt:Issuer"], premClaims,
              expires: DateTime.Now.AddDays(AppEnum.NewTokenExpiry.Days),
              signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        public ClaimsPrincipal GetPrincipalFromExpiredToken(string token, IConfiguration _config)
        {
            try
            {
                var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
                var tokenValidationParameters = new TokenValidationParameters
                {
                    ValidateAudience = false, //you might want to validate the audience and issuer depending on your use case
                    ValidateIssuer = false,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = securityKey,
                    ValidateLifetime = false //here we are saying that we don't care about the token's expiration date
                };

                var tokenHandler = new JwtSecurityTokenHandler();
                SecurityToken securityToken;
                var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out securityToken);
                //var user = StaticPublicObjects.ado.P_Get_User_Info(principal.FindFirst("username")?.Value, AppEnum.ApplicationId.AppID);
                //if (principal.FindFirst("key")?.Value != user.encrypted_key)
                //    throw new SecurityTokenException("Invalid Token");

                var jwtSecurityToken = securityToken as JwtSecurityToken;
                if (jwtSecurityToken == null || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
                    throw new SecurityTokenException("Invalid token");
                return principal;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetPrincipalFromExpiredToken", SmallMessage: ex.Message, Message: ex.ToString());
            }
            return null;
        }
                
        public RefreshTokenRes RefreshToken(RefreshTokenReq _GetRefreshTokenRes, CancellationToken cancellationToken)
        {
            try
            {
                RefreshTokenRes res = new RefreshTokenRes();
                var principal = GetPrincipalFromExpiredToken(_GetRefreshTokenRes.token, config);
                if (principal == null)
                {
                    res.ErrorMsg = "Invalid Token";
                    res.ErrorCode = ErrorList.ErrorListInvalidToken.ErrorCode;
                    return res;
                }
                var username = principal.Claims.FirstOrDefault(o => o.Type == "username").Value;
                var refreshToken = GenerateRefreshToken();
                var newJwtToken = GenerateTokenByClaims(principal.Claims.ToList());
                string NewrefreshToken = refreshToken.JWToken;

                res.JWToken = newJwtToken;
                res.RefreshToken = NewrefreshToken;
                DateTime? jwtokenexpiry = Globals.GetTokenExpiryTime(res.JWToken);
                if (jwtokenexpiry != null)
                    res.JWTokenExpiry = Convert.ToDateTime(jwtokenexpiry).ToString("yyyy-MM-dd HH:mm:ss.fff");

                res.ResponseCode = true;
                return res;
            }
            catch (Exception)
            {
                throw;
            }
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
        private string GenerateTokenByClaims(List<Claim> premClaims)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["Jwt:Key"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
            string issuer = config.GetValue<string>("Jwt:Issuer");

            var token = new JwtSecurityToken(issuer, config["Jwt:Issuer"], premClaims,
              expires: DateTime.Now.AddDays(AppEnum.NewTokenExpiry.Days),
              signingCredentials: credentials);

            string jitGUID = premClaims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti)?.Value;
            string Encrypted_Key = premClaims.FirstOrDefault(c => c.Type == "key")?.Value;

            return new JwtSecurityTokenHandler().WriteToken(token);
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
