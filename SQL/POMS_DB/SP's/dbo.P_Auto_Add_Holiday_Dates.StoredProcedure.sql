USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Auto_Add_Holiday_Dates]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Auto_Add_Holiday_Dates] null, null
-- =============================================
CREATE PROCEDURE [dbo].[P_Auto_Add_Holiday_Dates]
	@Currentdate date 
	,@Username nvarchar(150) 

AS
BEGIN
	
	set @Currentdate = ISNULL(@Currentdate,getutcdate())
	set @Username = isnull(@Username,'AUTOUSER')

	drop table if exists #tDates
	select HM_ID ,[Date] ,AddedBy = @Username into #tDates from [POMS_DB].[dbo].[F_Get_Next_Dates_From_Month_Day_And_Code] (@Currentdate) 

	insert into [POMS_DB].[dbo].[T_Holiday_Dates] (HM_ID, [Date], [AddedBy])
	select t.HM_ID ,t.[Date] ,t.AddedBy from #tDates t where t.[Date] is not null and t.[Date] not in (select hd.[Date] from [POMS_DB].[dbo].[T_Holiday_Dates] hd with (nolock))

END
GO
