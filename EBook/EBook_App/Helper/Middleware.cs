using Microsoft.AspNetCore.Http.Extensions;
using Serilog.Context;

namespace EBook_App.Helper
{
    public class LoggingMiddleware
    {
        private readonly RequestDelegate _next;

        public LoggingMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            using (LogContext.PushProperty("Url", context.Request.GetDisplayUrl()))
            {
                await _next(context);
            }
        }
    }
    public class RequestStartMiddleware
    {
        private readonly RequestDelegate _next;

        public RequestStartMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Set the start datetime of the request
            context.Items["RequestStartTime"] = DateTime.UtcNow;

            // Call the next middleware in the pipeline
            await _next(context);
        }
    }
}
