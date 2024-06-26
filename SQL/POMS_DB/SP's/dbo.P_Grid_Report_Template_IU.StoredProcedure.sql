USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Grid_Report_Template_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Grid_Report_Template_IU]
	@GRL_ID int
	,@UGRTL_ID int
	,@Name nvarchar(250)
	,@Username nvarchar(150)
	,@AddedBy nvarchar(150)
	,@Json nvarchar(max)
AS
BEGIN
	
	Declare @ReturnCode bit = 0
	Declare @ReturnText nvarchar(250) = ''
	Declare @GUID nvarchar(36) = ''
	set @Username = upper(@Username)
	set @AddedBy = upper(@AddedBy)
	
	if not exists(Select GRL_ID from [POMS_DB].[dbo].[T_Grid_Reports_List] rl with (nolock) where rl.GRL_ID = @GRL_ID and rl.IsActive = 1)
	begin
		set @ReturnText = 'Invalid Grid Report ID'
		select @ReturnCode as ReturnCode ,@ReturnText as ReturnText ,@GUID as GUID_
		return
	end

	Declare @ColumnsRecord table 
	(GRC_ID int
	,[SortPosition] int)

	insert into @ColumnsRecord (GRC_ID, [SortPosition])
	select GRC_ID, [SortPosition] from [POMS_DB].[dbo].[F_Get_Grid_Report_Template_Column] (@Json) where GRC_ID is not null and [SortPosition] is not null

	if not exists(select * from @ColumnsRecord)
	begin
		set @ReturnText = 'Column List is Required'
		select @ReturnCode as ReturnCode ,@ReturnText as ReturnText ,@GUID as GUID_
		return
	end

	if @UGRTL_ID > 0 and not exists(select UGRTL_ID from [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] with (nolock) where IsActive = 1 and UGRTL_ID = @UGRTL_ID)
	begin
		set @ReturnText = 'Invalid Grid Report Template ID'
		select @ReturnCode as ReturnCode ,@ReturnText as ReturnText ,@GUID as GUID_
		return
	end

	if (@UGRTL_ID = 0)
	begin
		if exists(select GRL_ID from [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] with (nolock) where GRL_ID = @GRL_ID and [Name] = @Name and USERNAME = @Username)
		begin
			set @ReturnCode = 0
			set @ReturnText = 'Report Template Name Already Exists'
		end
		else
		begin
			set @GUID = lower(newid())
			insert into [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] (GRL_ID, USERNAME, GUID_, [Name], AddedBy)
			values (@GRL_ID, @Username, @GUID, @Name, @AddedBy)
			set @UGRTL_ID = SCOPE_IDENTITY()

			insert into [POMS_DB].[dbo].[T_User_Grid_Report_Columns] (USERNAME,UGRTL_ID,GRC_ID,IsHidden,IsChecked,SortPosition,AddedBy)
			select @Username,@UGRTL_ID,rc.GRC_ID,rc.IsHidden,rc.IsChecked,cr.SortPosition,@AddedBy 
			from [POMS_DB].[dbo].[T_Grid_Report_Columns] rc with (nolock) 
			inner join @ColumnsRecord cr on rc.GRC_ID = cr.GRC_ID where rc.GRL_ID = @GRL_ID
			order by cr.SortPosition

			set @ReturnCode = 1
			set @ReturnText = 'Inserted'
		end
	end
	else
	begin
		select @GUID = GUID_ from [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] with (nolock) where UGRTL_ID = @UGRTL_ID
		if @GUID is not null
		begin
			Update [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] set [Name] = @Name, ModifiedBy = @AddedBy, ModifiedOn = getutcdate() where UGRTL_ID = @UGRTL_ID
		end
		set @GUID = isnull(@GUID,'')

		Delete [POMS_DB].[dbo].[T_User_Grid_Report_Columns] where UGRTL_ID = @UGRTL_ID

		insert into [POMS_DB].[dbo].[T_User_Grid_Report_Columns] (USERNAME,UGRTL_ID,GRC_ID,IsHidden,IsChecked,SortPosition,AddedBy)
		select @Username,@UGRTL_ID,rc.GRC_ID,rc.IsHidden,IsChecked=1,cr.SortPosition,@AddedBy 
		from [POMS_DB].[dbo].[T_Grid_Report_Columns] rc with (nolock) 
		inner join @ColumnsRecord cr on rc.GRC_ID = cr.GRC_ID where rc.GRL_ID = @GRL_ID
		order by cr.SortPosition

		set @ReturnCode = 1
		set @ReturnText = 'Updated'
	end

	select @ReturnCode as ReturnCode ,@ReturnText as ReturnText ,@GUID as GUID_
	
END
GO
