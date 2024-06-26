USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_OrderDetail_Manifest_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_OrderDetail_Manifest_By_OrderID] (3251155,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OrderDetail_Manifest_By_OrderID]
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
, [GUID_] nvarchar(36)
, [Manifest_ID] int
, [Status_ID] int
, [Status] nvarchar(50)
, [Type_ID] int
, [Type] nvarchar(50)
, [PerformedBy] nvarchar(150)
, [ManifestDate] date
, [AddedBy] nvarchar(150)
, [AddedOn] datetime
, [ModifiedBy] nvarchar(150)
, [ModifiedOn] datetime
, TotalRecords int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @PinnacleTotalRecords int = 0
	Declare @PPlusTotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147100,147101,147102,147103,147104,147105)
	begin
		select @PinnacleTotalRecords = (@PinnacleTotalRecords + count(distinct Manifest.[Entry No])) 
		from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSL with (nolock)
		inner join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] MGI with(nolock) ON MGI.[Item ID] = MSL.[ID]
		inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] MG with(nolock) on MGI.[Manifest Group ID] = MG.[ManifestGroupId]
		inner join [PinnacleProd].[dbo].[Metropolitan$Manifest] Manifest with(nolock) on MG.[ManifestId] = Manifest.[Entry No] AND Manifest.[Active Status] = 1
		where MSL.[Item Type] = 1 AND MSL.[Register Type] = 0 AND MGI.[Active Status] = 1 AND MG.[Active Status] = 1
		AND MSL.[Sales Order No] = @ORDER_NO AND Manifest.[Active Status] = 1

		select @PPlusTotalRecords = (@PPlusTotalRecords + count(distinct M.[MIN_ID])) 
		from [PPlus_DB].[dbo].[T_Manifest] M with (nolock) 
		inner join [PPlus_DB].[dbo].[T_Manifest_Stop] MS with (nolock) on MS.[MIN_ID] = M.[MIN_ID]
		inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order] MSO with (nolock) on MSO.[MS_ID]=MS.[MS_ID] 
		where MSO.Order_ID = @ORDER_ID

		set @TotalRecords = @PinnacleTotalRecords + @PPlusTotalRecords

		if @PinnacleTotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [GUID_] , [Manifest_ID] , [Status_ID] , [Status] , [Type_ID] , [Type] , [PerformedBy] , [ManifestDate] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			select distinct
			[OrderID] = @ORDER_ID
			,[GUID_] = ''
			,[Manifest_ID]=Manifest.[Entry No]
			,[Status_ID] = Manifest.[Status]
			,[Status]=(select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10120 and mtv.[ID] =Manifest.[Status])
			,[Type_ID]=(case when Manifest.[Type] = 10000 and Manifest.[Subtype] = 10000 then 10000
				when Manifest.[Type] = 10000 and Manifest.[Subtype] = 20000 then 20000
				when Manifest.[Type] = 10000 and Manifest.[Subtype] = 30000 then 30000
				when Manifest.[Type] = 20000 then 40000
				else 0 end)
			,[Type]=(case when Manifest.[Type] = 10000 and Manifest.[Subtype] = 10000 then 'Line Haul'
				when Manifest.[Type] = 10000 and Manifest.[Subtype] = 20000 then 'Return'
				when Manifest.[Type] = 10000 and Manifest.[Subtype] = 30000 then 'Liquation'
				when Manifest.[Type] = 20000 then 'Pinnacle Final Mile'
				else '' end)
			,[PerformedBy]=pfn.FullName
			,[ManifestDate]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (Manifest.[Manifest Date],@TimeZone_ID,null,@TimeZoneName)
			,[AddedBy]=afn.FullName
			,[AddedOn]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (Manifest.[Added Date],@TimeZone_ID,null,@TimeZoneName)
			,[ModifiedBy]=null
			,[ModifiedOn]=null
			,[TotalRecords]=@TotalRecords
			from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSL with (nolock)
			inner join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] MGI with(nolock) ON MGI.[Item ID] = MSL.[ID]
			inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] MG with(nolock) on MGI.[Manifest Group ID] = MG.[ManifestGroupId]
			inner join [PinnacleProd].[dbo].[Metropolitan$Manifest] Manifest with(nolock) on MG.[ManifestId] = Manifest.[Entry No] AND Manifest.[Active Status] = 1
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (Manifest.[Performed By]) pfn
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (Manifest.[Added By]) afn
			--outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (Manifest.[Added By]) mfn
			where MSL.[Item Type] = 1 AND MSL.[Register Type] = 0 AND MGI.[Active Status] = 1 AND MG.[Active Status] = 1
			AND MSL.[Sales Order No] = @ORDER_NO AND Manifest.[Active Status] = 1
		end

		if @PPlusTotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [GUID_] , [Manifest_ID] , [Status_ID] , [Status] , [Type_ID] , [Type] , [PerformedBy] , [ManifestDate] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			SELECT distinct
			[OrderID]=@ORDER_ID
			,[GUID_]=M.GUID_
			,[Manifest_ID]=M.[MIN_ID]
			,[Status_ID]=0
			,[Status]=''
			,[Type_ID]=(case when MSO.[Is_Pickup] = 0 then 50000 else 60000 end)
			,[Type]=(case when MSO.[Is_Pickup] = 0 then 'Final Mile' else 'Pickup' end)
			,[PerformedBy]=[POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (M.[DRIVER_ID])
			,[ManifestDate]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (M.[StartDate],@TimeZone_ID,null,@TimeZoneName)
			,[AddedBy]=afn.FullName
			,[AddedOn]=(case when Year(MS.[Enter_Date]) < 2000 or MS.[Enter_Date] is null then
				[POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (M.[StartDate],@TimeZone_ID,null,@TimeZoneName)
				else [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (MS.[Enter_Date],@TimeZone_ID,null,@TimeZoneName) end)
			,[ModifiedBy]=null
			,[ModifiedOn]=null
			,[TotalRecords]=@TotalRecords
			from [PPlus_DB].[dbo].[T_Manifest] M with (nolock) 
			inner join [PPlus_DB].[dbo].[T_Manifest_Stop] MS with (nolock) on MS.[MIN_ID] = M.[MIN_ID]
			inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order] MSO with (nolock) on MSO.[MS_ID]=MS.[MS_ID] 
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (MS.Enter_By) afn
			where MSO.Order_ID = @ORDER_ID
		end
	end
	
	return
	

end
GO
