USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_AccessLog_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_AccessLog_By_OrderID] (3251652,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_AccessLog_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([OrderID] int
, [UserType] nvarchar(20)
, [UserTypeName] nvarchar(50)
, [ViewedByUserName] nvarchar(150)
, [ViewedByFullName] nvarchar(250)
, [ViewedByDepartment] nvarchar(150)
, [ViewedOnDate] datetime
, [Source] nvarchar(50)
, [EndDate] datetime
, [TotalRecords] int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147103)
	begin
		select @TotalRecords = @TotalRecords + count(oal.[Sales Order]) from [PinnacleProd].[dbo].[Metropolitan$Order Access Log] oal with (nolock) where oal.[Sales Order] = @ORDER_NO
		insert into @ReturnTable ([OrderID] , [UserType] , [UserTypeName] , [ViewedByUserName] , [ViewedByFullName] , [ViewedByDepartment] , [ViewedOnDate] , [Source] , [EndDate] , [TotalRecords])
		SELECT [ORDER_ID] = @ORDER_ID 
			, [UserType]=(Case when [Client Type] = 1 then 'CLIENT-USER' when [Client Type] = 2 then 'METRO-USER' when [Client Type] = 3 then 'COD-USER' when [Client Type] = 4 then 'GUEST-USER' else '' end)
			, [UserTypeName]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] ((Case when [Client Type] = 1 then 'CLIENT-USER' when [Client Type] = 2 then 'METRO-USER' when [Client Type] = 3 then 'COD-USER' when [Client Type] = 4 then 'GUEST-USER' else '' end))
			, [ViewedByUserName] = oal.[Viewed By]
			, [ViewedByFullName] = gfadbu.FullName
			, [ViewedByDepartment] = gfadbu.DeptName
			, [ViewedOnDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oal.[Viewed On],@TimeZone_ID,null,@TimeZoneName)
			, [Source] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10070 and mtv.ID = oal.[Source]), '')
			, [EndDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oal.[EndDate],@TimeZone_ID,null,@TimeZoneName)
			, TotalRecords = @TotalRecords

		from [PinnacleProd].[dbo].[Metropolitan$Order Access Log] oal with (nolock)
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oal.[Viewed By]) gfadbu
		where oal.[Sales Order] = @ORDER_NO
	end
	else if @GetRecordType_MTV_ID in (147104,147105)
	begin
		if @GetRecordType_MTV_ID in (147104)
		begin
			select @TotalRecords = @TotalRecords + count(oal.[Sales Order]) from [PinnacleProd].[dbo].[Metropolitan$Order Access Log] oal with (nolock) where oal.[Sales Order] = @ORDER_NO
			insert into @ReturnTable ([OrderID] , [UserType] , [UserTypeName] , [ViewedByUserName] , [ViewedByFullName] , [ViewedByDepartment] , [ViewedOnDate] , [Source] , [EndDate] , [TotalRecords])
			SELECT [ORDER_ID] = @ORDER_ID 
				, [UserType]=(Case when [Client Type] = 1 then 'CLIENT-USER' when [Client Type] = 2 then 'METRO-USER' when [Client Type] = 3 then 'COD-USER' when [Client Type] = 4 then 'GUEST-USER' else '' end)
				, [UserTypeName]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] ((Case when [Client Type] = 1 then 'CLIENT-USER' when [Client Type] = 2 then 'METRO-USER' when [Client Type] = 3 then 'COD-USER' when [Client Type] = 4 then 'GUEST-USER' else '' end))
				, [ViewedByUserName] = oal.[Viewed By]
				, [ViewedByFullName] = gfadbu.FullName
				, [ViewedByDepartment] = gfadbu.DeptName
				, [ViewedOnDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oal.[Viewed On],@TimeZone_ID,null,@TimeZoneName)
				, [Source] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10070 and mtv.ID = oal.[Source]), '')
				, [EndDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oal.[EndDate],@TimeZone_ID,null,@TimeZoneName)
				, TotalRecords = @TotalRecords

			from [PinnacleProd].[dbo].[Metropolitan$Order Access Log] oal with (nolock)
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oal.[Viewed By]) gfadbu
			where oal.[Sales Order] = @ORDER_NO
		end

		select @TotalRecords = @TotalRecords + count(oal.[Sales Order]) from [PinnacleArchiveDB].[dbo].[Metropolitan$Order Access Log] oal with (nolock) where oal.[Sales Order] = @ORDER_NO
		insert into @ReturnTable ([OrderID] , [UserType] , [UserTypeName] , [ViewedByUserName] , [ViewedByFullName] , [ViewedByDepartment] , [ViewedOnDate] , [Source] , [EndDate] , [TotalRecords])
		SELECT [ORDER_ID] = @ORDER_ID 
			, [UserType]=(Case when [Client Type] = 1 then 'CLIENT-USER' when [Client Type] = 2 then 'METRO-USER' when [Client Type] = 3 then 'COD-USER' when [Client Type] = 4 then 'GUEST-USER' else '' end)
			, [UserTypeName]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] ((Case when [Client Type] = 1 then 'CLIENT-USER' when [Client Type] = 2 then 'METRO-USER' when [Client Type] = 3 then 'COD-USER' when [Client Type] = 4 then 'GUEST-USER' else '' end))
			, [ViewedByUserName] = oal.[Viewed By]
			, [ViewedByFullName] = gfadbu.FullName
			, [ViewedByDepartment] = gfadbu.DeptName
			, [ViewedOnDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oal.[Viewed On],@TimeZone_ID,null,@TimeZoneName)
			, [Source] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10070 and mtv.ID = oal.[Source]), '')
			, [EndDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oal.[EndDate],@TimeZone_ID,null,@TimeZoneName)
			, TotalRecords = @TotalRecords

		from [PinnacleArchiveDB].[dbo].[Metropolitan$Order Access Log] oal with (nolock)
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oal.[Viewed By]) gfadbu
		where oal.[Sales Order] = @ORDER_NO
	end

	return
	

end
GO
