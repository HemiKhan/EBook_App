using AutoMapper.Configuration;
using EBook_Data.DataAccess;
using EBook_Data.Interfaces;
using Microsoft.AspNetCore.Http;

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
    }
}
