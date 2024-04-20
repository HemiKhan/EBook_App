USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Users_Json]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select [dbo].[F_Get_Users_Json] ('IHTISHAMTETS')

CREATE FUNCTION [dbo].[F_Get_Users_Json]
(	
	 @UserName nvarchar(300)
	 
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json =  (SELECT
    USER_ID,
    u.USERNAME,
    u.UserType_MTV_CODE,
    --u.PasswordHash,
   -- u.PasswordSalt,
    u.D_ID,
	CONCAT(rm.ROLE_ID, '_', 
           CASE WHEN rm.IsGroupRoleID = 1 THEN 'true' ELSE 'false' END) AS R_ID,
    u.Designation,
    u.FirstName,
    u.MiddleName,
    u.LastName,
    u.Company,
    u.[Address],
    u.Address2,
    u.City,
    u.[State],
    u.ZipCode,
    u.Country,
    u.Email,
    u.Mobile,
    u.Phone,
    u.PhoneExt,
    u.SecurityQuestion_MTV_ID,
    --u.EncryptedAnswer,
    u.TIMEZONE_ID,
    u.IsApproved,
    u.BlockType_MTV_ID,
    u.IsAPIUser,
    u.IsActive,
	(
        SELECT
            uaa.UAA_ID,
            uaa.USERNAME,
            uaa.Application_MTV_ID,
            uaa.NAV_USERNAME,
            tmtv.name,
            uaa.IsActive
        FROM
            [POMS_DB].[dbo].[T_User_Application_Access] uaa WITH (NOLOCK)
        INNER JOIN
            [POMS_DB].[dbo].[T_Master_Type_Value] tmtv ON uaa.Application_MTV_ID = tmtv.MTV_ID
        WHERE
            tmtv.MT_ID = 148
            AND tmtv.IsActive = 1
            AND uaa.USERNAME = @UserName
            --AND uaa.IsActive = 1 
			for json path 
    ) AS ApplicationAccess 
    
FROM
    [POMS_DB].[dbo].[T_Users] u WITH (NOLOCK)
	Left Join   [POMS_DB].[dbo].[T_User_Role_Mapping] rm  WITH (NOLOCK) ON u.USERNAME = rm.USERNAME
    where u.UserName=@UserName
    
FOR JSON PATH)

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
