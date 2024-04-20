
namespace EBook_Data.Interfaces
{
    public interface ILogFile
    {
        void ErrorLog(string LogEntryDateTime = "", string RequestURL = "", string ParameterDetail = "", string FunctionName = "", string SmallMessage = "", string Message = "");
        string GetWebHostEnvironmentPath();
    }
}
