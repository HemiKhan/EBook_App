USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_UserDetials_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[F_Get_T_UserDetials_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    [USER_ID] int
    ,USERNAME NVARCHAR(50)
	,UserType_MTV_CODE NVARCHAR(20)
	,PasswordHash NVARCHAR(250)
	,PasswordSalt NVARCHAR(250)
	,D_ID int
	,ROLE_ID int
	,IsGroupRoleID bit
	,Designation nvarchar(150)
	,FirstName nvarchar(50)
	,MiddleName nvarchar(50)
	,LastName nvarchar(50)
	,Company nvarchar(250)
	,[Address] nvarchar(250)
	,Address2 nvarchar(250)
	,[City] nvarchar(50)
	,[State] nvarchar(5)
	,[ZipCode] nvarchar(10)
	,Country nvarchar(50)
	,Email nvarchar(250)
	,Mobile nvarchar(30)
	,Phone nvarchar(40)
	,PhoneExt nvarchar(20)
	,SecurityQuestion_MTV_ID int
	,EncryptedAnswer nvarchar(250)
	,TIMEZONE_ID int
	,IsApproved bit
	,BlockType_MTV_ID int
	,IsAPIUser bit
	,IsActive bit
	,UserApplicationJson nvarchar(max)
)
AS
BEGIN
    SET @Json = ISNULL(@Json, '')

    IF @Json = ''
    BEGIN
        RETURN
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
            RETURN
        END
    END
    
    INSERT INTO @ReturnTable ([USER_ID] ,USERNAME ,UserType_MTV_CODE ,PasswordHash ,PasswordSalt ,D_ID ,ROLE_ID ,IsGroupRoleID ,Designation ,FirstName ,MiddleName ,LastName ,Company ,[Address] ,Address2 
		,[City] ,[State] ,[ZipCode] ,Country ,Email ,Mobile ,Phone ,PhoneExt ,SecurityQuestion_MTV_ID ,EncryptedAnswer ,TIMEZONE_ID ,IsApproved ,BlockType_MTV_ID ,IsAPIUser ,IsActive ,UserApplicationJson)
    SELECT 
        UserID
        ,UserName=upper(UserName)
		,UserType_MTV_CODE
        ,PasswordHash 
        ,PasswordSalt 
		,D_ID 
		,ROLE_ID 
        ,IsGroupRoleID 
		,Designation 
        ,FirstName 
		,MiddleName 
        ,LastName 
        ,company 
        ,address1 
        ,address2 
        ,city 
        ,[state] 
        ,zipCode 
        ,country 
        ,[email] 
        ,mobile 
        ,phone 
        ,phoneExt 
        ,SecurityQuestion_MTV_ID 
        ,EncryptedAnswer 
		,timeZoneID 
        ,isApproved 
        ,blockType 
        ,isAPIUser 
		,isActive
		,UserApplicationJson
    FROM OPENJSON(@Json)
    WITH (
        UserID int '$.USER_ID',
        UserName NVARCHAR(50) '$.USERNAME',
		UserType_MTV_CODE nvarchar(20) '$.UserType_MTV_CODE',
        PasswordHash NVARCHAR(50) '$.PasswordHash',
        PasswordSalt NVARCHAR(50) '$.PasswordSalt',
		D_ID int '$.D_ID',
		ROLE_ID int '$.R_ID',
        IsGroupRoleID bit '$.IsGroupRoleID',
		Designation nvarchar(150) '$.Designation',
        FirstName NVARCHAR(50) '$.FirstName',
		MiddleName NVARCHAR(50) '$.MiddleName',
        LastName NVARCHAR(50) '$.LastName',
        company NVARCHAR(250) '$.Company',
        address1 NVARCHAR(250) '$.Address',
        address2 NVARCHAR(250) '$.Address2',
        city NVARCHAR(50) '$.City',
        [state] NVARCHAR(5) '$.State',
        zipCode NVARCHAR(10) '$.ZipCode',
        country NVARCHAR(50) '$.Country',
        [email] NVARCHAR(250) '$.Email',
        mobile NVARCHAR(30) '$.Mobile',
        phone NVARCHAR(40) '$.Phone',
        phoneExt NVARCHAR(20) '$.PhoneExt',
        SecurityQuestion_MTV_ID int '$.SecurityQuestion_MTV_ID',
        EncryptedAnswer NVARCHAR(250) '$.EncryptedAnswer',
		timeZoneID int '$.TIMEZONE_ID',
        isApproved BIT '$.IsApproved',
        blockType int '$.BlockType_MTV_ID',
        isAPIUser BIT '$.IsAPIUser',
		isActive BIT '$.IsActive',
		UserApplicationJson nvarchar(max) '$.ApplicationAccess' as json
    );

    RETURN;
END
GO
