USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_AirPort_ID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @AirPort_ID int exec [POMS_DB].[dbo].[P_Generate_AirPort_ID] @Ret_AirPort_ID = @AirPort_ID out select @AirPort_ID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_AirPort_ID]
	@Ret_AirPort_ID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_AirPort_ID] (IsGenerate)
	values (1)
	select @Ret_AirPort_ID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_AirPort_ID] where AirPort_ID = @Ret_AirPort_ID
END

 
 
GO
