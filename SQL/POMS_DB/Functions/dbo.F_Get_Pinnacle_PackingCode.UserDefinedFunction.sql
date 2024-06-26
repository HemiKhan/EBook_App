USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Pinnacle_PackingCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Pinnacle_PackingCode]
(
	@PackedbyShipper tinyint
	,@BlanketService bit
	,@PackingRequired bit
	,@CrateRequired bit
)
RETURNS nvarchar(20)
AS
BEGIN
	set @PackedbyShipper = isnull(@PackedbyShipper,0)
	set @BlanketService = isnull(@BlanketService,0)
	set @PackingRequired = isnull(@PackingRequired,0)
	set @CrateRequired = isnull(@CrateRequired,0)

	Declare @ReturnText nvarchar(20) = ''

	set @ReturnText = (case 
			when (@PackedbyShipper = 1 and @BlanketService = 0 and @PackingRequired = 0 and @CrateRequired = 0) then 'PK-SP'
			when (@PackedbyShipper in (0,1) and @BlanketService = 0 and @PackingRequired = 0 and @CrateRequired = 0) then 'PK-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 1 and @PackingRequired = 0 and @CrateRequired = 0) then 'BW-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 0 and @PackingRequired = 1 and @CrateRequired = 0) then 'PK-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 0 and @PackingRequired = 0 and @CrateRequired = 1) then 'CR-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 1 and @PackingRequired = 1 and @CrateRequired = 0) then 'BW-PK-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 1 and @PackingRequired = 0 and @CrateRequired = 1) then 'BW-CR-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 0 and @PackingRequired = 1 and @CrateRequired = 1) then 'PK-CR-REQ'
			when (@PackedbyShipper in (0,1) and @BlanketService = 1 and @PackingRequired = 1 and @CrateRequired = 1) then 'BW-PK-CR-REQ'
			else '' end)

	return @ReturnText

END
GO
