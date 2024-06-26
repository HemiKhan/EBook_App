USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Track_Valid]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Track_Valid]  
(
	-- Add the parameters for the function here
	@track nvarchar(100)
)
RETURNS bit
AS
BEGIN
DECLARE @Ret bit	
--DECLARE @Track nvarchar(100)='598706643212'
	if (LEN(@Track)=12)
	begin
		DECLARE @T table (id int IDENTITY(1, 1), chr nvarchar(1), d1 int)
		DECLARE @EPom nvarchar(100)
		DECLARE @Pom nvarchar(100)
		DECLARE @NewTrack nvarchar(100)		
		select @EPom =SUBSTRING(@track,2,3)+SUBSTRING(@track,6,3)+SUBSTRING(@track,9,3)
		INSERT INTO @T(chr)
		
		select substring(a.b, v.number+1, 1) 
		from (select @EPom b) a
		join master..spt_values v on v.number < len(a.b)
		where v.type = 'P'
		
		update @T set d1=case when (cast(chr as int)-10)*-1=10 then 0 else (cast(chr as int)-10)*-1 end

	--select * from @t

		Select @Pom = COALESCE(@Pom  + cast(d1 as nvarchar(10)),cast(d1 as nvarchar(10))) 
		From @T 
		select @NewTrack=dbo.F_Track(@POM)
		if (@NewTrack=@Track) begin set @Ret=1 end else begin set @Ret=0 end
	end
	else
	begin
		set @Ret=0 
	end

 
return @ret
END
GO
