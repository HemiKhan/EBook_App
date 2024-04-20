using EBook_Data.Interfaces;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EBook_Services.GlobalService
{
    public class LogFile : ILogFile
    {
        private readonly IWebHostEnvironment _env;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly string _IP;
        public LogFile(IWebHostEnvironment env, IHttpContextAccessor httpContextAccessor, IADORepository ado)
        {
            this._env = env;
            this._httpContextAccessor = httpContextAccessor;
            this._IP = ado.GetLocalIPAddress();
        }
        public string GetWebHostEnvironmentPath()
        {
            return _env.ContentRootPath;
        }
        public void ErrorLog(string LogEntryDateTime = "", string RequestURL = "", string ParameterDetail = "", string FunctionName = "", string SmallMessage = "", string Message = "")
        {
            try
            {
                if (LogEntryDateTime == "")
                    LogEntryDateTime = Strings.Format(DateTime.UtcNow, "MM/dd/yyyy HH:mm:ss.fff tt UTC");
                if (RequestURL == "")
                    RequestURL = _httpContextAccessor.HttpContext.Request.Path.Value;
                StringBuilder sb = new StringBuilder();
                string FileName = "";
                DateTime dt = DateTime.UtcNow;
                FileInfo FInfo;
                // Dim dt As DateTime = Now

                sb.Append(string.Format("Log Entry On: {0}", LogEntryDateTime));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append(string.Format("Log From: {0}", RequestURL));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append(string.Format("IP Address: {0}", this._IP));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append(string.Format("Function Name: {0}", FunctionName));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append(string.Format("Parameter Detail: {0}", ParameterDetail));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append(string.Format("Small Message: {0}", SmallMessage));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append(string.Format("Message: {0}", Message));
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                sb.Append("_____________________________________");
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                FileName = "Error_" + dt.ToString("yyyy-MM-dd");
                //FInfo = new FileInfo(string.Format(@"{0}\ErrorLog\{1}.txt", AppDomain.CurrentDomain.BaseDirectory, FileName));
                FInfo = new FileInfo(string.Format(@"{0}\ErrorLog\{1}.txt", _env.ContentRootPath, FileName));
                if (!FInfo.Directory.Exists)
                    FInfo.Directory.Create();

                //File.AppendAllText(AppDomain.CurrentDomain.BaseDirectory + @"\ErrorLog\\" + FileName + ".txt", sb.ToString());
                File.AppendAllText(_env.ContentRootPath + @"\ErrorLog\\" + FileName + ".txt", sb.ToString());
                sb.Clear();
            }
            catch (Exception ex)
            {
            }
        }

    }
}
