USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_New_ScanType_And_ManifestType_By_ScanType_And_ManifestType]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_New_ScanType_And_ManifestType_By_ScanType_And_ManifestType] (113101,115103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_New_ScanType_And_ManifestType_By_ScanType_And_ManifestType]
(	
	@OldScanType_MTV_ID int
	,@OldManifestType_MTV_ID int
)
RETURNS @ReturnTable TABLE 
(ScanType_MTV_ID int, ManifestType_MTV_ID int, ScanAnyTime bit)
AS
begin

	set @OldScanType_MTV_ID = ISNULL(@OldScanType_MTV_ID,0)
	set @OldManifestType_MTV_ID = ISNULL(@OldManifestType_MTV_ID,0)

	Declare @NewScanType_MTV_ID int = @OldScanType_MTV_ID
	Declare @NewManifestType_MTV_ID int = @OldManifestType_MTV_ID
	Declare @ScanAnyTime bit = 0

	if (@OldScanType_MTV_ID in (113101,113102) and @OldManifestType_MTV_ID = 115103)
	begin
		set @NewScanType_MTV_ID = @OldScanType_MTV_ID
		set @ScanAnyTime = 1
		set @OldManifestType_MTV_ID = 115100
	end
	else if (@OldScanType_MTV_ID in (113101,113102) and @OldManifestType_MTV_ID = 115104)
	begin
		set @NewScanType_MTV_ID = @OldScanType_MTV_ID
		set @ScanAnyTime = 1
		set @OldManifestType_MTV_ID = 115101
	end
	else if (@OldScanType_MTV_ID in (113101,113102) and @OldManifestType_MTV_ID = 115105)
	begin
		set @NewScanType_MTV_ID = @OldScanType_MTV_ID
		set @ScanAnyTime = 1
		set @OldManifestType_MTV_ID = 115102
	end
	else if (@OldScanType_MTV_ID in (113101,113102) and @OldManifestType_MTV_ID = 115108)
	begin
		set @NewScanType_MTV_ID = @OldScanType_MTV_ID
		set @ScanAnyTime = 1
		set @OldManifestType_MTV_ID = 115106
	end
	else if (@OldScanType_MTV_ID in (113101,113102) and @OldManifestType_MTV_ID = 115109)
	begin
		set @NewScanType_MTV_ID = @OldScanType_MTV_ID
		set @ScanAnyTime = 1
		set @OldManifestType_MTV_ID = 115107
	end
	
	insert into @ReturnTable (ScanType_MTV_ID , ManifestType_MTV_ID , ScanAnyTime)
	values (@NewScanType_MTV_ID,@NewManifestType_MTV_ID,@ScanAnyTime)

	return

end
GO
