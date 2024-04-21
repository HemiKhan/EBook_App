using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Newtonsoft.Json;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using EBook_Services.AccountServices;
using EBook_App.Extension;

namespace EBook_App.Controllers
{
    public class AccountController : Controller
    {
        #region Controller Constructor
        private IConfiguration _config;
        private IHttpContextAccessor _httpContextAccessor;
        private readonly IAccountService account;
        private PublicClaimObjects? _PublicClaimObjects
        {
            get
            {
                return StaticPublicObjects.ado.GetPublicClaimObjects();
            }
        }
        private readonly string _bodystring = "";
        public AccountController(IConfiguration config, IHttpContextAccessor httpContextAccessor, IAccountService account)
        {
            this._config = config;
            this._httpContextAccessor = httpContextAccessor;
            this.account = account;
            this._bodystring = StaticPublicObjects.ado.GetRequestBodyString().Result;
        }
        #endregion Controller Constructor

        #region Login
        public IActionResult Login()
        {
            if (Request.Path == "/")
                return Redirect("/Account/Login");

            PublicClaimObjects _PublicClaimObjectsNew = new PublicClaimObjects();
            _PublicClaimObjectsNew = HttpContext.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
            string encryptedusername = "";
            if (string.IsNullOrEmpty(_PublicClaimObjectsNew?.username) == false)
                encryptedusername = Crypto.EncryptQueryString(_PublicClaimObjectsNew?.username);

            ViewBag.RedirectURL = HttpContext.Request.Query["RedirectURL"].ToString();
            if (string.IsNullOrEmpty(_PublicClaimObjectsNew?.username) == false && ViewBag.RedirectURL != "")
                return Redirect(ViewBag.RedirectURL);

            string? url = Request.Cookies["URLCookie" + encryptedusername] ?? "/Account/Home";
            if (string.IsNullOrEmpty(_PublicClaimObjectsNew?.username) == false)
                return Redirect(url);

            SignInFromCookie(_PublicClaimObjectsNew, ViewBag.RedirectURL);
            if (string.IsNullOrEmpty(HttpContext.Session.GetStringValue("RedirectURL")) == false)
            {
                string ReturnURL = HttpContext.Session.GetStringValue("RedirectURL");
                HttpContext.Session.Remove("RedirectURL");
                return Redirect(ReturnURL);
            }
            HttpContext.Session.Clear();
            foreach (var cookie in Request.Cookies.Keys)
            {
                Response.Cookies.Delete(cookie);
            }
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> Login(string RedirectURL, SignIn_Req Login, CancellationToken cancellationToken)
        {
            try
            {
                SignIn_Res response = new SignIn_Res();
                response = await account.LoginAsync(Login, account.GenerateToken, cancellationToken);
                if (response.ResponseCode == true)
                {
                    if (Login.RememberMe)
                    {
                        var options = new CookieOptions
                        {
                            Expires = DateTimeOffset.UtcNow.AddDays(7),
                            HttpOnly = true
                        };
                        Response.Cookies.Append("user", Crypto.EncryptQueryString(response.UserName), options);
                        Response.Cookies.Append("jwtToken", Crypto.EncryptQueryString(response.JWToken), options);
                        Response.Cookies.Append("refreshToken", Crypto.EncryptQueryString(response.RefreshToken), options);
                        Response.Cookies.Append("cookietime", Crypto.EncryptQueryString(Newtonsoft.Json.JsonConvert.SerializeObject(options)), options);
                    }

                    string JWToken = response.JWToken;
                    ClaimsPrincipal User_ = account.GetPrincipalFromExpiredToken(JWToken, _config);
                    PublicClaimObjects _PublicClaimObjectsNew = new PublicClaimObjects();
                    _PublicClaimObjectsNew.username = (User_.FindFirst("username")?.Value == null ? "" : User_.FindFirst("username")?.Value.ToString())!;
                    _PublicClaimObjectsNew.jit = (User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value == null ? "" : User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value.ToString())!;
                    _PublicClaimObjectsNew.key = (User_.FindFirst("key")?.Value == null ? "" : User_.FindFirst("key")?.Value.ToString())!;
                    _PublicClaimObjectsNew.iswebtoken = (User_.FindFirst("isweb")?.Value == null ? false : Convert.ToBoolean(User_.FindFirst("isweb")?.Value.ToString()));
                    _PublicClaimObjectsNew.isdevelopment = StaticPublicObjects.ado.IsDevelopment();
                    _PublicClaimObjectsNew.appsettingfilename = (_PublicClaimObjectsNew.isdevelopment == true ? "appsettings.Development.json" : "appsettings.json");
                    _PublicClaimObjectsNew.isswaggercall = false;
                    _PublicClaimObjectsNew.isswaggercalladmin = false;
                    _PublicClaimObjectsNew.path = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRequestPath());
                    _PublicClaimObjectsNew.hostname = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetHostName());
                    _PublicClaimObjectsNew.hosturl = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetHostURL());
                    _PublicClaimObjectsNew.remotedomain = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRemoteDomain());
                    _PublicClaimObjectsNew.P_Get_User_Info = (StaticPublicObjects.ado == null ? null : StaticPublicObjects.ado.P_Get_User_Info(_PublicClaimObjectsNew.username, AppEnum.ApplicationId.AppID));
                                                           
