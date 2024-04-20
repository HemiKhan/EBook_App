using EBook_Data.Common;

namespace EBook_Services.AppSetupServices
{
    public interface IAppSetupService
    {
        Task<AccountSignInResDTO> SignIn(AccountSignInDTO signInDTO, GenrateTokenDelgate tokenGenrator, CancellationToken cancellationToken, bool IsPasswordRequired = true);
    }
}
