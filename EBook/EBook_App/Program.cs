using EBook_App.Helper;
using EBook_Data.DataAccess;
using EBook_Data.DatabaseContext;
using EBook_Models.Data_Model;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using Serilog;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages().AddRazorRuntimeCompilation();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(x =>
{
    x.Cookie.HttpOnly = true;
    x.Cookie.IsEssential = true;
    x.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    x.IdleTimeout = TimeSpan.FromMinutes(30);
});

// Add Authentication JWT Token Start
builder.Services.AddAuthentication(a =>
{
    a.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    a.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(jb =>
{
    jb.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
    {
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Constrant.Authenticatekey)),
        ValidateIssuer = true,
        ValidIssuer = Constrant.AuthenticateIssuer,
        ValidAudience = Constrant.AuthenticateAudience,
        ValidateIssuerSigningKey = true,
        ValidateAudience = true,
        RequireExpirationTime = true,
    };
});
// Add Authentication JWT Token End

builder.Services.AddHttpContextAccessor();
builder.Services.AddControllersWithViews();
builder.Services.AddSingleton<JsonSerializerSettings>(options => options.GetRequiredService<IOptions<MvcNewtonsoftJsonOptions>>().Value.SerializerSettings);

//dbConnection Get from appsetting.json
DbStringCollection dbStringCollection = new DbStringCollection()
{
    EBook_DB_ConnectionModel_10 = builder.Configuration.GetSection(nameof(EBook_DB_ConnectionModel_10)).Get<EBook_DB_ConnectionModel_10>(),
    EBook_DB_ConnectionModel_11 = builder.Configuration.GetSection(nameof(EBook_DB_ConnectionModel_11)).Get<EBook_DB_ConnectionModel_11>()
};
builder.Services.AddSingleton(dbStringCollection);
builder.Services.AddAppServices(dbStringCollection);


// Add services to the container.
builder.Services.AddControllersWithViews();

var app = builder.Build();

string virDir = builder.Configuration.GetSection("VirtualDirectory").Value;

app.UseSession();
app.UseStaticFiles();

app.UseMiddleware<RequestStartMiddleware>();
app.UseMiddleware<LoggingMiddleware>();
app.UseMiddleware<CustomContractResolverMiddleware>();

app.UseExceptionHandler(error =>
{
    error.Run(async context =>
    {
        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        context.Response.ContentType = "application/json";
        var contextFeature = context.Features.Get<IExceptionHandlerFeature>();
        if (contextFeature != null)
        {
            Log.Error(contextFeature.Error, $"{contextFeature.Error.Message}");
            Log.CloseAndFlush();
            string _Path = StaticPublicObjects.ado.GetRequestPath();
            StaticPublicObjects.logFile.ErrorLog(FunctionName: "Global Error; Path" + _Path, SmallMessage: contextFeature.Error.Message, Message: contextFeature.Error.ToString());

            string ID = "";
            Exception exception = new Exception("Internal Server Error");
            string CurrentURL = StaticPublicObjects.ado.GetRequestPath();
            ID = context.Session.SetupSessionError("Error", "~/" + CurrentURL, CurrentURL, exception);
            context.Response.Redirect($"/Error/Index?ID={ID}");
        }
    });
});

if (app.Environment.IsDevelopment())
{
    app.UseStatusCodePagesWithReExecute("/Error/Index", "?statusCode={0}");
    app.UseHsts();
}
else
{
    app.UseStatusCodePagesWithReExecute("/Error/Index", "?statusCode={0}");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=EBook}/{action=Home}/{id?}");

app.Use(async (context, next) =>
{
    if (context.Response.HasStarted == false)
    {
        PublicClaimObjects _PublicClaimObjects = new PublicClaimObjects();
        _PublicClaimObjects = context.Session.GetObject<PublicClaimObjects>("PublicClaimObjects");
        context.Items["PublicClaimObjects"] = _PublicClaimObjects;
        if (_PublicClaimObjects != null)
        {
            try
            {
                _PublicClaimObjects.requeststarttime = Convert.ToDateTime(context.Items["RequestStartTime"]);
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Program Set RequestStartTime", SmallMessage: ex.Message, Message: ex.ToString());
            }
        }
    }
    await next.Invoke();
});

app.Run();
