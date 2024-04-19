using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using EBook_Data.DataAccess;
using EBook_App.Helper;

namespace EBook_App.Extension
{
    public class CheckSessionExpirationAttribute : ActionFilterAttribute
    {
        
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (IsSessionExpired())
            {
                string CurrentURL = StaticPublicObjects.ado.GetRequestPath();
                // Redirect to a login page or perform any other action for session expiration
                filterContext.Result = new RedirectResult("~/Account/Login?RedirectURL=" + CurrentURL);
            }

            base.OnActionExecuting(filterContext);
        }

        private bool IsSessionExpired()
        {
            IHttpContextAccessor _HttpContextAccessor = StaticPublicObjects.ado.GetIHttpContextAccessor();
            var _publicClaimObjects = _HttpContextAccessor.HttpContext.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
            bool isExpired = true;
            string? CurrentUserAdmin = _publicClaimObjects?.username;

            if (string.IsNullOrEmpty(CurrentUserAdmin) == false)
            {
                isExpired = false;
            }
            else
            {
                //UserLogic_Security.SignInAjax();
                _publicClaimObjects = _HttpContextAccessor.HttpContext.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
                CurrentUserAdmin = _publicClaimObjects?.username;

                if (string.IsNullOrEmpty(CurrentUserAdmin) == false)
                {
                    isExpired = false;
                }
            }

            return isExpired;
        }
    }
}
