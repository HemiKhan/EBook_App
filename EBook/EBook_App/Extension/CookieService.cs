namespace EBook_App.Extension
{
    public static class CookieService
    {
        // Get cookie value by name
        public static string? GetCookie(this IRequestCookieCollection _httpContextAccessor, string key)
        {
            _httpContextAccessor.TryGetValue(key, out string? value);
            return value;
        }
        public static void SetCookie(this IResponseCookies _httpContextAccessor, string key, string value, CookieOptions? options = null)
        {
            if (options == null)
            {
                options = new CookieOptions { HttpOnly = true, Expires = DateTime.UtcNow.AddDays(1) };
            }
            _httpContextAccessor.Append(key, value, options);
        }
        // Set cookie value with options
    }
}
