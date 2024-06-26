USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Special_Service_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Special_Service_IU]
	@pJson nvarchar(max)
	,@pOrder_ID int
	,@pUserName nvarchar(150)
	,@IsPickup bit
	,@ST_CODE nvarchar(20)
	,@pAddRowCount int output
	,@pEditRowCount int output
	,@pDeleteRowCount int output
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 101100
AS
BEGIN
	SET NOCOUNT ON;
	set @pUserName = upper(@pUserName)

	set @pAddRowCount = 0
	set @pEditRowCount = 0
	set @pDeleteRowCount = 0
	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Begin Try

		drop table if exists #JsonSpecialServiceTable
		select * into #JsonSpecialServiceTable 
		from [POMS_DB].[dbo].[F_Get_Order_JsonSpecialServiceTable] (@pJson,@IsPickup,@ST_CODE)
	
		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if exists(select * from #JsonSpecialServiceTable where OSS_ID = 0 and IsDelete = 0 and [SLSS_ID] not in (select [SLSS_ID] from [POMS_DB].[dbo].[T_Order_Special_Service] with (nolock) where ORDER_ID = @pOrder_ID and [Is_Pickup] = @IsPickup))
		begin
			insert into [POMS_DB].[dbo].[T_Order_Special_Service] ([ORDER_ID] ,[SLSS_ID] ,[Is_Pickup] ,[Description_] ,[Mints] ,[Floor_] ,[EST_Amount] ,[Days_] ,[From_Date] ,[To_Date] ,[Man] ,[IsPublic] ,[CreatedBy])
			select @pOrder_ID as Order_ID, [SLSS_ID] , @IsPickup as [Is_Pickup] ,Description_ ,[Mints] ,[Floor_] ,[EST_Amount] ,[Days_] ,[From_Date] ,[To_Date] ,[Man] ,[IsPublic], @pUserName as CreatedBy 
			from #JsonSpecialServiceTable where OSS_ID = 0 and IsDelete = 0 
			and [SLSS_ID] not in (select [SLSS_ID] from [POMS_DB].[dbo].[T_Order_Special_Service] with (nolock) where ORDER_ID = @pOrder_ID and [Is_Pickup] = @IsPickup)
	
			set @pAddRowCount = @@ROWCOUNT
			if (@pAddRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Special Service was not Insert'
			end
		end

		if exists(select oss.OSS_ID from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock) 
					inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
					where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 0) and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldEditSpecialServiceTable 
			select oss.ORDER_ID, oss.OSS_ID ,oss.[SLSS_ID]
			,[SLSS_ID_Name] = isnull((SELECT top 1 ssl_.[Name] FROM [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock) inner join [POMS_DB].[dbo].[T_Special_Services_List] ssl_ with (nolock) on slss.SSL_CODE = ssl_.SSL_CODE where slss.SLSS_ID = oss.[SLSS_ID]),'')
			,[Description_] = isnull(oss.Description_,'')
			,[Mints] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Mints])
			,[Floor_] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Floor_])
			,[EST_Amount] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[EST_Amount])
			,[Days_] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Days_])
			,[From_Date] = (case when oss.[From_Date] is null then '' else format(oss.[From_Date],'yyyy-MM-dd') end)
			,[To_Date] = (case when oss.[To_Date] is null then '' else format(oss.[To_Date],'yyyy-MM-dd') end)
			,[Man] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Man])
			,[IsPublic] = oss.[IsPublic]
			,[IsPublicName] = (case when oss.[IsPublic] = 1 then 'Yes' else 'No' end)
			,[RefNo2] = (case when oss.[Is_Pickup] = 1 then 'Pickup' else 'Delivery' end)
			into #JsonOldEditSpecialServiceTable
			from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock)
			inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
			where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 0 
	
			update oss
			set oss.Description_ = joss.Description_ 
			,oss.[Mints] = joss.[Mints] 
			,oss.[Floor_] = joss.[Floor_] 
			,oss.[EST_Amount] = joss.[EST_Amount] 
			,oss.[Days_] = joss.[Days_] 
			,oss.[From_Date] = joss.[From_Date] 
			,oss.[To_Date] = joss.[To_Date] 
			,oss.[Man] = joss.[Man]
			,oss.[IsPublic] = joss.[IsPublic]
			,oss.[ModifiedBy] = @pUserName
			,oss.[ModifiedOn] = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock)
			inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
			where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 0
	
			set @pEditRowCount = @@ROWCOUNT
			if (@pEditRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Special Service was not Updated'
			end

			drop table if exists #JsonOldEditSpecialServiceTable 
			select ORDER_ID = @pOrder_ID, joss.OSS_ID ,joss.[SLSS_ID]
			,[SLSS_ID_Name] = isnull((SELECT top 1 ssl_.[Name] FROM [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock) inner join [POMS_DB].[dbo].[T_Special_Services_List] ssl_ with (nolock) on slss.SSL_CODE = ssl_.SSL_CODE where slss.SLSS_ID = joss.[SLSS_ID]),'')
			,Description_ = isnull(joss.Description_,'')
			,[Mints] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (joss.[Mints])
			,[Floor_] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (joss.[Floor_])
			,[EST_Amount] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (joss.[EST_Amount])
			,[Days_] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (joss.[Days_])
			,[From_Date] = (case when joss.[From_Date] is null then '' else format(joss.[From_Date],'yyyy-MM-dd') end)
			,[To_Date] = (case when joss.[To_Date] is null then '' else format(joss.[To_Date],'yyyy-MM-dd') end)
			,[Man] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (joss.[Man])
			,[IsPublic] = joss.[IsPublic]
			,[IsPublicName] = (case when joss.[IsPublic] = 1 then 'Yes' else 'No' end)
			,[RefNo2] = (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end)
			into #JsonNewEditSpecialServiceTable
			from #JsonSpecialServiceTable joss where joss.OSS_ID > 0 and joss.IsDelete = 0
		end
		
		if exists(select oss.OSS_ID from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock) 
					inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
					where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 1) and @pExecution_Error = ''
		begin
			drop table if exists #DeleteOSS_ID_Lists
			select oss.OSS_ID into #DeleteOSS_ID_Lists from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock) 
			inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
			where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 1
			
			drop table if exists #JsonOldDeleteSpecialServiceTable 
			select oss.ORDER_ID, oss.OSS_ID ,oss.[SLSS_ID]
			,[SLSS_ID_Name] = isnull((SELECT top 1 ssl_.[Name] FROM [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock) inner join [POMS_DB].[dbo].[T_Special_Services_List] ssl_ with (nolock) on slss.SSL_CODE = ssl_.SSL_CODE where slss.SLSS_ID = oss.[SLSS_ID]),'')
			,Description_ = isnull(oss.Description_,'')
			,[Mints] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Mints])
			,[Floor_] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Floor_])
			,[EST_Amount] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[EST_Amount])
			,[Days_] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Days_])
			,[From_Date] = (case when oss.[From_Date] is null then '' else format(oss.[From_Date],'yyyy-MM-dd') end)
			,[To_Date] = (case when oss.[To_Date] is null then '' else format(oss.[To_Date],'yyyy-MM-dd') end)
			,[Man] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oss.[Man])
			,[IsPublic] = oss.[IsPublic]
			,[IsPublicName] = (case when oss.[IsPublic] = 1 then 'Yes' else 'No' end)
			,[RefNo2] = (case when oss.[Is_Pickup] = 1 then 'Pickup' else 'Delivery' end)
			into #JsonOldDeleteSpecialServiceTable 
			from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock)
			inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
			where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 0 
	
			Delete from [POMS_DB].[dbo].[T_Order_Special_Service] where OSS_ID in 
			(select * from #DeleteOSS_ID_Lists)
			
			set @pEditRowCount = @@ROWCOUNT
			if (@pEditRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Special Service was not Updated'
			end

			drop table if exists #JsonNewDeleteSpecialServiceTable 
			select oss.ORDER_ID, oss.OSS_ID ,oss.[SLSS_ID]
			,[SLSS_ID_Name] = 'Deleted'
			,Description_ = 'Deleted'
			,[Mints] = 'Deleted'
			,[Floor_] = 'Deleted'
			,[EST_Amount] = 'Deleted'
			,[Days_] = 'Deleted'
			,[From_Date] = 'Deleted'
			,[To_Date] = 'Deleted'
			,[Man] = 'Deleted'
			,[IsPublic] = 'Deleted'
			,[IsPublicName] = 'Deleted'
			,[RefNo2] = (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end)
			into #JsonNewDeleteSpecialServiceTable 
			from [POMS_DB].[dbo].[T_Order_Special_Service] oss with (nolock)
			inner join #JsonSpecialServiceTable joss on oss.[SLSS_ID] = joss.[SLSS_ID] and oss.OSS_ID = joss.OSS_ID
			where oss.ORDER_ID = @pOrder_ID and oss.[Is_Pickup] = @IsPickup and joss.IsDelete = 0 
	
		end

		if @pExecution_Error = '' and @pReturn_Text = '' and @pError_Text = ''
		begin
			set @pReturn_Code = 1
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_Order_Special_Service_IU: ' + ERROR_MESSAGE()
	End catch

END
GO
