USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Process_Log_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Process_Log_IU]
	@RequestID nvarchar(36)
	,@IsSuccess bit
	,@UniqueID nvarchar(1000)
	,@ErrorJson nvarchar(max)
	,@WarningJson nvarchar(max)
	,@PickupServiceCode nvarchar(1000)
	,@DeliveryServiceCode nvarchar(1000)
	,@TotalQty int
	,@TotalWeight decimal(18, 6)
	,@TotalCuft decimal(18, 6)
	,@TotalValue decimal(18, 6)
	,@PRO nvarchar(1000)
	,@PONUMBER nvarchar(1000)
	,@REF2 nvarchar(1000)
	,@CarrierCode nvarchar(1000)
	,@ORDER_ID int
	,@TRACKING_NO nvarchar(20)
	,@Username nvarchar(150)
	,@Json nvarchar(max)
	,@Return_Code bit output
	,@Return_Text nvarchar(1000) output
	,@Error_Text nvarchar(max) output
AS
BEGIN
	
	Declare @OPL_ID int = 0
	select @OPL_ID = OPL_ID from [POMS_DB].[dbo].[T_Order_Process_Log] opl with (nolock) where opl.RequestID = @RequestID
	set @OPL_ID = isnull(@OPL_ID,0)

	Begin Try

		Begin Transaction

		if (@OPL_ID = 0)
		begin
			insert into [POMS_DB].[dbo].[T_Order_Process_Log] ([RequestID] ,[IsSuccess] ,[UniqueID] ,[ErrorJson] ,[WarningJson] ,[PickupServiceCode] ,[DeliveryServiceCode] ,[TotalQty] 
			,[TotalWeight] ,[TotalCuft] ,[TotalValue] ,[PRO] ,[PONUMBER] ,[REF2] ,[CarrierCode] ,[ORDER_ID] ,[TRACKING_NO] ,[AddedBy])
			values (@RequestID ,@IsSuccess ,@UniqueID ,@ErrorJson ,@WarningJson ,@PickupServiceCode ,@DeliveryServiceCode ,@TotalQty ,@TotalWeight ,@TotalCuft ,@TotalValue ,@PRO ,@PONUMBER ,@REF2 
			,@CarrierCode ,@ORDER_ID ,@TRACKING_NO ,@Username)
			Set @OPL_ID = SCOPE_IDENTITY()

			insert into [POMS_DB].[dbo].[T_Order_Process_Log_Json] ([OPL_ID] ,[RequestID] ,[Json] ,[AddedBy])
			values (@OPL_ID ,@RequestID ,@Json ,@Username)
		end
		else
		begin
			update opl
			set [IsSuccess] = @IsSuccess
			,[ErrorJson] = @ErrorJson
			,[WarningJson] = @WarningJson
			,[PickupServiceCode] = @PickupServiceCode
			,[DeliveryServiceCode] = @DeliveryServiceCode
			,[TotalQty] = TotalQty
			,[TotalWeight] = @TotalWeight
			,[TotalCuft] = @TotalCuft
			,[TotalValue] = @TotalValue
			,[PRO] = @PRO
			,[PONUMBER] = @PONUMBER
			,[REF2] = @REF2
			,[CarrierCode] = @CarrierCode
			,[ORDER_ID] = @ORDER_ID
			,[TRACKING_NO] = @TRACKING_NO
			,[ModifiedBy] = @Username
			,[ModifiedOn] = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Process_Log] opl where opl.OPL_ID = @OPL_ID

			update oplj
			set [Json] = @Json
			,[ModifiedBy] = @Username
			,[ModifiedOn] = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Process_Log_Json] oplj where oplj.OPL_ID = @OPL_ID
		end

		set @Return_Code = 1
		set @Return_Text = 'Done'
		set @Error_Text = ''

		if @@TRANCOUNT > 0
		begin
			COMMIT; 
		end

	end try
	begin catch
		set @Return_Code = 0
		set @Return_Text = 'Internal Server Error'
		if @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @Error_Text = ERROR_MESSAGE()
	end catch

END
GO
