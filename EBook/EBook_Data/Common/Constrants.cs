using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EBook_Data.Common
{
    public class Constrant
    {
        public static string Authenticatekey = "This is key that will be used in encryption";
        public static string AuthenticateIssuer = "http://localhost:7274";
        public static string AuthenticateAudience = "http://localhost:7274";
        public static Uri AppUrl = new Uri("http://172.16.0.11/api/");
    }
}
