USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Grid_Report_Template_Delete]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Grid_Report_Template_Delete]
	@UGRCGUID nvarchar(36)
	,@Username nvarchar(150)
	,@AddedBy nvarchar(150)
AS
BEGIN
	
	Declare @ReturnCode bit  = 0
	Declare @ReturnText nvarchar(250) = ''

	Declare @UGRTL_ID int = 0
	select @UGRTL_ID = UGRTL_ID from [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] with (nolock) where GUID_ = @UGRCGUID and USERNAME = @Username
	set @UGRTL_ID = isnull(@UGRTL_ID,0)

	if @UGRTL_ID <> 0
	begin
		delete from [POMS_DB].[dbo].[T_User_Grid_Report_Columns] where UGRTL_ID = @UGRTL_ID
		delete from [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] where UGRTL_ID = @UGRTL_ID

		set @ReturnCode = 1
		set @ReturnText = 'Deleted'
	end
	else
	begin
		set @ReturnCode = 0
		set @ReturnText = 'Invalid ID'
	end

	select @ReturnCode as ReturnCode ,@ReturnText as ReturnText 
	
END
GO
