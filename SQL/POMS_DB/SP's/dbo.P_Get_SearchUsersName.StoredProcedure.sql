USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SearchUsersName]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec P_Get_SearchUsersName 'iht'
CREATE PROCEDURE [dbo].[P_Get_SearchUsersName]
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT USER_ID, USERNAME
    FROM T_Users  with (nolock)
    WHERE  USERNAME LIKE '%' + @SearchTerm + '%';
END;
GO
