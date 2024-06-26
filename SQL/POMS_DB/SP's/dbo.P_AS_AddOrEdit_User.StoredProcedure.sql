USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AS_AddOrEdit_User]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC [P_AS_AddOrEdit_User] NULL,'Test','Test','','ABC','test@test.com',1,'POMS'
CREATE PROC [dbo].[P_AS_AddOrEdit_User]
@UID INT = NULL,
@Company nvarchar(250),
@FirstName nvarchar(50),
@LastName nvarchar(50) = NULL,
@Address nvarchar(250) = NULL,
@Email nvarchar(250) = NULL,
@Active BIT = 1,
@Username nvarchar(150)
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

  IF @UID > 0 
    BEGIN
        IF EXISTS (SELECT 1 FROM [dbo].[T_AS_User] with (nolock) WHERE [UID] = @UID)
        BEGIN
            
            UPDATE [POMS_DB].dbo.T_AS_User 
            SET Company = @Company, 
                FirstName = @FirstName, 
                LastName = @LastName, 
                [Address] = @Address, 
                Email = @Email, 
                IsActive = @Active, 
                ModifiedBy = @Username, 
                ModifiedOn = GETUTCDATE() 
            WHERE [UID] = @UID

            SET @Return_Text = 'User Updated Successfully!'
            SET @Return_Code = 1

        END
        ELSE
        BEGIN
            SET @Return_Text = 'User does not exist!'
            SET @Return_Code = 0
        END
    END

    ELSE BEGIN
        IF @Company <> '' AND @FirstName <> '' BEGIN
            SELECT @UID = ISNULL(MAX(UID),0) + 1 FROM [POMS_DB].[dbo].[T_AS_User] WITH (NOLOCK) 
            INSERT INTO [POMS_DB].[dbo].[T_AS_User] (UID, Company, FirstName, LastName, Address, Email, IsActive, AddedBy, AddedOn) 
            VALUES (@UID, @Company, @FirstName, @LastName, @Address, @Email, @Active, @Username, GETUTCDATE())
            SET @Return_Text = 'User Added Successfully!'
            set @Return_Code = 1
        END
        ELSE BEGIN
            SET @Return_Text = 'User details incomplete!'
            set @Return_Code = 0
        END
    END

    SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
