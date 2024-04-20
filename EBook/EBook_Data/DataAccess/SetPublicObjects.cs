using AutoMapper;
using EBook_Data.Dtos;
using EBook_Data.Interfaces;
using Microsoft.Extensions.Caching.Memory;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace EBook_Data.DataAccess
{
    public class SetPublicObjects
    {
        public static void SetStaticPublicObjects(ILogFile logFile, IADORepository ado, IMapper map, IMemoryCache memorycache)
        {
            if (StaticPublicObjects.logFile == null)
                StaticPublicObjects.logFile = (logFile != null ? logFile : StaticPublicObjects.logFile);

            if (StaticPublicObjects.ado == null)
                StaticPublicObjects.ado = (ado != null ? ado : StaticPublicObjects.ado);

            if (StaticPublicObjects.map == null)
                StaticPublicObjects.map = (map != null ? map : StaticPublicObjects.map);

            if (StaticPublicObjects.ado != null && StaticPublicObjects.virtualdirectory == null)
                StaticPublicObjects.virtualdirectory = StaticPublicObjects.ado.GetVirtualDirectory();

            if (StaticPublicObjects.ado != null)
                StaticPublicObjects.iscachingenable = StaticPublicObjects.ado.GetIsCachingEnabled();

            if (StaticPublicObjects.memorycache == null)
                StaticPublicObjects.memorycache = (memorycache != null ? memorycache : StaticPublicObjects.memorycache);
        }
        public static PublicClaimObjects SetPublicClaimObjects()
        {
            ClaimsPrincipal? User_ = StaticPublicObjects.ado.GetUserClaim();
            PublicClaimObjects _PublicClaimObjects = new PublicClaimObjects();
            if (User_ != null)
            {
                _PublicClaimObjects.username = (User_.FindFirst("username")?.Value == null ? "" : User_.FindFirst("username")?.Value.ToString());
                _PublicClaimObjects.jit = (User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value == null ? "" : User_.FindFirst(JwtRegisteredClaimNames.Jti)?.Value.ToString());
                _PublicClaimObjects.key = (User_.FindFirst("key")?.Value == null ? "" : User_.FindFirst("key")?.Value.ToString());
                _PublicClaimObjects.iswebtoken = (User_.FindFirst("isweb")?.Value == null ? false : Convert.ToBoolean(User_.FindFirst("isweb")?.Value.ToString()));
            }
            else
            {
                _PublicClaimObjects.username = "";
                _PublicClaimObjects.jit = "";
                _PublicClaimObjects.key = "";
                _PublicClaimObjects.iswebtoken = false;
            }

            _PublicClaimObjects.isdevelopment = StaticPublicObjects.ado.IsDevelopment();
            //_PublicClaimObjects.isallowedremotedomain = StaticPublicObjects.ado.IsAllowedDomain();
            _PublicClaimObjects.appsettingfilename = (_PublicClaimObjects.isdevelopment == true ? "appsettings.Development.json" : "appsettings.json");
            //_PublicClaimObjects.isswaggercall = (StaticPublicObjects.ado == null ? false : StaticPublicObjects.ado.IsSwaggerCall());
           // _PublicClaimObjects.isswaggercalladmin = (StaticPublicObjects.ado == null ? false : StaticPublicObjects.ado.IsSwaggerCall());
            _PublicClaimObjects.path = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRequestPath());
            _PublicClaimObjects.hostname = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetHostName());
            _PublicClaimObjects.hosturl = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetHostURL());
            _PublicClaimObjects.remotedomain = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRemoteDomain());
            //_PublicClaimObjects.remoteurl = (StaticPublicObjects.ado == null ? "" : StaticPublicObjects.ado.GetRemoteURL());
            _PublicClaimObjects.P_Get_User_Info_Class = (StaticPublicObjects.ado == null ? null : StaticPublicObjects.ado.P_Get_User_Info_Class(_PublicClaimObjects.username, AppEnum.ApplicationId.AppID));

            return _PublicClaimObjects;
        }
    }
}
