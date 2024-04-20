using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Newtonsoft.Json;
using EBook_Data.DataAccess;
using EBook_Data.Common;
using EBook_Data.Interfaces;
using EBook_Data.Dtos;

namespace EBook_App.Controllers
{
    public class AccountController : Controller
    {
        #region Controller Constructor
        private IConfiguration _config;
        private IHttpContextAccessor _httpContextAccessor;
        private readonly IADORepository ado;
        private PublicClaimObjects? _PublicClaimObjects
        {
            get
            {
                return ado.GetPublicClaimObjects();
            }
        }
        private readonly string _bodystring = "";
        public AccountController(IConfiguration config, IHttpContextAccessor httpContextAccessor, IADORepository ado)
        {
            this._config = config;
            this._httpContextAccessor = httpContextAccessor;
            this.ado = ado;
            this._bodystring = ado.GetRequestBodyString().Result;
        }
        #endregion Controller Constructor

        #region Login
        public async Task<IActionResult> Login()
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
        public async void SignInFromCookie(PublicClaimObjects _PublicClaimObjectsNew, string QueryReturnURL) {
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
            //    AccountSignInResDTO response = new AccountSignInResDTO();
            //    EBook.APIService.Controllers.AccountController accountController = new EBook.APIService.Controllers.AccountController(_signIn_Query, _config, _httpContextAccessor);
            //    RefreshTokenRequestDTO Login = new RefreshTokenRequestDTO();
            //    Login.userID = username;
            //    Login.token = jwtToken;
            //    Login.refreshToken = refreshToken;

            //    var newresponse = await accountController.RefreshToken(Login, CancellationToken.None);
            //    if (newresponse != null)
            //    {
            //        var contentResult = newresponse as Microsoft.AspNetCore.Mvc.ContentResult;
            //        if (contentResult != null)
            //            response = JsonConvert.DeserializeObject<AccountSignInResDTO>(contentResult.Content!)!;
            //    }

            //    if (response.ResponseCode == true)
            //    {
            //        SetPublicClaimObjectAfterLogin(ref _PublicClaimObjectsNew, response.JWToken, QueryReturnURL, response.RefreshToken);
            //        await _hubContext.Clients.All.SendAsync("SessionExpired" + _PublicClaimObjects.username + _httpContextAccessor.HttpContext.Connection.Id, false);
            //        await _hubContext.Clients.All.SendAsync("ReLogin" + _PublicClaimObjects.username + _httpContextAccessor.HttpContext.Connection.Id, false);
            //    }
            }
        }
        public void SetPublicClaimObjectAfterLogin(ref PublicClaimObjects _PublicClaimObjectsNew, string JWToken, string QueryReturnURL, string RefreshToken)
        {
            {
                //ClaimsPrincipal User_ = EBook.APIService.Controllers.AccountController.GetPrincipalFromExpiredToken(JWToken, _config);
                ClaimsPrincipal User_ = new ClaimsPrincipal();
                _PublicClaimObjectsNew = new PublicClaimObjects();
                _PublicClaimObjectsNew.username = (User_.FindFirst("username")?.Value == null ? "" : User_.FindFirst("username")?.Value.ToString())!;
                _PublicClaimObjectsNew.jit = (User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value == null ? "" : User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value.ToString())!;
                _PublicClaimObjectsNew.key = (User_.FindFirst("key")?.Value == null ? "" : User_.FindFirst("key")?.Value.ToString())!;
                _PublicClaimObjectsNew.iswebtoken = (User_.FindFirst("isweb")?.Value == null ? false : Convert.ToBoolean(User_.FindFirst("isweb")?.Value.ToString()));

                _PublicClaimObjectsNew.isdevelopment = ado.IsDevelopment();
                //_PublicClaimObjectsNew.isallowedremotedomain = ado.IsAllowedDomain();
                _PublicClaimObjectsNew.appsettingfilename = (_PublicClaimObjectsNew.isdevelopment == true ? "appsettings.Development.json" : "appsettings.json");
                _PublicClaimObjectsNew.isswaggercall = false;
                _PublicClaimObjectsNew.isswaggercalladmin = false;
                _PublicClaimObjectsNew.path = (ado == null ? "" : ado.GetRequestPath());
                _PublicClaimObjectsNew.hostname = (ado == null ? "" : ado.GetHostName());
                _PublicClaimObjectsNew.hosturl = (ado == null ? "" : ado.GetHostURL());
                _PublicClaimObjectsNew.remotedomain = (ado == null ? "" : ado.GetRemoteDomain());
                //_PublicClaimObjectsNew.remoteurl = (ado == null ? "" : ado.GetRemoteURL());
                _PublicClaimObjectsNew.P_Get_User_Info_Class = (ado == null ? null : ado.P_Get_User_Info_Class(_PublicClaimObjectsNew.username, AppEnum.ApplicationId.AppID));

                //if (ado.IsValidToken(_PublicClaimObjectsNew, AppEnumC.WebTokenExpiredTime.Seconds))
                {

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
                    //Response.Cookies.Append("UserName", Login.UserID, options);
                    //Response.Cookies.Append("Password", Login.Password, options);
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
                    //return Redirect(ReturnURL);
                }
            }
        }
        [HttpPost]
        public async Task<IActionResult> Login(string RedirectURL, AccountSignInDTO Login, CancellationToken cancellationToken)
        {
            try
            {
                AccountSignInResDTO response = new AccountSignInResDTO();
                //EBook.APIService.Controllers.AccountController accountController = new EBook.APIService.Controllers.AccountController(_signIn_Query, _config, _httpContextAccessor);

                //var newresponse = await accountController.SignInAsync(Login, cancellationToken);
                //if (newresponse != null)
                //{
                //    var contentResult = newresponse as Microsoft.AspNetCore.Mvc.ContentResult;
                //    if (contentResult != null)
                //        response = JsonConvert.DeserializeObject<AccountSignInResDTO>(contentResult.Content!)!;
                //}

                if (response.ResponseCode == true)
                {
                    if (Login.RememberMe)
                    {
                        var options = new CookieOptions
                        {
                            Expires = DateTimeOffset.UtcNow.AddDays(7),
                            HttpOnly = true
                        };
                        //Response.Cookies.Append("UserName", Login.UserID, options);
                        //Response.Cookies.Append("Password", Login.Password, options);
                        Response.Cookies.Append("user", Crypto.EncryptQueryString(response.UserName), options);
                        Response.Cookies.Append("jwtToken", Crypto.EncryptQueryString(response.JWToken), options);
                        Response.Cookies.Append("refreshToken", Crypto.EncryptQueryString(response.RefreshToken), options);
                        Response.Cookies.Append("cookietime", Crypto.EncryptQueryString(Newtonsoft.Json.JsonConvert.SerializeObject(options)), options);
                    }

                    string jwtToken = response.JWToken;
                    //ClaimsPrincipal User_ = EBook.APIService.Controllers.AccountController.GetPrincipalFromExpiredToken(response.JWToken, _config);
                    ClaimsPrincipal User_ = new ClaimsPrincipal(); 

                    PublicClaimObjects _PublicClaimObjectsNew = new PublicClaimObjects();
                    _PublicClaimObjectsNew.username = (User_.FindFirst("username")?.Value == null ? "" : User_.FindFirst("username")?.Value.ToString())!;
                    _PublicClaimObjectsNew.jit = (User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value == null ? "" : User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value.ToString())!;
                    _PublicClaimObjectsNew.key = (User_.FindFirst("key")?.Value == null ? "" : User_.FindFirst("key")?.Value.ToString())!;
                    _PublicClaimObjectsNew.iswebtoken = (User_.FindFirst("isweb")?.Value == null ? false : Convert.ToBoolean(User_.FindFirst("isweb")?.Value.ToString()));

                    _PublicClaimObjectsNew.isdevelopment = ado.IsDevelopment();
                    //_PublicClaimObjectsNew.isallowedremotedomain = ado.IsAllowedDomain();
                    _PublicClaimObjectsNew.appsettingfilename = (_PublicClaimObjectsNew.isdevelopment == true ? "appsettings.Development.json" : "appsettings.json");
                    _PublicClaimObjectsNew.isswaggercall = false;
                    _PublicClaimObjectsNew.isswaggercalladmin = false;
                    _PublicClaimObjectsNew.path = (ado == null ? "" : ado.GetRequestPath());
                    _PublicClaimObjectsNew.hostname = (ado == null ? "" : ado.GetHostName());
                    _PublicClaimObjectsNew.hosturl = (ado == null ? "" : ado.GetHostURL());
                    _PublicClaimObjectsNew.remotedomain = (ado == null ? "" : ado.GetRemoteDomain());
                    //_PublicClaimObjectsNew.remoteurl = (ado == null ? "" : ado.GetRemoteURL());
                    _PublicClaimObjectsNew.P_Get_User_Info_Class = (ado == null ? null : ado.P_Get_User_Info_Class(_PublicClaimObjectsNew.username, AppEnum.ApplicationId.AppID));

                    HttpContext.Session.SetObject<PublicClaimObjects>("PublicClaimObjects", _PublicClaimObjectsNew);
                    string GUID_ = Guid.NewGuid().ToString().ToLower();
                    HttpContext.Session.SetStringValue("FileGUID", GUID_);

                    ViewBag.GUID = GUID_;

                    string ReturnURL = Request.Cookies["URLCookie" + Crypto.EncryptQueryString(_PublicClaimObjectsNew.username)] ?? "/Account/Home";
                    if (string.IsNullOrEmpty(RedirectURL) == false)
                        ReturnURL = RedirectURL;

                    //await _hubContext.Clients.All.SendAsync("SessionExpired" + _PublicClaimObjectsNew.username + _httpContextAccessor.HttpContext.Connection.Id, false);
                    //await _hubContext.Clients.All.SendAsync("ReLogin" + _PublicClaimObjectsNew.username + _httpContextAccessor.HttpContext.Connection.Id, false);
                    return Redirect(ReturnURL);
                }
                else
                {
                    return Globals.GetAjaxJsonReturn(new { Result = false, ErrorMsg = response.ErrorMsg});
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Login", SmallMessage: ex.Message, Message: ex.ToString());
                throw new Exception("Internal Server Error");
            }

        }
        #endregion Login

        #region Home
        //[CustomPageSetupAttribute]
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
            //await _hubContext.Clients.All.SendAsync("SessionExpired" + Username + _httpContextAccessor.HttpContext.Connection.Id, true);
            return Redirect("/Account/Login");
            //return RedirectToAction("Login");
        }
        #endregion Logut        
    }
}
