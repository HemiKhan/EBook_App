USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Chat_Dropdown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--			[P_Get_Chat_Dropdown_Lists] 'HAMMAS.KHAN'
CREATE PROCEDURE [dbo].[P_Get_Chat_Dropdown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = [Name] FROM [dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = 181 AND IsActive = 1 AND Name <> 'Public' ORDER BY Sort_
	
	SELECT code = USERNAME, name = CONCAT(FirstName,' ',LastName) FROM [dbo].[T_Users] WITH (NOLOCK) 
	WHERE USERNAME IN ('ABDULLAH.ARSHAD','HAMMAS.KHAN','BABAR.ALI','TAIMOOR.ALI','SAAD.QADIR','TOUSEEF.AHMAD','IHTISHAM.ULHAQ','MUSA.RAZA')
	AND USERNAME NOT IN (SELECT DISTINCT UserName FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK) 
	INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK) ON cr.CR_ID = crum.CR_ID
	WHERE cr.AddedBy = @Username AND UserName <> 'All')
	
	SELECT code = USERNAME, name = CONCAT(FirstName,' ',LastName) FROM [dbo].[T_Users] WITH (NOLOCK) WHERE USERNAME IN ('ABDULLAH.ARSHAD','HAMMAS.KHAN','BABAR.ALI','TAIMOOR.ALI','SAAD.QADIR','TOUSEEF.AHMAD','IHTISHAM.ULHAQ','MUSA.RAZA') AND USERNAME <> @Username
END

 
GO
