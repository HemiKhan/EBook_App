using EBook_Data.DatabaseContext;
using EBook_Data.Interfaces;
using EBook_Services.AppSetupServices;
using EBook_Services.GlobalService;
using Microsoft.EntityFrameworkCore;

namespace EBook_App.Helper
{
    public static class AppServices
    {
        public static void AddAppServices(this IServiceCollection services, DbStringCollection dbStringCollection)
        {
            services.AddTransient<IHttpContextAccessor, HttpContextAccessor>();
            services.AddSignalR();
            services.AddLogging();

            //DBContext
            services.AddDbContext<IEBook_DB_Context_10, EBook_DB_Context_10>(op => op.UseSqlServer(dbStringCollection.EBook_DB_ConnectionModel_10.ConnectionString, optionBuilder => optionBuilder.MigrationsAssembly("EBook_Data")));
            services.AddDbContext<IEBook_DB_Context_11, EBook_DB_Context_11>(op => op.UseSqlServer(dbStringCollection.EBook_DB_ConnectionModel_11.ConnectionString, optionBuilder => optionBuilder.MigrationsAssembly("EBook_Data")));
            services.AddDbContext<IEBook_DB_Context_13, EBook_DB_Context_13>(op => op.UseSqlServer(dbStringCollection.EBook_DB_ConnectionModel_13.ConnectionString, optionBuilder => optionBuilder.MigrationsAssembly("EBook_Data")));

            //ADO Repo
            services.AddScoped<IADORepository, ADORepository>();
            services.AddScoped<ILogFile, LogFile>();

            //services.AddTransient<IAppSetupService, AppSetupService>();
        }
    }
}
