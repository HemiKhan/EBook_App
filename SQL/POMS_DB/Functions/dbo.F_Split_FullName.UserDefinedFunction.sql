USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Split_FullName]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Split_FullName] ('A BD')
-- =============================================
CREATE FUNCTION [dbo].[F_Split_FullName]
(	
	@FullName NVARCHAR(1000)
)
RETURNS @ReturnTable TABLE 
(First_Name nvarchar(250), Middle_Name nvarchar(250), Last_Name nvarchar(250))
AS
begin

	set @FullName = isnull(@FullName,'')

	Declare @First_Name nvarchar(250) = ''
	Declare @Middle_Name nvarchar(250) = ''
	Declare @Last_Name nvarchar(250) = ''
	Declare @MaxRecords int = 0

	Declare @SplitTable table
	(ID int 
	,[Name] nvarchar(250)
	)

	insert into @SplitTable (ID, [Name])
	select ID,Text_ from [POMS_DB].[dbo].[SplitIntoTableWithSpace](@FullName)

	select @MaxRecords = ID from @SplitTable
	set @MaxRecords = isnull(@MaxRecords,0)

	if (@MaxRecords > 0)
	begin
		select @First_Name = [Name] from @SplitTable where ID = 1
	end
	if (@MaxRecords > 1)
	begin
		select @Middle_Name = [Name] from @SplitTable where ID = 2
	end
	if (@MaxRecords = 3)
	begin
		select @Last_Name = [Name] from @SplitTable where ID = 3
	end
	if (@MaxRecords > 3)
	begin
		set @Last_Name = (select [Name] + ' ' from @SplitTable where ID > 2 For XML Path(''), TYPE).value('.', 'nvarchar(1000)')
		set @Last_Name = rtrim(ltrim(@Last_Name))
	end

	insert into @ReturnTable
	select @First_Name, @Middle_Name, @Last_Name

	return

end
GO
