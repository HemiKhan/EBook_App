using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using EBook_Models.App_Models;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.VisualBasic;
using Newtonsoft.Json;
using System.Data;
using System.Security.Cryptography;
using System.Text;

namespace EBook_Services.MemoryCache
{
    public class MemoryCachesValues
    {
        public object? value { get; set; }
        public MemoryCacheEntryOptions cacheEntryOptions { get; set; } = new MemoryCacheEntryOptions();
    }
    public class MemoryCaches
    {
        public static bool GetCacheValue(string CacheKey, IMemoryCache cache, int Seconds)
        {
            bool result_code = false;
            if (cache.TryGetValue(CacheKey, out MemoryCachesValues cachedResponse))
            {
                result_code = (bool)cachedResponse.value;
            }
            else 
            {
                DataRow? DR = null;
                DR = StaticPublicObjects.ado.P_Get_CacheEntry(CacheKey);
                if (DR != null)
                {
                    if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                    {
                        result_code = Convert.ToBoolean(DR["Value"]);
                        SetTokenCacheValue(CacheKey, Seconds, cache);
                    }
                }
            }
            return result_code;
        }
        public static void RemoveCacheValue(string CacheKey, IMemoryCache cache, bool IsRemoveSQLCache)
        {
            cache.Remove(CacheKey);
            if (IsRemoveSQLCache)
                StaticPublicObjects.ado.P_CacheEntry_Delete(CacheKey);
        }
        public static MemoryCachesValues SetMemoryCachesValues(string CacheKey, object? value, int seconds, IMemoryCache cache, ref DateTime? uTCDateTime, bool IsRefresh)
        {
            MemoryCacheEntryOptions cacheEntryOptions = null;
            if (cache.TryGetValue(CacheKey, out MemoryCachesValues cachedResponse))
            {
                if (cachedResponse.cacheEntryOptions == null)
                {
                    cacheEntryOptions = new MemoryCacheEntryOptions();
                    cacheEntryOptions.AbsoluteExpiration = DateTime.UtcNow.AddSeconds(seconds);
                    uTCDateTime = cacheEntryOptions.AbsoluteExpiration.GetValueOrDefault().UtcDateTime;
                }
                else
                {
                    cacheEntryOptions = new MemoryCacheEntryOptions();
                    if (IsRefresh)
                        cacheEntryOptions.AbsoluteExpiration = DateTime.UtcNow.AddSeconds(seconds);
                    else
                        cacheEntryOptions.AbsoluteExpiration = cachedResponse.cacheEntryOptions.AbsoluteExpiration;
                    uTCDateTime = cacheEntryOptions.AbsoluteExpiration.GetValueOrDefault().UtcDateTime;
                }

            }
            else
            {
                if (cacheEntryOptions == null)
                {
                    cacheEntryOptions = new MemoryCacheEntryOptions();
                    uTCDateTime = DateTime.UtcNow.AddSeconds(seconds);
                    cacheEntryOptions.AbsoluteExpiration = uTCDateTime;// DateTime.Now.AddSeconds(seconds);
                    uTCDateTime = cacheEntryOptions.AbsoluteExpiration.GetValueOrDefault().UtcDateTime;
                }
            }
            MemoryCachesValues memoryCachesValues = new MemoryCachesValues();
            memoryCachesValues.value = value;
            memoryCachesValues.cacheEntryOptions = cacheEntryOptions;
            return memoryCachesValues;
        }
        public static void SetTokenCacheValue(string CacheKey, int Seconds, IMemoryCache cache)
        {
            MemoryCachesValues memoryCachesValues = new MemoryCachesValues();
            DateTime? uTCDateTime = null;
            memoryCachesValues = SetMemoryCachesValues(CacheKey, true, Seconds, cache, ref uTCDateTime, true);
            cache.Set(CacheKey, memoryCachesValues, memoryCachesValues.cacheEntryOptions);

            if (cache.TryGetValue(CacheKey + "datetime", out DateTime tempdatetime) == false)
            {
                cache.Set(CacheKey + "datetime", uTCDateTime, TimeSpan.FromSeconds(60));
                StaticPublicObjects.ado.P_CacheEntry_IU(CacheKey, "true", uTCDateTime, AppEnum.ApplicationId.EBookAppID);
            }
        }
        public static string GetObjectHash(object _object)
        {
            // hash the request body to generate a cache key
            // for simplicity, we're using MD5 here, but you might want to use a stronger hash algorithm
            using (var _SHA512 = SHA512.Create())
            {
                JsonSerializerSettings settings = Globals.GetCustomJsonDefaultSetting(AppEnum.JsonIgnorePropertyType.None, false, false);
                var serializedBody = JsonConvert.SerializeObject(_object, settings);
                var hash = _SHA512.ComputeHash(Encoding.UTF8.GetBytes(serializedBody));
                return BitConverter.ToString(hash).Replace("-", "").ToLower();
            }
        }
        public static string GetCacheKey(string _path, string reqtype, string username, string IP_RemoteDomain)
        {
            string cacheKey = $"post={_path.ToLower()}|reqtype:{reqtype.ToLower()}|user={username.ToLower()}|ipremotedomain={IP_RemoteDomain.ToLower()}|";
            return cacheKey;
        }
        public static void GetSetRequestLimitCacheValue(string CacheKey, ref int RetObject, IMemoryCache cache, int Seconds, bool issqlcachingenable)
        {
            RetObject += 1;
            MemoryCachesValues memoryCachesValues = new MemoryCachesValues();
            if (cache.TryGetValue(CacheKey, out MemoryCachesValues cachedResponse))
            {
                RetObject = (cachedResponse.value == null ? 0 : (int)cachedResponse.value + 1);
            }
            else
            {
                if (cache.TryGetValue(CacheKey + "result", out bool tempresult) == false)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(CacheKey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            RetObject = Convert.ToInt32(DR["Value"].ToString()) + 1;
                        }
                    }
                    cache.Set(CacheKey + "result", true, TimeSpan.FromDays(1));
                }
                else
                {
                    cache.Set(CacheKey + "result", true, TimeSpan.FromDays(1));
                }
            }
            DateTime? uTCDateTime = null;
            memoryCachesValues = SetMemoryCachesValues(CacheKey, RetObject, Seconds, cache, ref uTCDateTime, false);
            cache.Set(CacheKey, memoryCachesValues, memoryCachesValues.cacheEntryOptions);
            if (uTCDateTime != null && issqlcachingenable)
            {
                if (cache.TryGetValue(CacheKey + "datetime", out DateTime tempdatetime) == false)
                {
                    cache.Set(CacheKey + "datetime", uTCDateTime, TimeSpan.FromSeconds(300));
                    StaticPublicObjects.ado.P_CacheEntry_IU(CacheKey, memoryCachesValues.value.ToString(), uTCDateTime);
                }
            }
        }
        public static bool GetCacheValue(MemoryCacheValueType _MemoryCacheValueType, ref object? RetObject, IMemoryCache cache, bool iscachingenable)
        {
            bool result_code = false;
            RemoveCacheValue(_MemoryCacheValueType, cache);
            if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromcache)
            {
                if (cache.TryGetValue(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, out MemoryCachesValues cachedResponse))
                {
                    RetObject = cachedResponse.value;
                    result_code = true;
                }
                else if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromsqlcache)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            RetObject = DR["Value"];
                            SetCacheValue(_MemoryCacheValueType, RetObject, cache, iscachingenable);
                        }                    
                    }
                }
            }
            return result_code;
        }
        public static bool GetCacheValue(MemoryCacheValueType _MemoryCacheValueType, ref string RetObject, IMemoryCache cache,bool iscachingenable)
        {
            bool result_code = false;
            RemoveCacheValue(_MemoryCacheValueType, cache);
            if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromcache)
            {
                if (cache.TryGetValue(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, out MemoryCachesValues cachedResponse))
                {
                    RetObject = cachedResponse.value.ToString();
                    result_code = true;
                }
                else if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromsqlcache)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            RetObject = DR["Value"].ToString();
                            SetCacheValue(_MemoryCacheValueType, RetObject, cache, iscachingenable);
                        }
                    }
                }
            }
            return result_code;
        }
        public static bool GetCacheValue(MemoryCacheValueType _MemoryCacheValueType, ref DataRow? RetObject, IMemoryCache cache, bool iscachingenable)
        {
            bool result_code = false;
            RemoveCacheValue(_MemoryCacheValueType, cache);
            if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromcache)
            {
                if (cache.TryGetValue(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, out MemoryCachesValues cachedResponse))
                {
                    RetObject = (DataRow)cachedResponse.value;
                    result_code = true;
                }
                else if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromsqlcache)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            RetObject = null;
                            if (DR["Value"] != null)
                            {
                                RetObject = JsonConvert.DeserializeObject<DataRow>(DR["Value"].ToString());
                            }
                            SetCacheValue(_MemoryCacheValueType, RetObject, cache, iscachingenable);
                        }
                    }
                }
            }
            return result_code;
        }
        public static bool GetCacheValue(MemoryCacheValueType _MemoryCacheValueType, ref DataTable RetObject, IMemoryCache cache, bool iscachingenable)
        {
            bool result_code = false;
            RemoveCacheValue(_MemoryCacheValueType, cache);
            if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromcache)
            {
                if (cache.TryGetValue(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, out MemoryCachesValues cachedResponse))
                {
                    RetObject = (DataTable)cachedResponse.value;
                    result_code = true;
                }
                else if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromsqlcache)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            RetObject = new DataTable();
                            if (DR["Value"] != null)
                            {
                                if (DR["Value"].ToString() != "")
                                {
                                    RetObject = JsonConvert.DeserializeObject<DataTable>(DR["Value"].ToString());
                                }
                            }
                            SetCacheValue(_MemoryCacheValueType, RetObject, cache, iscachingenable);
                        }
                    }
                }
            }
            return result_code;
        }
        public static bool GetCacheValue(MemoryCacheValueType _MemoryCacheValueType, ref int RetObject, IMemoryCache cache, bool iscachingenable)
        {
            bool result_code = false;
            RemoveCacheValue(_MemoryCacheValueType, cache);
            if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromcache)
            {
                if (cache.TryGetValue(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, out MemoryCachesValues cachedResponse))
                {
                    RetObject = (int)cachedResponse.value;
                    result_code = true;
                }
                else if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromsqlcache)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            if (DR["Value"] != null)
                            {
                                if (DR["Value"].ToString() != "")
                                {
                                    if (Information.IsNumeric(DR["Value"]))
                                        RetObject = Convert.ToInt32(DR["Value"].ToString());
                                }
                            }
                            SetCacheValue(_MemoryCacheValueType, RetObject, cache, iscachingenable);
                        }
                    }
                }
            }
            return result_code;
        }
        public static bool GetCacheValue<T>(MemoryCacheValueType _MemoryCacheValueType, ref T RetObject, IMemoryCache cache, bool iscachingenable)
        {
            bool result_code = false;
            RemoveCacheValue(_MemoryCacheValueType, cache);
            if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromcache)
            {
                if (cache.TryGetValue(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, out MemoryCachesValues cachedResponse))
                {
                    if (cachedResponse.value == null)
                    {
                        //RetObject = null;
                    }
                    else
                        RetObject = (T)cachedResponse.value;
                    result_code = true;
                }
                else if (_MemoryCacheValueType._GetMemoryCacheValueType.isgetfromsqlcache)
                {
                    DataRow? DR = null;
                    DR = StaticPublicObjects.ado.P_Get_CacheEntry(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
                    if (DR != null)
                    {
                        if (Convert.ToDateTime(DR["ExpiredOn"].ToString()) > DateTime.UtcNow)
                        {
                            if (DR["Value"] != null)
                            {
                                if (DR["Value"].ToString() != "")
                                {
                                    RetObject = JsonConvert.DeserializeObject<T>(DR["Value"].ToString());
                                }
                            }
                            SetCacheValue(_MemoryCacheValueType, RetObject, cache, iscachingenable);
                        }
                    }
                }
            }
            return result_code;
        }
        public static void RemoveCacheValue(MemoryCacheValueType _MemoryCacheValueType, IMemoryCache cache)
        {
            if (_MemoryCacheValueType._SetMemoryCacheValueType.isremovecache)
                cache.Remove(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
            if (_MemoryCacheValueType._SetMemoryCacheValueType.isremovesqlcache)
                StaticPublicObjects.ado.P_CacheEntry_Delete(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey);
        }
        public static void SetCacheValue(MemoryCacheValueType _MemoryCacheValueType, object? RetObject, IMemoryCache cache, bool iscachingenable)
        {
            if (_MemoryCacheValueType._SetMemoryCacheValueType.issetcache && iscachingenable)
            {
                MemoryCachesValues memoryCachesValues = new MemoryCachesValues();
                DateTime? uTCDateTime = null;
                memoryCachesValues = SetMemoryCachesValues(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, RetObject, _MemoryCacheValueType._SetMemoryCacheValueType.cacheexpiryseconds, cache, ref uTCDateTime, false);
                cache.Set(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, memoryCachesValues, memoryCachesValues.cacheEntryOptions);

                if (uTCDateTime != null && _MemoryCacheValueType._SetMemoryCacheValueType.issetsqlcache)
                {
                    string memoryCachesValuesstring = JsonConvert.SerializeObject(memoryCachesValues);
                    StaticPublicObjects.ado.P_CacheEntry_IU(_MemoryCacheValueType._GetMemoryCacheValueType.cachekey, memoryCachesValuesstring, uTCDateTime);
                }
            }
        }
    }
}
