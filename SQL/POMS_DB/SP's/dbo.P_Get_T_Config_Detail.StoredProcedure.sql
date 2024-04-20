USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_T_Config_Detail]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_T_Config_Detail]
	-- Add the parameters for the stored procedure here
	@Config_Key nvarchar(50)
AS
BEGIN
	set @Config_Key = upper(@Config_Key)

	select Config_Key,Val_num,Val_Text,Val_Date,Start_DateTime,End_DateTime from [PPlus_DB].[dbo].[T_Config] with (nolock) where Config_Key = @Config_Key

END
GO
