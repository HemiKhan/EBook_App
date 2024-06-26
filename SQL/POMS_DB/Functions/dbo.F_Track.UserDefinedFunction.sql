USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Track]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Track]  
(
	-- Add the parameters for the function here
	@POM nvarchar(100)
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here

--DECLARE @POM nvarchar(100)='123446789'
DECLARE @T table (id int IDENTITY(1, 1), chr nvarchar(1),n1 int,n2 int,n3 int, c1 int, d1 int)
select @POM ='00000000000' + @POM
Select @POM=RIGHT(@pom,9)
DECLARE @n1 int=0
DECLARE @n2 int=0
DECLARE @n3 int=0
DECLARE @EPom nvarchar(100)

INSERT INTO @T(chr)

select substring(a.b, v.number+1, 1) 
from (select @POM b) a
join master..spt_values v on v.number < len(a.b)
where v.type = 'P'
update @T set c1=case when 10-cast(chr as int)=10 then 0 else 10-cast(chr as int) end
update @T set d1=case when (c1-10)*-1=10 then 0 else (c1-10)*-1 end
update @T set n1=cast(chr as int)*id
update @T set n2=cast(chr as int)*n1
update @T set n3=cast(chr as int)*n2
--select * from @t
select @n1=sum(n1) from @T
select @n1=@n1%11
if (@n1=10) begin set @n1=0 end

select @n2=sum(n2) from @T
select @n2=@n2%11
if (@n2=10) begin set @n2=0 end

select @n3=sum(n3) from @T
select @n3=@n3%11
if (@n3=10) begin set @n3=0 end

Select @EPom = COALESCE(@EPom  + cast(c1 as nvarchar(10)),cast(c1 as nvarchar(10))) From @T 

--select cast(@n1 as nvarchar(10))+SUBSTRING(@EPom,1,3) +cast(@n2 as nvarchar(10))+SUBSTRING(@EPom,4,3)+SUBSTRING(@EPom,7,3)+cast(@n3 as nvarchar(10))
return cast(@n1 as nvarchar(10))+SUBSTRING(@EPom,1,3) +cast(@n2 as nvarchar(10))+SUBSTRING(@EPom,4,3)+SUBSTRING(@EPom,7,3)+cast(@n3 as nvarchar(10))
 


 


END
GO
