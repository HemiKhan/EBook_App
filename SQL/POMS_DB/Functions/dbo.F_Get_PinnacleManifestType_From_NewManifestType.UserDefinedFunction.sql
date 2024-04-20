USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleManifestType_From_NewManifestType]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (115103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleManifestType_From_NewManifestType]
(	
	@ManifestType_MTV_ID int
)
RETURNS @ReturnTable TABLE 
(PinnacleManifestType int, PinnacleManifestSubType int)
AS
begin

	set @ManifestType_MTV_ID = ISNULL(@ManifestType_MTV_ID,0)

	Declare @PinnacleManifestType int = @ManifestType_MTV_ID
	Declare @PinnacleManifestSubType int = 10000

	if (@ManifestType_MTV_ID in (115100,115103))
	begin
		set @PinnacleManifestType = 40000
		set @PinnacleManifestSubType = 10000
	end
	else if (@ManifestType_MTV_ID in (115101,115104))
	begin
		set @PinnacleManifestType = 10000
		set @PinnacleManifestSubType = 10000
	end
	else if (@ManifestType_MTV_ID in (115102,115105))
	begin
		set @PinnacleManifestType = 30000
		set @PinnacleManifestSubType = 10000
	end
	else if (@ManifestType_MTV_ID in (115106,115108))
	begin
		set @PinnacleManifestType = 10000
		set @PinnacleManifestSubType = 20000
	end
	else if (@ManifestType_MTV_ID in (115107,115109))
	begin
		set @PinnacleManifestType = 10000
		set @PinnacleManifestSubType = 30000
	end

	insert into @ReturnTable (PinnacleManifestType , PinnacleManifestSubType)
	values (@PinnacleManifestType,@PinnacleManifestSubType)

	return

end
GO
