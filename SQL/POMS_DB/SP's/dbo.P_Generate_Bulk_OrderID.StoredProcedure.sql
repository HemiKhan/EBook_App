USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_Bulk_OrderID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @Return_Code bit Declare @Return_Text nvarchar(1000) exec [POMS_DB].[dbo].[P_Generate_Bulk_OrderID] @GenerateNoOfOrders = 500, @Ret_Return_Code = @Return_Code out, @Ret_Return_Text = @Return_Text out select @Return_Code, @Return_Text
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_Bulk_OrderID]
	@GenerateNoOfOrders int
	,@Ret_Return_Code bit out
	,@Ret_Return_Text nvarchar(1000) out
AS
BEGIN
	Declare @ReturnTable table (Order_ID bigint, Tracking_No nvarchar(40))
	Declare @Order_ID bigint
	Declare @TRACKING_NO nvarchar(40)
	Declare @AllowedLimit int = 1000
	select @Ret_Return_Code = 0, @Ret_Return_Text = ''

	Declare @CurrentRow int = 1
	if (@GenerateNoOfOrders > 0 and @GenerateNoOfOrders <= @AllowedLimit)
	begin
		while (@CurrentRow <= @GenerateNoOfOrders)
		begin
			insert into [POMS_DB].[dbo].[T_Generate_OrderID] (IsGenerate)
			values (1)
			select @Order_ID = SCOPE_IDENTITY()
			select @TRACKING_NO = [POMS_DB].[dbo].[F_Track] (@Order_ID)
			insert into @ReturnTable (Order_ID,Tracking_No)
			select @Order_ID,@TRACKING_NO
			set @CurrentRow = @CurrentRow + 1
		end
		select @Ret_Return_Code = 1, @Ret_Return_Text = ''
		delete from [POMS_DB].[dbo].[T_Generate_OrderID] where ORDER_ID in (select Order_ID from @ReturnTable)
	end

	if @GenerateNoOfOrders <= 0
	begin
		select @Ret_Return_Code = 0, @Ret_Return_Text = 'Request count should be more than 0 count'
	end
	else if @GenerateNoOfOrders > @AllowedLimit
	begin
		select @Ret_Return_Code = 0, @Ret_Return_Text = 'More than ' + FORMAT(@AllowedLimit, '##,##,#####') + ' is not allowed. Request received for ' + FORMAT(@GenerateNoOfOrders, '##,##,#####') + '.'
	end

	select Order_ID , Tracking_No from @ReturnTable

END
GO
