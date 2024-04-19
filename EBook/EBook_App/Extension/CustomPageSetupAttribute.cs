using EBook_App.Helper;
using EBook_Data.DataAccess;
using EBook_Models.Data_Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.VisualBasic;
using System.Data;
using static EBook_App.Extension.MasterPage;

namespace EBook_App.Extension
{
    public class CustomPageSetupAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            MasterpageResponse aResponse = new MasterpageResponse();
            string CurrentURL = StaticPublicObjects.ado.GetRequestPath();
            MasterPage masterPage = new MasterPage();
            aResponse = masterPage.MasterPage_Code(aResponse);

            if (!aResponse.IsSessionEnabled)
            {
                filterContext.Result = new RedirectResult(aResponse.RedirectURL);
                return;
            }

            //StaticPublicObjects.ado.IsValidToken(StaticPublicObjects.ado.GetPublicClaimObjects(), AppEnum.WebTokenExpiredTime.Seconds);
            var controller = filterContext.Controller as Controller;

            if (controller != null)
            {
                controller.ViewBag.Sidebarstring = Side_Menu.GetSideBar();
                controller.ViewBag.PageGroupDT = filterContext.HttpContext.Session.GetObject<DataTable>("PageGroupDT");
                controller.ViewBag.PageDT = filterContext.HttpContext.Session.GetObject<DataTable>("PageDT");
                controller.ViewBag.CurrentPG = filterContext.HttpContext.Session.GetIntNotNull("CurrentPG");
                var _publicClaimObjects = filterContext.HttpContext.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
                controller.ViewBag.FullName = _publicClaimObjects.username;

                try
                {
                    controller.ViewBag.GUID = filterContext.HttpContext.Session.GetString("FileGUID") ?? Guid.NewGuid().ToString().ToLower();
                }
                catch (Exception ex)
                {
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "OnActionExecuting", SmallMessage: ex.Message, Message: ex.ToString());
                    controller.ViewBag.GUID = Guid.NewGuid().ToString().ToLower();
                }
            }

            base.OnActionExecuting(filterContext);
        }
    }
    public class MasterPage
    {
        public IHttpContextAccessor _HttpContextAccessor;
        public MasterPage()
        {
            _HttpContextAccessor = StaticPublicObjects.ado.GetIHttpContextAccessor();
        }
        public class MasterpageResponse
        {
            public bool IsSessionEnabled { get; set; }
            public string RedirectURL { get; set; }
            public string CurrentURL { get; set; }
        }
        public MasterpageResponse MasterPage_Code(MasterpageResponse aResponse)
        {
            MasterpageResponse Ret = new MasterpageResponse();
            Ret.IsSessionEnabled = true;
            var _publicClaimObjects = _HttpContextAccessor.HttpContext.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
            string? CurrentUserName = _publicClaimObjects?.username;
            if (string.IsNullOrEmpty(CurrentUserName))
            {
                //UserLogic_Security.SignInAjax();
                _publicClaimObjects = _HttpContextAccessor.HttpContext.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
                CurrentUserName = _publicClaimObjects?.username;
            }

            string CurrentURL = StaticPublicObjects.ado.GetRequestPath();
            if (string.IsNullOrEmpty(CurrentUserName))
            {
                Ret.IsSessionEnabled = false;
                Ret.CurrentURL = CurrentURL;
                Ret.RedirectURL = "~/Account/Login?RedirectURL=" + CurrentURL;
                return Ret;
            }
            string URL;
            URL = CurrentURL;
            _HttpContextAccessor.HttpContext.Response.Cookies.Append("URLCookie" + Crypto.EncryptQueryString(CurrentUserName), URL, new CookieOptions { HttpOnly = true, Expires = DateTime.UtcNow.AddDays(1) });

            return Ret;
        }

    }
    public class Side_Menu
    {
        public static string GetSideBar()
        {
            IHttpContextAccessor _HttpContextAccessor = StaticPublicObjects.ado.GetIHttpContextAccessor();
            DataTable DT = new DataTable();
            DataRow DR = null;
            DataSet DS = new DataSet();
            DataTable DTSUb;
            string Ret = "";
            string LitText = "";
            string CurrentURL = "";
            CurrentURL = StaticPublicObjects.ado.GetRequestPath();
            int Current_PG_ID = 0;
            int Current_P_ID = 0;

            string? Last_Page_Login = _HttpContextAccessor.HttpContext.Session.GetString("Last_Page_Login");
            if (Last_Page_Login != null)
            {
                if (CurrentURL.ToLower() == Last_Page_Login.ToLower())
                {
                    return Ret = LitText;
                }
                else
                {
                    (string Name, object Value)[] ParamsNameValues = { ("PageURL", (Strings.Left(CurrentURL, 1) == "/" ? "" : "/") + CurrentURL) };
                    DR = StaticPublicObjects.ado.ExecuteSelectDR("select CurrentPG_ID=p.PG_ID ,CurrentP_ID=p.P_ID from [dbo].[T_Page] p with (nolock) where p.PageURL= @PageURL", ParamsNameValues);
                }
            }

            if (DR == null)
            {
                List<Dynamic_SP_Params> List_dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "USERNAME";
                //dynamic_SP_Params.Val = UserLogic_Security.CurrentUserStatic.UserName;
                dynamic_SP_Params.Val = "HAMMAS.KHAN";
                List_dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "Application_MTV_ID";
                dynamic_SP_Params.Val = "148100";
                List_dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "CurrentURL";
                dynamic_SP_Params.Val = CurrentURL;
                List_dynamic_SP_Params.Add(dynamic_SP_Params);

                DS = StaticPublicObjects.ado.ExecuteStoreProcedureDS("P_Get_Pages_Info_By_User", ref List_dynamic_SP_Params);
                DT = DS.Tables[0];
                DTSUb = DS.Tables[1];

                if (DT.Rows.Count > 0 && Current_PG_ID == 0)
                {
                    Current_PG_ID = Convert.ToInt32(DT.Rows[0]["CurrentPG_ID"]);
                }

                if (DTSUb.Rows.Count > 0 && Current_P_ID == 0)
                {
                    Current_P_ID = Convert.ToInt32(DTSUb.Rows[0]["CurrentP_ID"]);
                }
            }
            else
            {
                DT = _HttpContextAccessor.HttpContext.Session.GetObject<DataTable>("PageGroupDT");
                DTSUb = _HttpContextAccessor.HttpContext.Session.GetObject<DataTable>("PageDT");
                Current_PG_ID = _HttpContextAccessor.HttpContext.Session.GetIntNotNull("CurrentPG_ID");
                Current_P_ID = _HttpContextAccessor.HttpContext.Session.GetIntNotNull("CurrentP_ID");

                for (int i = 0; i < DT.Rows.Count; i++)
                {
                    DT.Rows[i]["CurrentPG_ID"] = Current_PG_ID;
                    DT.Rows[i]["PageGroupSelected"] = "";
                    DT.Rows[i]["PageGroupActive"] = "";
                    DT.Rows[i]["PageGroupActiveIn"] = "";
                    if (Convert.ToInt32(DT.Rows[i]["PG_ID"]) == Current_PG_ID)
                    {
                        DT.Rows[i]["PageGroupSelected"] = "selected";
                        DT.Rows[i]["PageGroupActive"] = "active";
                        DT.Rows[i]["PageGroupActiveIn"] = "in";
                    }
                }
                for (int i = 0; i < DTSUb.Rows.Count; i++)
                {
                    DTSUb.Rows[i]["CurrentP_ID"] = Current_P_ID;
                    DTSUb.Rows[i]["PageActive"] = "";
                    if (Convert.ToInt32(DTSUb.Rows[i]["P_ID"]) == Current_P_ID)
                    {
                        DTSUb.Rows[i]["PageActive"] = "active";
                    }
                }
            }

            _HttpContextAccessor.HttpContext.Session.SetString("Last_Page_Login", CurrentURL.ToLower());
            _HttpContextAccessor.HttpContext.Session.SetObject<DataTable>("PageGroupDT", DT);
            _HttpContextAccessor.HttpContext.Session.SetObject<DataTable>("PageDT", DTSUb);
            _HttpContextAccessor.HttpContext.Session.SetInt("CurrentPG", Current_PG_ID);

            return Ret = LitText;
        }
    }
}
