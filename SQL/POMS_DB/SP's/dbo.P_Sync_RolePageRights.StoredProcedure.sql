USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_RolePageRights]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC [P_Sync_RolePageRights] 3,2,0,0,303,NULL,'HAMMAS.KHAN'
--							EXEC [P_Sync_RolePageRights] 3,2,0,0,303,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Sync_RolePageRights]
@RoleID INT,
@RoleIDCompare INT,
@CopyR_ID INT = 0,
@CopyPG_ID INT = 0,
@CopyP_ID INT = 0,
@Active BIT = 0,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	set @Active = isnull(@Active,0)

	IF EXISTS (SELECT top 1 1 FROM [POMS_DB].[dbo].[T_Roles] r with (nolock) where r.R_ID = @RoleIDCompare and r.IsActive = 1 and @RoleIDCompare <> 1)
	BEGIN

		IF (@CopyR_ID = @RoleIDCompare)
		BEGIN
			IF @CopyR_ID > 0
			BEGIN 				
				IF (@Active = 0)
				BEGIN
					DELETE FROM [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] 
					where R_ID = @RoleID
				END
		
				INSERT INTO [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] (R_ID, PR_ID, IsRightActive, IsActive, AddedBy)
				SELECT R_ID = @RoleID, PR_ID = rprm.PR_ID, rprm.IsRightActive, IsActive, AddedBy = @Username
				FROM [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID = @RoleIDCompare and rprm.IsActive = 1 and @RoleIDCompare <> 1 
				and rprm.RPRM_ID not in (select rprm1.RPRM_ID from [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm1 with (nolock) where R_ID = @RoleID)
				and ((rprm.IsRightActive = 1 and @Active = 1) or @Active = 0)
				order by rprm.RPRM_ID
		
				SET @Return_Text = 'Role Rights Synced Successfully!'
				SET @Return_Code = 1		
			END
		END
		ELSE IF (@CopyR_ID != @RoleIDCompare and @CopyR_ID > 0)
		BEGIN
			SET @Return_Text = 'Invalid Copy Role ID'
			SET @Return_Code = 0
		END
		ELSE IF @CopyPG_ID > 0
		BEGIN 
			IF (@Active = 0)
			BEGIN
				DELETE rprm 
				FROM [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm
				INNER JOIN [POMS_DB].[dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
				INNER JOIN [POMS_DB].[dbo].[T_Page] p on pr.P_ID = p.P_ID
				where rprm.R_ID = @RoleID and p.PG_ID = @CopyPG_ID
			END
		
			INSERT INTO [POMS_DB].[dbo].T_Role_Page_Rights_Mapping (R_ID, PR_ID, IsRightActive, IsActive, AddedBy)
			SELECT R_ID = @RoleID, PR_ID = rprm.PR_ID, rprm.IsRightActive, rprm.IsActive, AddedBy = @Username
			FROM [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) 
			INNER JOIN [POMS_DB].[dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
			INNER JOIN [POMS_DB].[dbo].[T_Page] p on pr.P_ID = p.P_ID
			where rprm.R_ID = @RoleIDCompare and rprm.IsActive = 1 and @RoleIDCompare <> 1 and p.PG_ID = @CopyPG_ID
			and rprm.RPRM_ID not in (select rprm1.RPRM_ID from [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm1 with (nolock) where R_ID = @RoleID)
			and ((rprm.IsRightActive = 1 and @Active = 1) or @Active = 0)
			order by rprm.RPRM_ID
		
			SET @Return_Text = 'Page Group Rights Synced Successfully!'
			SET @Return_Code = 1
		
		END
		ELSE IF @CopyP_ID > 0
		BEGIN 
			IF (@Active = 0)
			BEGIN
				DELETE rprm 
				FROM [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm
				INNER JOIN [POMS_DB].[dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
				where rprm.R_ID = @RoleID and pr.P_ID = @CopyP_ID
			END
		
			INSERT INTO [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] (R_ID, PR_ID, IsRightActive, IsActive, AddedBy)
			SELECT R_ID = @RoleID, PR_ID = rprm.PR_ID, rprm.IsRightActive, rprm.IsActive, AddedBy = @Username
			FROM [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) 
			INNER JOIN [POMS_DB].[dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
			where rprm.R_ID = @RoleIDCompare and rprm.IsActive = 1 and @RoleIDCompare <> 1 and pr.P_ID = @CopyP_ID
			and rprm.RPRM_ID not in (select rprm1.RPRM_ID from [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm1 with (nolock) where R_ID = @RoleID)
			and ((rprm.IsRightActive = 1 and @Active = 1) or @Active = 0)
			order by rprm.RPRM_ID
		
			SET @Return_Text = 'Page Rights Synced Successfully!'
			SET @Return_Code = 1
		
		END
		ELSE
		BEGIN
			SET @Return_Text = 'NOT Synced Successfully!'
			SET @Return_Code = 1	
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Invalid Compare Role ID'
		SET @Return_Code = 0
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
