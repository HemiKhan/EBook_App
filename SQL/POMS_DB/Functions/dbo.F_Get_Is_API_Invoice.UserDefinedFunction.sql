USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Is_API_Invoice]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Is_API_Invoice] 
(
	-- Add the parameters for the function here
	@EstInvoiceNo nvarchar(20)
	,@ORDER_NO nvarchar(20)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@TimeZoneName nvarchar(50)
)
RETURNS nvarchar(250)
AS
BEGIN
	DECLARE @Result nvarchar(250) = ''

	if @UserType_MTV_CODE <> 'METRO-USER'
	begin
		RETURN @Result
	end

	Declare @APIUsers table
	(
		APIUser nvarchar(150)
		,APIUserID int
	)
	insert into @APIUsers(APIUser,APIUserID)
	select [USERNAME],[USER_ID] from [POMS_DB].[dbo].[T_Users] with (nolock) where [USERNAME] in ('PPLUS.COSTCO','PPLUS.EXCPCOSTCO','PPLUS.EXCPINVOICE','PPLUS.EXCPTEAM4','PPLUS.INVOICE','PPLUS.TEAM4','INVOICEAPI')

	Declare @tmp table
	(
		[Document No_] nvarchar(40)
		,[Line No_] int
		,[Added By] nvarchar(100)
		,[Added On] datetime
		,[Modified By] int
		,[Modified On] datetime
	)
	insert into @tmp ([Document No_],[Line No_],[Added By],[Added On],[Modified By],[Modified On])
	select [Document No_],[Line No_],[Added By],[Added On],[Modified By],[Modified On] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Estimate Line] with (nolock) where [Document No_] = @EstInvoiceNo

	declare @apiuseraddeddate datetime
	declare @apiusermodifiydate datetime
	declare @otheruseraddeddate datetime
	declare @otherusermodifiydate datetime
	declare @maxdate datetime
	Declare @IsAPI bit = 0
	Declare @GeneralDate datetime = '1753-01-01 00:00:00.000'

	select @apiuseraddeddate = max([Added On]) from @tmp where [Added By] in (Select APIUser from @APIUsers)
	select @apiusermodifiydate = max([Modified On]) from @tmp where [Modified By] in (Select APIUserID from @APIUsers)
	select @otheruseraddeddate = max([Added On]) from @tmp where [Added By] not in (Select APIUser from @APIUsers)
	select @otherusermodifiydate = max([Modified On]) from @tmp where [Modified By] not in (Select APIUserID from @APIUsers)

	select @apiuseraddeddate = isnull(@apiuseraddeddate,@GeneralDate)
	,@apiusermodifiydate = isnull(@apiusermodifiydate,@GeneralDate)
	,@otheruseraddeddate = isnull(@otheruseraddeddate,@GeneralDate)
	,@otherusermodifiydate = isnull(@otherusermodifiydate,@GeneralDate)

	SELECT @maxdate = (SELECT Max(v) FROM (VALUES (@apiuseraddeddate), (@apiusermodifiydate), (@otheruseraddeddate),(@otherusermodifiydate)) AS value(v))
	set @maxdate = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](@maxdate,@TimeZone_ID,null,@TimeZoneName)

	select @IsAPI = (case when @apiuseraddeddate > @otheruseraddeddate and @apiusermodifiydate > @otherusermodifiydate then 1 else 0 end)

	set @Result = (case when @IsAPI = 1 then 'API ' + format(@maxdate , 'MM/dd/yyyy hh:mm tt') else '' end)

	RETURN @Result

END
GO
