using AutoMapper;
using EBook_Data.Common;
using EBook_Data.Interfaces;
using EBook_Models.Data_Model;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.VisualBasic;
using Newtonsoft.Json;
using System.Collections.Specialized;
using System.Security.Cryptography;
using System.Text;

namespace EBook_Data.DataAccess
{
    public class PublicClaimObjects
    {
        public DateTime requeststarttime { get; set; } = DateTime.UtcNow;
        private string _username = "";
        public string username
        {
            get
            {
                return _username;
            }
            set
            {
                string Ret = "";
                if (value != null)
                    Ret = value.ToUpper();
                _username = Ret;
            }
        }
        public string jit { get; set; } = "";
        public string key { get; set; } = "";
        public bool iswebtoken { get; set; } = false;
        public P_Get_User_Info? P_Get_User_Info_Class { get; set; } = null;
        private string _appsettingfilename = "appsettings.json";
        public string appsettingfilename
        {
            get
            {
                return _appsettingfilename;
            }
            set
            {
                string Ret = "appsettings.json";
                if (value == "appsettings.Development.json")
                    Ret = value;
                _appsettingfilename = Ret;
            }
        }
        public bool isallowedremotedomain { get; set; } = false;
        public bool isdevelopment { get; set; } = false;
        public bool isswaggercall { get; set; } = false;
        public bool isswaggercalladmin { get; set; } = false;
        public string path { get; set; } = "";
        public string hostname { get; set; } = "";
        public string hosturl { get; set; } = "";
        public string remotedomain { get; set; } = "";
        public string remoteurl { get; set; } = "";
        public bool isignorejsonserializeproperty { get; set; } = false;
        public bool isignorejsondeserializeproperty { get; set; } = false;
        public List<string>? ignorejsonserializepropertylist { get; set; } = null;
        public List<string>? ignorejsondeserializepropertylist { get; set; } = null;
    }
    public class Error
    {
        public int StatusCode { get; set; }
        public string Message { get; set; }
        public override string ToString() => JsonConvert.SerializeObject(this);
    }
    public class MemoryCacheType
    {
        public string TypeString
        {
            get
            {
                List<string>? RetList = new List<string>();
                RetList = GlobalsFunctions.GetCacheType(this.SubType);
                string Ret = "";
                Ret = GlobalsFunctions.GetTypeString(RetList);
                return Ret;
            }
        }
        public string SubType { get; set; } = "";
        public int DefaultExpirySeconds
        {
            get
            {
                int Ret = 60;
                Ret = GlobalsFunctions.GetDefaultCacheExpirySeconds(this.SubType);
                return Ret;
            }
        }
        public int NewExpirySeconds { get; set; } = 0;
        public int GetExpirySeconds
        {
            get
            {
                int Ret = 0;
                Ret = Math.Max(this.DefaultExpirySeconds, this.NewExpirySeconds);
                return Ret;
            }
        }
        public bool IsInputType { get; set; } = true;
    }
    public class MemoryCacheValueType
    {
        public SetMemoryCacheValueType _SetMemoryCacheValueType { get; set; }
        public GetMemoryCacheValueType _GetMemoryCacheValueType { get; set; }
        public MemoryCacheValueType()
        {
            _SetMemoryCacheValueType = new SetMemoryCacheValueType();
            _GetMemoryCacheValueType = new GetMemoryCacheValueType();
        }
    }
    public class GetMemoryCacheValueType
    {
        public string typestring
        {
            get
            {
                List<string>? RetList = new List<string>();
                RetList = GlobalsFunctions.GetCacheType(this.subtype);
                string Ret = "";
                Ret = GlobalsFunctions.GetTypeString(RetList);
                return Ret;
            }
        }
        public string subtype { get; set; } = "";
        public string keypath
        {
            get
            {
                string Ret = this.defaultkeypath;
                if (setkeypath != null)
                    Ret = setkeypath;
                return Ret;
            }
        }
        public string keyrequest
        {
            get
            {
                string Ret = this.defaultkeyrequest;
                if (setkeyrequest != null)
                    Ret = setkeyrequest;
                return Ret;
            }
        }
        public string keyusername
        {
            get
            {
                string Ret = this.defaultkeyusername;
                if (setkeyusername != null)
                    Ret = setkeyusername;
                return Ret;
            }
        }
        public string keyother
        {
            get
            {
                string Ret = this.defaultkeyother;
                if (setkeyother != null)
                    Ret = setkeyother;
                return Ret;
            }
        }
        public string keyvalues
        {
            get
            {
                string Ret = this.defaultkeyvalues;
                if (setkeyvalues != null)
                    Ret = setkeyvalues;
                return Ret;
            }
        }
        public string keyparavalues
        {
            get
            {
                string Ret = "";
                if (setkeyparavalues != null)
                    Ret = setkeyparavalues;
                return Ret;
            }
        }
        public string? setkeypath { get; set; } = null;
        public string? setkeyrequest { get; set; } = null;
        public string? setkeyusername { get; set; } = null;
        public string? setkeyother { get; set; } = null;
        public string? setkeyvalues { get; set; } = null;
        public string setkeyparavalues { get; set; } = "";
        public string defaultkeypath
        {
            get
            {
                string Ret = StaticPublicObjects.ado.GetPublicClaimObjects().path;
                return Ret;
            }
        }
        public string defaultkeyrequest
        {
            get
            {
                string Ret = "";
                return Ret;
            }
        }
        public string defaultkeyusername
        {
            get
            {
                string Ret = StaticPublicObjects.ado.GetPublicClaimObjects().username;
                return Ret;
            }
        }
        public string defaultkeyother
        {
            get
            {
                string Ret = "";
                return Ret;
            }
        }
        public string defaultkeyvalues
        {
            get
            {
                string Ret = "";
                return Ret;
            }
        }
        public string cachekey
        {
            get
            {
                string Ret = "";
                if (this.setkeypath != null && this.setkeypath.ToString() != "")
                    Ret += "path:" + this.setkeypath + "|";
                else if (this.defaultkeypath != null && this.defaultkeypath.ToString() != "")
                    Ret += "path:" + this.defaultkeypath + "|";

                if (this.setkeyrequest != null && this.setkeyrequest.ToString() != "")
                    Ret += "request:" + this.setkeyrequest + "|";
                else if (this.defaultkeyrequest != null && this.defaultkeyrequest.ToString() != "")
                    Ret += "request:" + this.defaultkeyrequest + "|";

                if (this.setkeyusername != null && this.setkeyusername.ToString() != "")
                    Ret += "username:" + this.setkeyusername + "|";
                else if (this.defaultkeyusername != null && this.defaultkeyusername.ToString() != "")
                    Ret += "username:" + this.defaultkeyusername + "|";

                if (this.setkeyother != null && this.setkeyother.ToString() != "")
                    Ret += "other:" + this.setkeyother + "|";
                else if (this.defaultkeyother != null && this.defaultkeyother.ToString() != "")
                    Ret += "other:" + this.defaultkeyother + "|";

                if (this.setkeyvalues != null && this.setkeyvalues.ToString() != "")
                    Ret += "value:" + this.setkeyvalues + "|";
                else if (this.defaultkeyvalues != null && this.defaultkeyvalues.ToString() != "")
                    Ret += "value:" + this.defaultkeyvalues + "|";

                if (this.setkeyparavalues.ToString() != "")
                    Ret += "paravalues=" + this.setkeyparavalues + "|";

                if (this.typestring != "")
                    Ret += this.typestring;

                if (this.subtype != "")
                    Ret += "subtype=" + this.subtype + "|";

                return Ret.ToLower();
            }
        }
        public bool isgetfromcache
        {
            get
            {
                bool Ret = this.defaultisgetcache;
                if (this.setisgetcache != null)
                    Ret = (bool)this.setisgetcache;
                return Ret;
            }
        }
        public bool isgetfromsqlcache
        {
            get
            {
                bool Ret = this.defaultisgetsqlcache;
                if (this.setisgetsqlcache != null)
                    Ret = (bool)this.setisgetsqlcache;
                return Ret;
            }
        }
        public bool? setisgetcache { get; set; } = null;
        public bool? setisgetsqlcache { get; set; } = null;
        public bool defaultisgetcache
        {
            get
            {
                bool Ret = false;
                Ret = GlobalsFunctions.GetDefaultGetCache(this.subtype);
                return Ret;
            }
        }
        public bool defaultisgetsqlcache
        {
            get
            {
                bool Ret = false;
                Ret = GlobalsFunctions.GetDefaultGetSQLCache(this.subtype);
                return Ret;
            }
        }
    }
    public class SetMemoryCacheValueType
    {
        public string TypeString
        {
            get
            {
                List<string>? RetList = new List<string>();
                RetList = GlobalsFunctions.GetCacheType(this.subtype);
                string Ret = "";
                Ret = GlobalsFunctions.GetTypeString(RetList);
                return Ret;
            }
        }
        public string subtype { get; set; } = "";
        public bool issetcache
        {
            get
            {
                bool Ret = this.defaultissetcache;
                if (this.setissetcache != null)
                    Ret = (bool)this.setissetcache;
                return Ret;
            }
        }
        public bool issetsqlcache
        {
            get
            {
                bool Ret = this.defaultissetsqlcache;
                if (this.setsqlissetcache != null)
                    Ret = (bool)this.setsqlissetcache;
                return Ret;
            }
        }
        public bool isremovecache
        {
            get
            {
                bool Ret = this.defaultisremovecache;
                if (this.setisremovecache != null)
                    Ret = (bool)this.setisremovecache;
                return Ret;
            }
        }
        public bool isremovesqlcache
        {
            get
            {
                bool Ret = this.defaultisremovesqlcache;
                if (this.setisremovesqlcache != null)
                    Ret = (bool)this.setisremovesqlcache;
                return Ret;
            }
        }
        public bool? setissetcache { get; set; } = null;
        public bool? setsqlissetcache { get; set; } = null;
        public bool? setisremovecache { get; set; } = null;
        public bool? setisremovesqlcache { get; set; } = null;
        public bool defaultissetcache
        {
            get
            {
                bool Ret = false;
                Ret = GlobalsFunctions.GetDefaultSetCache(this.subtype);
                return Ret;
            }
        }
        public bool defaultissetsqlcache
        {
            get
            {
                bool Ret = false;
                Ret = GlobalsFunctions.GetDefaultSetSQLCache(this.subtype);
                return Ret;
            }
        }
        public bool defaultisremovecache
        {
            get
            {
                bool Ret = false;
                Ret = GlobalsFunctions.GetDefaultRemoveCache(this.subtype);
                return Ret;
            }
        }
        public bool defaultisremovesqlcache
        {
            get
            {
                bool Ret = false;
                Ret = GlobalsFunctions.GetDefaultRemoveSQLCache(this.subtype);
                return Ret;
            }
        }
        public int cacheexpiryseconds
        {
            get
            {
                int Ret = 0;
                if (this.setcacheexpiryseconds != null)
                    Ret = (int)this.setcacheexpiryseconds;
                else
                    Ret = this.cacheexpirydefaultseconds;
                return Ret;
            }
        }
        public int? setcacheexpiryseconds { get; set; } = null;
        public int cacheexpirydefaultseconds
        {
            get
            {
                int Ret = 0;
                Ret = GlobalsFunctions.GetDefaultCacheExpirySeconds(this.subtype);
                return Ret;
            }
        }
    }
    public static class StaticPublicObjects
    {
        private static ILogFile _logFile;
        public static ILogFile logFile
        {
            get
            {
                return _logFile;
            }
            set
            {
                if (_logFile == null) _logFile = value;
            }
        }
        private static ILogger _logger;
        public static ILogger logger
        {
            get
            {
                return _logger;
            }
            set
            {
                if (_logger == null) _logger = value;
            }
        }
        private static IADORepository _ado;
        public static IADORepository ado
        {
            get
            {
                return _ado;
            }
            set
            {
                if (_ado == null) _ado = value;
            }
        }
        public static string? subdomain { get; set; } = null;
        private static IMapper _map;
        public static IMapper map
        {
            get
            {
                return _map;
            }
            set
            {
                if (_map == null) _map = value;
            }
        }
        private static IMemoryCache _memorycache;
        public static IMemoryCache memorycache
        {
            get
            {
                return _memorycache;
            }
            set
            {
                if (_memorycache == null) _memorycache = value;
            }
        }
    }
    public class Crypto
    {
        public Crypto() { }

