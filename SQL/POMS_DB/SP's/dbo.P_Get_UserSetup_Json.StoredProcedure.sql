USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_UserSetup_Json]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--		exec [dbo].[P_Get_UserSetup_Json] 15065

CREATE PROCEDURE [dbo].[P_Get_UserSetup_Json]
	@UserID int
	 
AS
BEGIN
	
DECLARE @Json NVARCHAR(MAX) = ''
DECLARE @UserDetails NVARCHAR(MAX) = ''
DECLARE @UserSeller NVARCHAR(MAX) = ''
DECLARE @UserName NVARCHAR(300) = ''

SELECT @UserName = u.USERNAME
FROM [POMS_DB].[dbo].[T_Users] u WITH (NOLOCK)
WHERE u.USER_ID = @UserID

IF @UserName <> ''
BEGIN
    SELECT @UserDetails = [POMS_DB].[dbo].[F_Get_Users_Json] (@UserName)
    SELECT @UserSeller = [POMS_DB].[dbo].[F_Get_UserToSeller_Json] (@UserName)

    IF @UserSeller <> ''
    BEGIN
        SELECT @Json = (CONCAT('{"UserDetails":', @UserDetails, ',"UserSeller":', @UserSeller, '}'))
    END
    ELSE
    BEGIN
        SELECT @Json = (CONCAT('{"UserDetails":', @UserDetails, '}'))
    END
END

SELECT @Json AS [Json]  

END
GO
