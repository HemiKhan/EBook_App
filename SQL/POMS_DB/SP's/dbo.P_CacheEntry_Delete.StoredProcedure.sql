USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_CacheEntry_Delete]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_CacheEntry_Delete]
    @cacheKey VARCHAR(800)
	,@applicationID int
AS
BEGIN
    
	if exists(select * from [dbo].[T_CacheEntries] with (nolock) where [Key] = @cacheKey and ApplicationID = @applicationID)
	begin
		Delete from [dbo].[T_CacheEntries] where [Key] = @cacheKey and ApplicationID = @applicationID
	end

END;
GO
