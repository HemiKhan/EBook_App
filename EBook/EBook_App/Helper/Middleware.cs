using AutoMapper;
using EBook_Models.Data_Model;
using EBook_Services.GlobalService;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.VisualBasic;
using Newtonsoft.Json;
using Serilog.Context;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

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
