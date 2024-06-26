USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_ChangeLog_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_ChangeLog_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_ChangeLog_By_OrderID]
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
, [AuditType_MTV_ID] int
, [AuditType_Name] nvarchar(50)
, [RefNo1] nvarchar(50)
, [RefNo2] nvarchar(50)
, [RefNo3] nvarchar(50)
, [OAH_ID] int
, [ColumnName] nvarchar(100)
, [IsPublic] bit
, [Reason] nvarchar(1000)
, [OldValue] nvarchar(150)
, [NewValue] nvarchar(250)
, [IsAuto] bit
, [Source_MTV_ID] int
, [Source_Name] nvarchar(50)
, [ChangedBy] nvarchar(150)
, [ChangedOn] datetime
, TotalRecords int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147103,147105)
	begin
		select @TotalRecords = (@TotalRecords + count(ah.ID)) from [PinnacleProd].[dbo].[Metropolitan$Audit History] ah with (nolock)
		inner join [PinnacleProd].[dbo].[Metropolitan$Audit Column] ac with (nolock) on ah.[Column ID] = ac.[Column ID]
		Where ah.[Order ID]= @ORDER_NO and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [AuditType_MTV_ID] , [AuditType_Name] , [RefNo1] , [RefNo2] , [RefNo3] , [OAH_ID] , [ColumnName] , [IsPublic] , [Reason] , [OldValue] , [NewValue] 
				, [IsAuto] , [Source_MTV_ID] , [Source_Name] , [ChangedBy] , [ChangedOn] , TotalRecords)
			select OrderID ,[AuditType_MTV_ID] ,[AuditType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[AuditType_MTV_ID])
			,[RefNo1] ,[RefNo2] ,[RefNo3] ,[OAH_ID] ,[ColumnName] ,[IsPublic] ,[Reason] 
			,[OldValue] ,[NewValue] ,[IsAuto] ,[Source_MTV_ID] ,[Source_Name] ,[ChangedBy] ,[ChangedOn] ,TotalRecords 
			from (
				select OrderID = @ORDER_ID
					,[AuditType_MTV_ID] = (case ac.[Table Name] when 'Comments' then 108103
						when 'Metro_InvoiceOrderMap' then 108110
						when 'Metro_OrderData' then 108100
						when 'Metropolitan$Comments' then 108103
						--when 'Metropolitan$Delivery Attempt' then 0
						when 'Metropolitan$Image' then 108102
						when 'Metropolitan$Proof of Delivery' then 108102
						when 'Metropolitan$RelatedTicketMap' then 108111
						when 'Metropolitan$Sales Comment Line' then 108106
						when 'Metropolitan$Sales Estimate Header' then 108108
						when 'Metropolitan$Sales Estimate Line' then 108109
						when 'Metropolitan$Sales Header' then 108100
						when 'Metropolitan$Sales Line' then 0
						when 'Metropolitan$Sales Line Link' then 108101
						when 'Metropolitan$Sales Linkup' then 108100
						--when 'Metropolitan$TR Routes' then 0
						when 'Metropolitan$TR Warehouse Hub' then 108100
						when 'NAV_Metropolitan$Sales Header' then 108108
						when 'NAV_Metropolitan$Sales Line' then 108109
						else 0 end)
					,[RefNo1] = ah.[Ref No]
					,[RefNo2] = ''
					,[RefNo3] = ''
					,[OAH_ID] = ah.ID
					,[ColumnName] = ac.DisplayName
					,[IsPublic] = ac.IsPublic
					,[Reason] = ah.[Update Reason]
					,[OldValue] = (case 
						when ac.[Column Name] = 'Order Status' and ISNUMERIC(ah.[Old Value]) = 1
							then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.ID = ah.[Old Value]), '')
						when (ac.[Column Name]='Requested Pickup Date' or ac.[Column Name]='Requested Delivery Date') and charindex(' ',( ah.[Old Value])) > 0 --SoNu
							then  substring(( ah.[Old Value]), 1, charindex(' ',( ah.[Old Value])))
						else ah.[Old Value] end)
					,[NewValue] = (case 
						when ac.[Column Name] = 'Order Status' and ISNUMERIC(ah.[New Value]) = 1
							then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.ID = ah.[New Value]), '')
						when (ac.[Column Name]='Requested Pickup Date' or ac.[Column Name]='Requested Delivery Date') and charindex(' ',( ah.[Old Value])) > 0 --SoNu
							then  substring(( ah.[New Value]), 1, charindex(' ',(ah.[New Value])))
						else ah.[New Value] end)
					,[IsAuto] = 0
					,[Source_MTV_ID] = 0
					,[Source_Name] = null
					,[ChangedBy] = cfn.FullName
					,[ChangedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ah.[Date],@TimeZone_ID,null,@TimeZoneName)
					,TotalRecords = @TotalRecords
				from [PinnacleProd].[dbo].[Metropolitan$Audit History] ah with (nolock)
				inner join [PinnacleProd].[dbo].[Metropolitan$Audit Column] ac with (nolock) on ah.[Column ID] = ac.[Column ID]
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ah.[Added by]) cfn
				Where ah.[Order ID]= @ORDER_NO and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)
			) ilv
		end

		if @GetRecordType_MTV_ID in (147105)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(ah.ID)) from [PinnacleArchiveDB].[dbo].[Metropolitan$Audit History] ah with (nolock)
			inner join [PinnacleProd].[dbo].[Metropolitan$Audit Column] ac with (nolock) on ah.[Column ID] = ac.[Column ID]
			Where ah.[Order ID]= @ORDER_NO and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable ([OrderID] , [AuditType_MTV_ID] , [AuditType_Name] , [RefNo1] , [RefNo2] , [RefNo3] , [OAH_ID] , [ColumnName] , [IsPublic] , [Reason] , [OldValue] , [NewValue] 
					, [IsAuto] , [Source_MTV_ID] , [Source_Name] , [ChangedBy] , [ChangedOn] , TotalRecords)
				select OrderID ,[AuditType_MTV_ID] ,[AuditType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[AuditType_MTV_ID])
				,[RefNo1] ,[RefNo2] ,[RefNo3] ,[OAH_ID] ,[ColumnName] ,[IsPublic] ,[Reason] 
				,[OldValue] ,[NewValue] ,[IsAuto] ,[Source_MTV_ID] ,[Source_Name] ,[ChangedBy] ,[ChangedOn] ,TotalRecords 
				from (
					select OrderID = @ORDER_ID
						,[AuditType_MTV_ID] = (case ac.[Table Name] when 'Comments' then 108103
							when 'Metro_InvoiceOrderMap' then 108110
							when 'Metro_OrderData' then 108100
							when 'Metropolitan$Comments' then 108103
							--when 'Metropolitan$Delivery Attempt' then 0
							when 'Metropolitan$Image' then 108102
							when 'Metropolitan$Proof of Delivery' then 108102
							when 'Metropolitan$RelatedTicketMap' then 108111
							when 'Metropolitan$Sales Comment Line' then 108106
							when 'Metropolitan$Sales Estimate Header' then 108108
							when 'Metropolitan$Sales Estimate Line' then 108109
							when 'Metropolitan$Sales Header' then 108100
							when 'Metropolitan$Sales Line' then 0
							when 'Metropolitan$Sales Line Link' then 108101
							when 'Metropolitan$Sales Linkup' then 108100
							--when 'Metropolitan$TR Routes' then 0
							when 'Metropolitan$TR Warehouse Hub' then 108100
							when 'NAV_Metropolitan$Sales Header' then 108108
							when 'NAV_Metropolitan$Sales Line' then 108109
							else 0 end)
						,[RefNo1] = ah.[Ref No]
						,[RefNo2] = ''
						,[RefNo3] = ''
						,[OAH_ID] = ah.ID
						,[ColumnName] = ac.DisplayName
						,[IsPublic] = ac.IsPublic
						,[Reason] = ah.[Update Reason]
						,[OldValue] = (case 
							when ac.[Column Name] = 'Order Status' and ISNUMERIC(ah.[Old Value]) = 1
								then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.ID = ah.[Old Value]), '')
							when (ac.[Column Name]='Requested Pickup Date' or ac.[Column Name]='Requested Delivery Date') and charindex(' ',( ah.[Old Value])) > 0 --SoNu
								then  substring(( ah.[Old Value]), 1, charindex(' ',( ah.[Old Value])))
							else ah.[Old Value] end)
						,[NewValue] = (case 
							when ac.[Column Name] = 'Order Status' and ISNUMERIC(ah.[New Value]) = 1
								then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.ID = ah.[New Value]), '')
							when (ac.[Column Name]='Requested Pickup Date' or ac.[Column Name]='Requested Delivery Date') and charindex(' ',( ah.[Old Value])) > 0 --SoNu
								then  substring(( ah.[New Value]), 1, charindex(' ',(ah.[New Value])))
							else ah.[New Value] end)
						,[IsAuto] = 0
						,[Source_MTV_ID] = 0
						,[Source_Name] = null
						,[ChangedBy] = cfn.FullName
						,[ChangedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ah.[Date],@TimeZone_ID,null,@TimeZoneName)
						,TotalRecords = @TotalRecords
					from [PinnacleArchiveDB].[dbo].[Metropolitan$Audit History] ah with (nolock)
					inner join [PinnacleProd].[dbo].[Metropolitan$Audit Column] ac with (nolock) on ah.[Column ID] = ac.[Column ID]
					outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ah.[Added by]) cfn
					Where ah.[Order ID]= @ORDER_NO and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)
				) ilv
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147104)
	begin
		select @TotalRecords = (@TotalRecords + count(ah.ID)) from [PinnacleArchiveDB].[dbo].[Metropolitan$Audit History] ah with (nolock)
		inner join [PinnacleProd].[dbo].[Metropolitan$Audit Column] ac with (nolock) on ah.[Column ID] = ac.[Column ID]
		Where ah.[Order ID]= @ORDER_NO and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [AuditType_MTV_ID] , [AuditType_Name] , [RefNo1] , [RefNo2] , [RefNo3] , [OAH_ID] , [ColumnName] , [IsPublic] , [Reason] , [OldValue] , [NewValue] 
				, [IsAuto] , [Source_MTV_ID] , [Source_Name] , [ChangedBy] , [ChangedOn] , TotalRecords)
			select OrderID ,[AuditType_MTV_ID] ,[AuditType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[AuditType_MTV_ID])
			,[RefNo1] ,[RefNo2] ,[RefNo3] ,[OAH_ID] ,[ColumnName] ,[IsPublic] ,[Reason] 
			,[OldValue] ,[NewValue] ,[IsAuto] ,[Source_MTV_ID] ,[Source_Name] ,[ChangedBy] ,[ChangedOn] ,TotalRecords 
			from (
				select OrderID = @ORDER_ID
					,[AuditType_MTV_ID] = (case ac.[Table Name] when 'Comments' then 108103
						when 'Metro_InvoiceOrderMap' then 108110
						when 'Metro_OrderData' then 108100
						when 'Metropolitan$Comments' then 108103
						--when 'Metropolitan$Delivery Attempt' then 0
						when 'Metropolitan$Image' then 108102
						when 'Metropolitan$Proof of Delivery' then 108102
						when 'Metropolitan$RelatedTicketMap' then 108111
						when 'Metropolitan$Sales Comment Line' then 108106
						when 'Metropolitan$Sales Estimate Header' then 108108
						when 'Metropolitan$Sales Estimate Line' then 108109
						when 'Metropolitan$Sales Header' then 108100
						when 'Metropolitan$Sales Line' then 0
						when 'Metropolitan$Sales Line Link' then 108101
						when 'Metropolitan$Sales Linkup' then 108100
						--when 'Metropolitan$TR Routes' then 0
						when 'Metropolitan$TR Warehouse Hub' then 108100
						when 'NAV_Metropolitan$Sales Header' then 108108
						when 'NAV_Metropolitan$Sales Line' then 108109
						else 0 end)
					,[RefNo1] = ah.[Ref No]
					,[RefNo2] = ''
					,[RefNo3] = ''
					,[OAH_ID] = ah.ID
					,[ColumnName] = ac.DisplayName
					,[IsPublic] = ac.IsPublic
					,[Reason] = ah.[Update Reason]
					,[OldValue] = (case 
						when ac.[Column Name] = 'Order Status' and ISNUMERIC(ah.[Old Value]) = 1
							then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.ID = ah.[Old Value]), '')
						when (ac.[Column Name]='Requested Pickup Date' or ac.[Column Name]='Requested Delivery Date') and charindex(' ',( ah.[Old Value])) > 0 --SoNu
							then  substring(( ah.[Old Value]), 1, charindex(' ',( ah.[Old Value])))
						else ah.[Old Value] end)
					,[NewValue] = (case 
						when ac.[Column Name] = 'Order Status' and ISNUMERIC(ah.[New Value]) = 1
							then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.ID = ah.[New Value]), '')
						when (ac.[Column Name]='Requested Pickup Date' or ac.[Column Name]='Requested Delivery Date') and charindex(' ',( ah.[Old Value])) > 0 --SoNu
							then  substring(( ah.[New Value]), 1, charindex(' ',(ah.[New Value])))
						else ah.[New Value] end)
					,[IsAuto] = 0
					,[Source_MTV_ID] = 0
					,[Source_Name] = null
					,[ChangedBy] = cfn.FullName
					,[ChangedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ah.[Date],@TimeZone_ID,null,@TimeZoneName)
					,TotalRecords = @TotalRecords
				from [PinnacleArchiveDB].[dbo].[Metropolitan$Audit History] ah with (nolock)
				inner join [PinnacleProd].[dbo].[Metropolitan$Audit Column] ac with (nolock) on ah.[Column ID] = ac.[Column ID]
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ah.[Added by]) cfn
				Where ah.[Order ID]= @ORDER_NO and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)
			) ilv
		end
	end

	return
	

end
GO
