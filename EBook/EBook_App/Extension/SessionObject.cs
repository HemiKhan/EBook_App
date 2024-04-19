using Newtonsoft.Json;

public static class SessionExtensions
{
    public static void SetObject<T>(this ISession session, string key, T value)
    {
        session.SetString(key, JsonConvert.SerializeObject(value));
    }
    public static void SetStringValue(this ISession session, string key, string value)
    {
        session.SetString(key, value);
    }
    public static void SetBool(this ISession session, string key, bool value)
    {
        session.SetString(key, value.ToString());
    }
    public static void SetDateTime(this ISession session, string key, DateTime value)
    {
        session.SetString(key, value.ToString("yyyy-MM-dd HH:mm:ss.fffffff"));
    }
    public static void SetInt(this ISession session, string key, int value)
    {
        session.SetString(key, value.ToString());
    }
    public static T GetObject<T>(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? default : JsonConvert.DeserializeObject<T>(value);
    }
    public static string? GetStringValue(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value;
    }
    public static bool? GetBool(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? null : Convert.ToBoolean(value);
    }
    public static bool GetBoolNotNull(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? false : Convert.ToBoolean(value);
    }
    public static DateTime? GetDateTime(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? null : Convert.ToDateTime(value);
    }
    public static int? GetInt(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? null : Convert.ToInt32(value);
    }
    public static int GetIntNotNull(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? 0 : Convert.ToInt32(value);
    }
    public static string SetupSessionError(this ISession session, string ErrorPageName, string PreviousUrl, string PreviousName, Exception Exception)
    {
        string id = Guid.NewGuid().ToString().ToLower();
        SetStringValue(session, "ErrorPageName" + id, ErrorPageName);
        SetStringValue(session, "PreviousUrl" + id, PreviousUrl);
        SetStringValue(session, "PreviousName" + id, PreviousName);
        SetObject<Exception>(session, "Exception" + id, Exception);
        return id;
    }
}