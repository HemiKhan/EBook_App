USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_ChangeLog_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_ChangeLog_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_ChangeLog_By_OrderID]
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

	if @GetRecordType_MTV_ID in (147100,147102)
	begin
		select @TotalRecords = (@TotalRecords + count(oah.OAH_ID)) from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock)
		inner join [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock) on oah.AC_ID = ac.AC_ID
		Where oah.ORDER_ID= @ORDER_ID and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [AuditType_MTV_ID] , [AuditType_Name] , [RefNo1] , [RefNo2] , [RefNo3] , [OAH_ID] , [ColumnName] , [IsPublic] , [Reason] , [OldValue] , [NewValue] 
				, [IsAuto] , [Source_MTV_ID] , [Source_Name] , [ChangedBy] , [ChangedOn] , TotalRecords)
			select OrderID = oah.ORDER_ID
				,oah.[AuditType_MTV_ID]
				,[AuditType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oah.[AuditType_MTV_ID])
				,oah.[RefNo1]
				,oah.[RefNo2]
				,oah.[RefNo3]
				,oah.[OAH_ID]
				,[ColumnName] = ac.[Name]
				,ac.IsPublic
				,oah.[Reason]
				,oah.[OldValue]
				,oah.[NewValue]
				,oah.[IsAuto]
				,oah.[Source_MTV_ID]
				,[Source_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oah.[Source_MTV_ID])
				,[ChangedBy] = cfn.FullName
				,[ChangedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oah.ChangedOn,@TimeZone_ID,null,@TimeZoneName)
				,TotalRecords = @TotalRecords
			from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock)
			inner join [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock) on oah.AC_ID = ac.AC_ID
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oah.ChangedBy) cfn
			Where oah.ORDER_ID= @ORDER_ID and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)
		end

		if @GetRecordType_MTV_ID in (147102)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(oah.OAH_ID)) from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock)
			inner join [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock) on oah.AC_ID = ac.AC_ID
			Where oah.ORDER_ID= @ORDER_ID and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable ([OrderID] , [AuditType_MTV_ID] , [AuditType_Name] , [RefNo1] , [RefNo2] , [RefNo3] , [OAH_ID] , [ColumnName] , [IsPublic] , [Reason] , [OldValue] , [NewValue] 
					, [IsAuto] , [Source_MTV_ID] , [Source_Name] , [ChangedBy] , [ChangedOn] , TotalRecords)
				select OrderID = oah.ORDER_ID
					,oah.[AuditType_MTV_ID]
					,[AuditType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oah.[AuditType_MTV_ID])
					,oah.[RefNo1]
					,oah.[RefNo2]
					,oah.[RefNo3]
					,oah.[OAH_ID]
					,[ColumnName] = ac.[Name]
					,ac.IsPublic
					,oah.[Reason]
					,oah.[OldValue]
					,oah.[NewValue]
					,oah.[IsAuto]
					,oah.[Source_MTV_ID]
					,[Source_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oah.[Source_MTV_ID])
					,[ChangedBy] = cfn.FullName
					,[ChangedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oah.ChangedOn,@TimeZone_ID,null,@TimeZoneName)
					,TotalRecords = @TotalRecords
				from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock)
				inner join [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock) on oah.AC_ID = ac.AC_ID
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oah.ChangedBy) cfn
				Where oah.ORDER_ID= @ORDER_ID and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147101)
	begin
		select @TotalRecords = (@TotalRecords + count(oah.OAH_ID)) from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock)
		inner join [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock) on oah.AC_ID = ac.AC_ID
		Where oah.ORDER_ID= @ORDER_ID and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [AuditType_MTV_ID] , [AuditType_Name] , [RefNo1] , [RefNo2] , [RefNo3] , [OAH_ID] , [ColumnName] , [IsPublic] , [Reason] , [OldValue] , [NewValue] 
				, [IsAuto] , [Source_MTV_ID] , [Source_Name] , [ChangedBy] , [ChangedOn] , TotalRecords)
			select OrderID = oah.ORDER_ID
				,oah.[AuditType_MTV_ID]
				,[AuditType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oah.[AuditType_MTV_ID])
				,oah.[RefNo1]
				,oah.[RefNo2]
				,oah.[RefNo3]
				,oah.[OAH_ID]
				,[ColumnName] = ac.[Name]
				,ac.IsPublic
				,oah.[Reason]
				,oah.[OldValue]
				,oah.[NewValue]
				,oah.[IsAuto]
				,oah.[Source_MTV_ID]
				,[Source_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oah.[Source_MTV_ID])
				,[ChangedBy] = cfn.FullName
				,[ChangedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oah.ChangedOn,@TimeZone_ID,null,@TimeZoneName)
				,TotalRecords = @TotalRecords
			from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock)
			inner join [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock) on oah.AC_ID = ac.AC_ID
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oah.ChangedBy) cfn
			Where oah.ORDER_ID= @ORDER_ID and ((ac.[IsPublic] = 1 and  @IsPublic = 0) or @IsPublic = 1)
		end
	end

	return
	

end
GO