        public static string EncryptConnectionString(string qs, string key)
        {
            return EncryptDesToHex(qs, "MSPL_HRMS09182023#?+");
        }
        public static string DecryptConnectionString(string qs, string key)
        {
            return DecryptDesFromHex(qs, "MSPL_HRMS09182023#?+");
        }
        public static string EncriptURL(string stringToEncrypt, string encryptionKey)
        {
            byte[] key = { };
            byte[] iv = { 0x8, 0x7, 0x6, 0x5, 0x1, 0x2, 0x3, 0x4 };
            byte[] inputByteArray;
            byte[] outputByteArray;

            try
            {
                key = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 8));
                DESCryptoServiceProvider des = new DESCryptoServiceProvider();
                inputByteArray = Encoding.UTF8.GetBytes(stringToEncrypt);
                MemoryStream MS = new MemoryStream();
                CryptoStream cs = new CryptoStream(MS, des.CreateEncryptor(key, iv), CryptoStreamMode.Write);
                cs.Write(inputByteArray, 0, inputByteArray.Length);
                cs.FlushFinalBlock();
                outputByteArray = MS.ToArray();
                string retstr = Bytes_To_String2(outputByteArray);
                return retstr;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "EncriptURL", SmallMessage: ex.Message, Message: ex.ToString());
                return (string.Empty);
            }
        }
        private static string Bytes_To_String2(byte[] bytes_Input)
        {
            StringBuilder strTemp = new StringBuilder(bytes_Input.Length * 2);
            foreach (byte b in bytes_Input)
                strTemp.Append(Conversion.Hex(b));
            return strTemp.ToString();
        }
        public static byte[] createSalt(byte[] saltSize)
        {
            byte[] saltBytes = saltSize;
            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            rng.GetNonZeroBytes(saltBytes);
            return saltBytes;
        }
        public static string EncodePassword(byte passFormat, string passtext, string passwordSalt)
        {
            if ((passFormat.Equals(0)))
                return passtext;
            else
            {
                byte[] Key;
                byte[] IV;
                byte[] bytePASS = Encoding.Unicode.GetBytes(passtext);
                byte[] byteSALT = Convert.FromBase64String(passwordSalt);
                var Lenarr = (byteSALT.Length + bytePASS.Length) - 1;
                byte[] byteRESULT = new byte[Lenarr + 1];

                System.Buffer.BlockCopy(byteSALT, 0, byteRESULT, 0, byteSALT.Length);
                System.Buffer.BlockCopy(bytePASS, 0, byteRESULT, byteSALT.Length, bytePASS.Length);

                TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
                tdes.KeySize = 128;
                Key = UTF8Encoding.UTF8.GetBytes("0123456789ABCDEF");
                IV = UTF8Encoding.UTF8.GetBytes("ABCDEFGH");
                tdes.Key = Key;
                tdes.IV = IV;
                ICryptoTransform cTransform = tdes.CreateEncryptor();
                byte[] resultArray = cTransform.TransformFinalBlock(byteRESULT, 0, byteRESULT.Length);
                return Convert.ToBase64String(resultArray, 0, resultArray.Length);
            }
        }
        public static string DecodePassword(string Password, string PW_Salt)
        {
            byte[] PasswordDecode;
            byte[] Salt;
            string RetVal;
            TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
            tdes.KeySize = 128;
            tdes.Key = UTF8Encoding.UTF8.GetBytes("0123456789ABCDEF");
            tdes.IV = UTF8Encoding.UTF8.GetBytes("ABCDEFGH");
            byte[] toEncryptArray = Convert.FromBase64String(Password);
            ICryptoTransform cTransform1 = tdes.CreateDecryptor();
            PasswordDecode = cTransform1.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
            Salt = Convert.FromBase64String(PW_Salt);
            RetVal = Encoding.Unicode.GetString(PasswordDecode).Remove(0, Encoding.Unicode.GetString(Salt).Length);
            return RetVal;
        }

        #region DES Encrypt/Decrypt
        /// <summary>
        ///    Decrypts  a particular string with a specific Key
        /// </summary>
        public string DecryptDes(string stringToDecrypt, string sEncryptionKey)
        {
            stringToDecrypt = stringToDecrypt.Replace("plus", "+");
            byte[] key = { };
            byte[] IV = { 10, 20, 30, 40, 50, 60, 70, 80 };
            byte[] inputByteArray = new byte[stringToDecrypt.Length];
            try
            {
                key = Encoding.UTF8.GetBytes(sEncryptionKey.Substring(0, 8));
                DESCryptoServiceProvider des = new DESCryptoServiceProvider();
                inputByteArray = Convert.FromBase64String(stringToDecrypt);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(key, IV), CryptoStreamMode.Write);
                cs.Write(inputByteArray, 0, inputByteArray.Length);
                cs.FlushFinalBlock();
                Encoding encoding = Encoding.UTF8;
                return encoding.GetString(ms.ToArray());
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "DecryptDes", SmallMessage: ex.Message, Message: ex.ToString());
                return (string.Empty);
            }
        }

        /// <summary>
        ///   Encrypts  a particular string with a specific Key
        /// </summary>
        /// <param name="stringToEncrypt"></param>
        /// <param name="sEncryptionKey"></param>
        /// <returns></returns>
        public string EncryptDes(string stringToEncrypt, string sEncryptionKey)
        {
            byte[] key = { };
            byte[] IV = { 10, 20, 30, 40, 50, 60, 70, 80 };
            byte[] inputByteArray; //Convert.ToByte(stringToEncrypt.Length) 

            try
            {
                key = Encoding.UTF8.GetBytes(sEncryptionKey.Substring(0, 8));
                DESCryptoServiceProvider des = new DESCryptoServiceProvider();
                inputByteArray = Encoding.UTF8.GetBytes(stringToEncrypt);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(key, IV), CryptoStreamMode.Write);
                cs.Write(inputByteArray, 0, inputByteArray.Length);
                cs.FlushFinalBlock();
                //string retstr = Convert.ToBase64String(ms.ToArray());
                //retstr = retstr.Replace("+", "plus");
                //return retstr;

                string retstr = ToHex(ms.ToArray());
                //retstr = retstr.Replace("+", "plus");
                return retstr;

            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "EncryptDes", SmallMessage: ex.Message, Message: ex.ToString());
                return (string.Empty);
            }
        }

        public static string EncryptDesToHex(string stringToEncrypt, string encryptionKey)
        {
            byte[] key = { };
            byte[] iv = { 0x08, 0x07, 0x06, 0x05, 0x01, 0x02, 0x03, 0x04 };
            byte[] inputByteArray;
            byte[] outputByteArray;

            try
            {
                key = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 8));
                DESCryptoServiceProvider des = new DESCryptoServiceProvider();
                inputByteArray = Encoding.UTF8.GetBytes(stringToEncrypt);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(key, iv), CryptoStreamMode.Write);
                cs.Write(inputByteArray, 0, inputByteArray.Length);
                cs.FlushFinalBlock();
                outputByteArray = ms.ToArray();
                string retstr = ToHex(outputByteArray);
                return retstr;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "EncryptDesToHex", SmallMessage: ex.Message, Message: ex.ToString());
                return (string.Empty);
            }
        }

        public static string DecryptDesFromHex(string stringToDecrypt, string encryptionKey)
        {
            stringToDecrypt = Convert.ToBase64String(FromHex(stringToDecrypt));
            byte[] key = { };
            byte[] iv = { 0x08, 0x07, 0x06, 0x05, 0x01, 0x02, 0x03, 0x04 };
            byte[] inputByteArray = new byte[stringToDecrypt.Length];

            try
            {
                key = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 8));
                DESCryptoServiceProvider des = new DESCryptoServiceProvider();
                inputByteArray = Convert.FromBase64String(stringToDecrypt);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(key, iv), CryptoStreamMode.Write);
                cs.Write(inputByteArray, 0, inputByteArray.Length);
                cs.FlushFinalBlock();
                Encoding encoding = Encoding.UTF8;
                return encoding.GetString(ms.ToArray());
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "DecryptDesFromHex", SmallMessage: ex.Message, Message: ex.ToString());
                return (string.Empty);
            }
        }

        #endregion

        public static string ToHex(Byte[] inputByte)
        {
            if ((inputByte == null) || (inputByte.Length == 0))
            {
                return "";
            }

            String HexFormat = "{0:X2}";
            StringBuilder sb = new StringBuilder();

            foreach (Byte b in inputByte)
            {
                sb.Append(String.Format(HexFormat, b));
            }
            return sb.ToString();
        }

        public static Byte[] FromHex(String hexEncoded)
        {
            Byte[] retByte = null;

            if ((hexEncoded == null) || (hexEncoded.Length == 0))
                return null;

            try
            {
                Int32 l = Convert.ToInt32(hexEncoded.Length / 2);
                int iTemp = l - 1;
                Byte[] b = new Byte[iTemp + 1];

                for (int i = 0; i <= iTemp; i++)
                {
                    b[i] = Convert.ToByte(hexEncoded.Substring(i * 2, 2), 16);
                }
                retByte = b;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "FromHex", SmallMessage: ex.Message, Message: ex.ToString());
            }

            return retByte;
        }

        public static string EncryptQueryString(String qs)
        {
            qs = (qs ?? "");
            return Crypto.EncryptDesToHex(qs, "MetroCryptoUSA08861-POMS#?+");
        }

        public static string NewEncodePassword(byte passFormat, string passtext, string passwordSalt)
        {
            if (passFormat == 0)
            {
                // No encoding required
                return passtext;
            }
            else
            {
                // Convert password and salt to bytes
                byte[] bytePASS = Encoding.Unicode.GetBytes(passtext);
                byte[] byteSALT = Convert.FromBase64String(passwordSalt);

                // Concatenate salt and password bytes
                byte[] combinedBytes = new byte[bytePASS.Length + byteSALT.Length];
                Buffer.BlockCopy(bytePASS, 0, combinedBytes, 0, bytePASS.Length);
                Buffer.BlockCopy(byteSALT, 0, combinedBytes, bytePASS.Length, byteSALT.Length);

                // Use AES encryption
                using (Aes aes = Aes.Create())
                {
                    aes.KeySize = 256;
                    aes.Mode = CipherMode.CBC;

                    // Generate key and IV from password
                    Rfc2898DeriveBytes keyDerivation = new Rfc2898DeriveBytes(passtext, byteSALT, 10000);
                    aes.Key = keyDerivation.GetBytes(aes.KeySize / 8);
                    aes.IV = keyDerivation.GetBytes(aes.BlockSize / 8);

                    // Encrypt the combined bytes
                    using (MemoryStream ms = new MemoryStream())
                    {
                        using (CryptoStream cs = new CryptoStream(ms, aes.CreateEncryptor(), CryptoStreamMode.Write))
                        {
                            cs.Write(combinedBytes, 0, combinedBytes.Length);
                            cs.FlushFinalBlock();
                        }
                        return Convert.ToBase64String(ms.ToArray());
                    }
                }
            }
        }
        public static string NewDecodePassword(byte passFormat, string encodedPassword, string passwordSalt)
        {
            if (passFormat == 0)
            {
                // No decoding required
                return encodedPassword;
            }
            else
            {
                // Convert encoded password to bytes
                byte[] encryptedBytes = Convert.FromBase64String(encodedPassword);

                // Convert salt to bytes
                byte[] byteSALT = Convert.FromBase64String(passwordSalt);

                // Use AES decryption
                using (Aes aes = Aes.Create())
                {
                    aes.KeySize = 256;
                    aes.Mode = CipherMode.CBC;

                    // Generate key and IV from password
                    Rfc2898DeriveBytes keyDerivation = new Rfc2898DeriveBytes(encodedPassword, byteSALT, 10000);
                    aes.Key = keyDerivation.GetBytes(aes.KeySize / 8);
                    aes.IV = keyDerivation.GetBytes(aes.BlockSize / 8);

                    // Decrypt the encrypted bytes
                    using (MemoryStream ms = new MemoryStream(encryptedBytes))
                    {
                        using (CryptoStream cs = new CryptoStream(ms, aes.CreateDecryptor(), CryptoStreamMode.Read))
                        {
                            byte[] decryptedBytes = new byte[encryptedBytes.Length];
                            int decryptedByteCount = cs.Read(decryptedBytes, 0, decryptedBytes.Length);
                            return Encoding.Unicode.GetString(decryptedBytes, 0, decryptedByteCount);
                        }
                    }
                }
            }
        }
        public static byte[] GenerateSalt(byte[] saltSize)
        {
            byte[] saltBytes = saltSize;
            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            rng.GetNonZeroBytes(saltBytes);
            return saltBytes;
        }
        #region DES Encrypt/Decrypt
        public static string EncryptWithExpiry(string plainText, string encryptionKey, TimeSpan validityPeriod)
        {
            // Ensure encryptionKey is at least 16 characters long
            if (encryptionKey.Length < 16)
                throw new ArgumentException("Encryption key must be at least 16 characters long.");

            // Convert plaintext to bytes
            byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);

            // Add current timestamp to plain bytes
            byte[] timestampBytes = BitConverter.GetBytes(DateTime.UtcNow.Ticks);
            byte[] combinedBytes = new byte[plainBytes.Length + timestampBytes.Length];
            Array.Copy(plainBytes, combinedBytes, plainBytes.Length);
            Array.Copy(timestampBytes, 0, combinedBytes, plainBytes.Length, timestampBytes.Length);

            // Encrypt combined bytes
            byte[] encryptedBytes = EncryptBytes(combinedBytes, encryptionKey);

            // Convert result to hex string
            return BitConverter.ToString(encryptedBytes).Replace("-", "");
        }
        public static string DecryptWithExpiry(string hexString, string encryptionKey, TimeSpan validityPeriod)
        {
            // Convert hex string to bytes
            byte[] encryptedBytes = new byte[hexString.Length / 2];
            for (int i = 0; i < encryptedBytes.Length; i++)
            {
                encryptedBytes[i] = Convert.ToByte(hexString.Substring(i * 2, 2), 16);
            }

            // Decrypt bytes
            byte[] decryptedBytes = DecryptBytes(encryptedBytes, encryptionKey);

            // Extract plaintext and timestamp
            byte[] plainBytes = new byte[decryptedBytes.Length - sizeof(long)];
            byte[] timestampBytes = new byte[sizeof(long)];
            Array.Copy(decryptedBytes, plainBytes, plainBytes.Length);
            Array.Copy(decryptedBytes, plainBytes.Length, timestampBytes, 0, timestampBytes.Length);

            // Check timestamp validity
            long ticks = BitConverter.ToInt64(timestampBytes, 0);
            DateTime timestamp = new DateTime(ticks, DateTimeKind.Utc);
            if (DateTime.UtcNow - timestamp > validityPeriod)
                throw new InvalidOperationException("Data has expired.");

            // Convert plaintext bytes to string
            return Encoding.UTF8.GetString(plainBytes);
        }
        private static byte[] EncryptBytes(byte[] inputBytes, string encryptionKey)
        {
            // Convert encryptionKey to bytes
            byte[] keyBytes = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 16));

            // Encrypt bytes using AES
            using (Aes aesAlg = Aes.Create())
            {
                aesAlg.Key = keyBytes;
                aesAlg.GenerateIV();

                using (MemoryStream msEncrypt = new MemoryStream())
                {
                    using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, aesAlg.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        csEncrypt.Write(inputBytes, 0, inputBytes.Length);
                        csEncrypt.FlushFinalBlock();
                    }

                    byte[] ivAndEncryptedBytes = new byte[aesAlg.IV.Length + msEncrypt.Length];
                    Array.Copy(aesAlg.IV, ivAndEncryptedBytes, aesAlg.IV.Length);
                    Array.Copy(msEncrypt.ToArray(), 0, ivAndEncryptedBytes, aesAlg.IV.Length, msEncrypt.Length);
                    return ivAndEncryptedBytes;
                }
            }
        }
        private static byte[] DecryptBytes(byte[] encryptedBytes, string encryptionKey)
        {
            // Convert encryptionKey to bytes
            byte[] keyBytes = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 16));

            // Extract IV and encrypted data
            byte[] iv = new byte[16];
            byte[] encryptedData = new byte[encryptedBytes.Length - 16];
            Array.Copy(encryptedBytes, iv, 16);
            Array.Copy(encryptedBytes, 16, encryptedData, 0, encryptedData.Length);

            // Decrypt bytes using AES
            using (Aes aesAlg = Aes.Create())
            {
                aesAlg.Key = keyBytes;
                aesAlg.IV = iv;

                using (MemoryStream msDecrypt = new MemoryStream(encryptedData))
                {
                    using (CryptoStream csDecrypt = new CryptoStream(msDecrypt, aesAlg.CreateDecryptor(), CryptoStreamMode.Read))
                    {
                        using (MemoryStream msPlain = new MemoryStream())
                        {
                            csDecrypt.CopyTo(msPlain);
                            return msPlain.ToArray();
                        }
                    }
                }
            }
        }
        public static string EncryptToHex(string plainText, string encryptionKey, bool isfixedIV = false, TimeSpan? validityPeriod = null)
        {
            // Ensure encryptionKey is at least 16 characters long
            if (encryptionKey.Length < 16)
                throw new ArgumentException("Encryption key must be at least 16 characters long.");

            // Convert stringToEncrypt and encryptionKey to bytes
            byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);
            byte[] keyBytes = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 16));

            using (Aes aesAlg = Aes.Create())
            {
                aesAlg.Key = keyBytes;
                if (isfixedIV)
                    aesAlg.Mode = CipherMode.ECB; // Use ECB mode
                else
                    aesAlg.GenerateIV();

                // Encrypt the data
                using (MemoryStream msEncrypt = new MemoryStream())
                {
                    using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, aesAlg.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        csEncrypt.Write(plainBytes, 0, plainBytes.Length);
                        csEncrypt.FlushFinalBlock();
                    }

                    if (isfixedIV == false)
                    {
                        // Combine IV and encrypted data
                        byte[] encryptedBytes = msEncrypt.ToArray();
                        byte[] resultBytes = new byte[aesAlg.IV.Length + encryptedBytes.Length];
                        Array.Copy(aesAlg.IV, resultBytes, aesAlg.IV.Length);
                        Array.Copy(encryptedBytes, 0, resultBytes, aesAlg.IV.Length, encryptedBytes.Length);
                        return BitConverter.ToString(resultBytes).Replace("-", "");
                    }
                    else
                    {
                        // Convert result to hex string
                        return BitConverter.ToString(msEncrypt.ToArray()).Replace("-", "");
                    }
                }
            }
        }
        public static string DecryptFromHex(string hexString, string encryptionKey, bool isfixedIV = false)
        {
            // Ensure encryptionKey is at least 16 characters long
            if (encryptionKey.Length < 16)
                throw new ArgumentException("Encryption key must be at least 16 characters long.");

            // Convert hex string to bytes
            byte[] inputBytes = new byte[hexString.Length / 2];
            for (int i = 0; i < inputBytes.Length; i++)
            {
                inputBytes[i] = Convert.ToByte(hexString.Substring(i * 2, 2), 16);
            }

            byte[] iv = new byte[16];
            byte[] encryptedBytes = new byte[inputBytes.Length - iv.Length];
            if (isfixedIV == false)
            {
                // Extract IV and encrypted data
                Array.Copy(inputBytes, iv, iv.Length);
                Array.Copy(inputBytes, iv.Length, encryptedBytes, 0, encryptedBytes.Length);
            }
            // Convert encryptionKey to bytes
            byte[] keyBytes = Encoding.UTF8.GetBytes(encryptionKey.Substring(0, 16));

            using (Aes aesAlg = Aes.Create())
            {
                aesAlg.Key = keyBytes;
                if (isfixedIV)
                    aesAlg.Mode = CipherMode.ECB; // Use ECB mode
                else
                    aesAlg.IV = iv;

                // Decrypt the data
                using (MemoryStream msDecrypt = new MemoryStream((isfixedIV ? inputBytes : encryptedBytes)))
                {
                    using (CryptoStream csDecrypt = new CryptoStream(msDecrypt, aesAlg.CreateDecryptor(), CryptoStreamMode.Read))
                    {
                        using (StreamReader srDecrypt = new StreamReader(csDecrypt))
                        {
                            return srDecrypt.ReadToEnd();
                        }
                    }
                }
            }
        }
        #endregion
        public static string DecryptQueryString(String qs)
        {
            return Crypto.DecryptFromHex(qs, "MetroCryptoUSA08861-POMS#?+");
        }
        public static string EncryptString(String qs)
        {
            qs = (qs ?? "");
            return Crypto.EncryptToHex(qs, "MetroCryptoUSA08861-POMS#?+");
        }
        public static string DecryptString(String qs)
        {
            return Crypto.DecryptFromHex(qs, "MetroCryptoUSA08861-POMS#?+");
        }
        public static string? EncryptNumericToString(int? qs)
        {
            if (qs == null)
                return null;
            return Crypto.EncryptToHex(qs.ToString(), "MetroCryptoUSA08861-POMS#?+");
        }
        public static string EncryptNumericToStringWithOutNull(int? qs)
        {
            if (qs == null)
                return "";
            return Crypto.EncryptToHex(qs.ToString(), "MetroCryptoUSA08861-POMS#?+");
        }
        public static int? DecryptNumericToString(string? qs, bool IsNullForEmptyString = false)
        {
            if (qs == null)
                return null;
            else if (qs == "" && IsNullForEmptyString)
                return null;
            else if (qs == "" && IsNullForEmptyString == false)
                return 0;
            return Convert.ToInt32(Crypto.DecryptFromHex(qs, "MetroCryptoUSA08861-POMS#?+"));
        }
        public static int DecryptNumericToStringWithOutNull(string? qs)
        {
            if (qs == null)
                return 0;
            return (int)DecryptNumericToString(qs);
        }
        public static string EncryptOrderSource(string qs)
        {
            if (qs == null || qs.Length == 0)
                return "0";
            else
                return Crypto.EncryptToHex(qs.ToString(), "MetroCryptoUSA08861-POMS#?+");
        }
        public static string DecryptOrderSource(String qs)
        {
            string Retqs = "0";
            if (qs == null || qs.Length == 0)
                return Retqs;
            else
            {
                Retqs = Crypto.DecryptFromHex(qs, "MetroCryptoUSA08861-POMS#?+");
                if (Information.IsNumeric(Retqs) == false)
                    Retqs = "0";
            }
            return Retqs;
        }
        public static string EncryptUserName(String qs)
        {
            if (qs == null || qs.Length == 0)
                return qs;
            else
                return Crypto.EncryptToHex(qs.ToUpper(), "MetroCryptoUSA08861-POMS#?+");
        }
        public static string DecryptUserName(String qs)
        {
            if (qs == null || qs.Length == 0)
                return qs;
            else
                return Crypto.DecryptFromHex(qs, "MetroCryptoUSA08861-POMS#?+").ToUpper();
        }
        public static string EncryptPasswordHashSalt(String ph, String ps)
        {
            return Crypto.EncryptToHex($"{ph}{ps}", "MetroCryptoUSA08861-POMS#?+", true);
        }
        public static string DecryptPasswordHashSalt(String qs)
        {
            return Crypto.DecryptFromHex(qs, "MetroCryptoUSA08861-POMS#?+", true);
        }
        public static string EncryptPassword(String password)
        {
            return Crypto.EncryptToHex($"{password}", "MetroCryptoUSA08861-POMS#?+", true);
        }
        public static string DecryptPassword(String password)
        {
            return Crypto.DecryptFromHex(password, "MetroCryptoUSA08861-POMS#?+", true);
        }
        public static NameValueCollection ConvertNVC(string qs)
        {
            NameValueCollection nvc = new NameValueCollection();
            string[] nameValuePairs = qs.Split('&');

            for (int i = 0; i < nameValuePairs.Length; i++)
            {
                string[] nameValue = nameValuePairs[i].Split('=');

                if (nameValue.Length == 2)
                    nvc.Add(nameValue[0], nameValue[1]);
            }

            return nvc;
        }
    }
   
}
