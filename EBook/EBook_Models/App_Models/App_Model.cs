namespace EBook_Models.App_Models
{   
    public partial class TUser
    {
        public string? Username { get; set; } = null!;
        public string? Token { get; set; }
        public DateTime? TokenCreatedOn { get; set; }
        public DateTime? TokenExpiry { get; set; }
        public DateTime? TokenRevokedOn { get; set; }
        public string? Otp { get; set; }
        public DateTime? OtpExpiry { get; set; }
        public int? OtpStatus { get; set; }
    }

    public class UpdateAttachmentPath
    {
        public int TA_ID { get; set; }
        public string Path { get; set; }
        public int TD_ID { get; set; }

    }
}
