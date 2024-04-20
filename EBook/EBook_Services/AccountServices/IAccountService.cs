using Azure;
using EBook_Data.Dtos;

namespace EBook_Services.AccountServices
{
    public interface IAccountService
    {
        Task<SignIn_Res> LoginAsync(SignIn_Req req, GenrateTokenDelgate tokenGenrator, CancellationToken cancellationToken, bool IsPasswordRequired = true);
        string GenerateToken(P_Get_User_Info userInfo, string Encrypted_Key);
    }
}