                    HttpContext.Session.SetObject<PublicClaimObjects>("PublicClaimObjects", _PublicClaimObjectsNew);
                    string GUID_ = Guid.NewGuid().ToString().ToLower();
                    HttpContext.Session.SetStringValue("FileGUID", GUID_);

                    ViewBag.GUID = GUID_;

                    string ReturnURL = Request.Cookies["URLCookie" + Crypto.EncryptQueryString(_PublicClaimObjectsNew.username)] ?? "/Account/Home";
                    if (string.IsNullOrEmpty(RedirectURL) == false)
                        ReturnURL = RedirectURL;

                    return Redirect(ReturnURL);
                }
                else
                {
                    return Globals.GetAjaxJsonReturn(new { Result = false, ErrorMsg = response.ErrorMsg });
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Login", SmallMessage: ex.Message, Message: ex.ToString());
                throw new Exception("Internal Server Error");
            }

        }
        public async void SignInFromCookie(PublicClaimObjects _PublicClaimObjectsNew, string QueryReturnURL)
        {
            var username = Convert.ToString(_httpContextAccessor.HttpContext.Request.Cookies["user"]);
            var jwtToken = Convert.ToString(_httpContextAccessor.HttpContext.Request.Cookies["jwtToken"]);
            var refreshToken = Convert.ToString(_httpContextAccessor.HttpContext.Request.Cookies["refreshToken"]);
            if (!string.IsNullOrWhiteSpace(username) && !string.IsNullOrWhiteSpace(jwtToken) && !string.IsNullOrWhiteSpace(refreshToken))
            {
                try
                {
                    username = Crypto.DecryptQueryString(username);
                    jwtToken = Crypto.DecryptQueryString(jwtToken);
                    refreshToken = Crypto.DecryptQueryString(refreshToken);
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Login Page Decrypt", SmallMessage: ex.Message, Message: ex.ToString());
                    username = "";
                    jwtToken = "";
                    refreshToken = "";
                }
            }
            if (!string.IsNullOrWhiteSpace(username) && !string.IsNullOrWhiteSpace(jwtToken) && !string.IsNullOrWhiteSpace(refreshToken))
            {
                RefreshTokenReq Login = new RefreshTokenReq();
                Login.UserName = username;
                Login.token = jwtToken;
                Login.refreshToken = refreshToken;
                SignIn_Res response = await account.LoginFromCookiesAsync(Login, CancellationToken.None);
                if (response.ResponseCode == true)
                {
                    SetPublicClaimObjectAfterLogin(ref _PublicClaimObjectsNew, response.JWToken, QueryReturnURL, response.RefreshToken);
                }
            }
        }
        public void SetPublicClaimObjectAfterLogin(ref PublicClaimObjects _PublicClaimObjectsNew, string JWToken, string QueryReturnURL, string RefreshToken)
        {
            ClaimsPrincipal User_ = account.GetPrincipalFromExpiredToken(JWToken, _config);
            _PublicClaimObjectsNew = new PublicClaimObjects();
            _PublicClaimObjectsNew.username = (User_.FindFirst("username")?.Value == null ? "" : User_.FindFirst("username")?.Value.ToString())!;
            _PublicClaimObjectsNew.jit = (User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value == null ? "" : User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value.ToString())!;
            _PublicClaimObjectsNew.key = (User_.FindFirst("key")?.Value == null ? "" : User_.FindFirst("key")?.Value.ToString())!;
            _PublicClaimObjectsNew.iswebtoken = (User_.FindFirst("isweb")?.Value == null ? false : Convert.ToBoolean(User_.FindFirst("isweb")?.Value.ToString()));
            _PublicClaimObjectsNew.isdevelopment = StaticPublicObjects.ado.IsDevelopment();
            _PublicClaimObjectsNew.appsettingfilename = (_PublicClaimObjectsNew.isdevelopment == true ? "appsettings.Development.json" : "appsettings.json");
            _PublicClaimObjectsNew.isswaggercall = false;
            _PublicClaimObjectsNew.isswaggercalladmin = false;
            _PublicClaimObjectsNew.path = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRequestPath());
            _PublicClaimObjectsNew.hostname = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetHostName());
            _PublicClaimObjectsNew.hosturl = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetHostURL());
            _PublicClaimObjectsNew.remotedomain = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRemoteDomain());
            _PublicClaimObjectsNew.P_Get_User_Info = (StaticPublicObjects.ado == null ? null : StaticPublicObjects.ado.P_Get_User_Info(_PublicClaimObjectsNew.username, AppEnum.ApplicationId.AppID));

            var optionscookie = _httpContextAccessor.HttpContext.Request.Cookies["cookietime"];
            CookieOptions? tempoptions = null;
            if (string.IsNullOrEmpty(optionscookie) == false)
            {
                tempoptions = new CookieOptions();
                tempoptions = JsonConvert.DeserializeObject<CookieOptions>(Crypto.DecryptQueryString(optionscookie));

            }
            CookieOptions options = new CookieOptions();
            if (tempoptions != null)
            {
                options = new CookieOptions
                {
                    Expires = tempoptions.Expires,
                    HttpOnly = true
                };
            }
            else
            {
                options = new CookieOptions
                {
                    Expires = DateTimeOffset.UtcNow.AddDays(1),
                    HttpOnly = true
                };
            }

            _httpContextAccessor.HttpContext.Response.Cookies.Append("user", Crypto.EncryptQueryString(_PublicClaimObjectsNew.username), options);
            _httpContextAccessor.HttpContext.Response.Cookies.Append("jwtToken", Crypto.EncryptQueryString(JWToken), options);
            _httpContextAccessor.HttpContext.Response.Cookies.Append("refreshToken", Crypto.EncryptQueryString(RefreshToken), options);
            _httpContextAccessor.HttpContext.Response.Cookies.Append("cookietime", Crypto.EncryptQueryString(Newtonsoft.Json.JsonConvert.SerializeObject(options)), options);
            _httpContextAccessor.HttpContext.Session.SetObject<PublicClaimObjects>("PublicClaimObjects", _PublicClaimObjectsNew);
            string GUID_ = Guid.NewGuid().ToString().ToLower();
            _httpContextAccessor.HttpContext.Session.SetStringValue("FileGUID", GUID_);
            ViewBag.GUID = GUID_;
            string ReturnURL = _httpContextAccessor.HttpContext.Request.Cookies["URLCookie" + Crypto.EncryptQueryString(_PublicClaimObjectsNew.username)] ?? "/Account/Home";
            if (string.IsNullOrEmpty(QueryReturnURL) == false)
                ReturnURL = QueryReturnURL;

            _httpContextAccessor.HttpContext.Session.SetStringValue("RedirectURL", ReturnURL);
        }
        #endregion Login

        #region Home
        [CustomPageSetup]
        public IActionResult Home()
        {
            return View();
        }
        #endregion Home

        #region Logut
        public async Task<IActionResult> Logout()
        {
            string Username = _PublicClaimObjects.username;
            HttpContext.Session.Clear();
            foreach (var cookie in Request.Cookies.Keys)
            {
                Response.Cookies.Delete(cookie);
            }
            return Redirect("/Account/Login");
        }
        #endregion Logut        
    }
}
