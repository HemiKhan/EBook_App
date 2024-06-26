USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RejectionDetail_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_RejectionDetail_By_OrderID] (3134111,'S-ESTINV4475928','SI11397925',1,'ABDULLAH.ARSHAD','METRO-USER',0,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_RejectionDetail_By_OrderID]
(	
	@ORDER_ID int
	,@EstInvoiceNo nvarchar(50)
	,@InvoiceInvoiceNo nvarchar(50)
	,@IsCountOnly bit
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([OrderID] int
,[Reject_Count] int
,[Cancel_Count] int
,[EstInvoiceNo] nvarchar(50) 
,[InvoiceNo] nvarchar(50)
,[Type] nvarchar(50)
,[Reason] nvarchar(250) 
,[RejectedBy] nvarchar(150) 
,[RejectionTime] datetime
,[CreatedBy] nvarchar(150) 
,[CreatedTime] datetime
,[PostingDate] date
)
AS
begin
	
	Declare @Reject_Count int = 0
	Declare @Cancel_Count int = 0
	Declare @ReturnCode bit = 0
	Declare @ReturnText nvarchar(250) = ''
	
	Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	Declare @Inv table 
	([EstimateID] nvarchar(20) collate Latin1_General_100_CS_AS
	,[NavInvoiceID] nvarchar(20) collate Latin1_General_100_CS_AS
	,[OrderNo] nvarchar(20) collate Latin1_General_100_CS_AS
	,[OrderID] int)
	
	insert into @Inv ([EstimateID], [NavInvoiceID], [OrderNo], [OrderID])
	select [EstimateID] = @EstInvoiceNo , [NavInvoiceID] = @InvoiceInvoiceNo , [Order No] = @OrderNo , [OrderID] = @ORDER_ID 

	Declare @final table 
	([Date] datetime 
	,[OrderID] int
	,[InvoiceNo] nvarchar(50) collate Latin1_General_100_CS_AS
	,[Reason] nvarchar(250) collate Latin1_General_100_CS_AS
	,[RejectedBy] nvarchar(150) collate Latin1_General_100_CS_AS
	,[EstInvoiceNo] nvarchar(50) collate Latin1_General_100_CS_AS
	,[Type] nvarchar(50) collate Latin1_General_100_CS_AS)

	if exists(select top 1 1 from @Inv)
	begin
		Declare @tmp table 
		(EntryNo int
		,[Date] datetime
		,[OrderID] int
		,[Reason] nvarchar(250) collate Latin1_General_100_CS_AS
		,[AddedBy] nvarchar(150) collate Latin1_General_100_CS_AS
		,[Type] nvarchar(50) collate Latin1_General_100_CS_AS
		,[InvoiceNo] nvarchar(50) collate Latin1_General_100_CS_AS
		,[EstInvoiceNo] nvarchar(50) collate Latin1_General_100_CS_AS)
		
		if @GetRecordType_MTV_ID in (147100,147101,147102)
		begin
			insert into @tmp (EntryNo,[Date],[OrderID],[Reason],[AddedBy],[Type],[InvoiceNo],[EstInvoiceNo])
			select [EntryNo]=OAH_ID,[Date]=ChangedOn,[OrderID]=ORDER_ID,[Reason],[AddedBy]=[ChangedBy],[Type]=left([NewValue],17),[InvoiceNo]=i.[NavInvoiceID],[EstInvoiceNo]=i.[EstimateID]
			from [POMS_DB].[dbo].[T_Order_Audit_History] oah with (nolock) 
			inner join @Inv i on i.[OrderID] = oah.ORDER_ID and oah.[AC_ID] in (1012)
			and left([NewValue],17) in ('Approval Rejected','Approval Cancelle')
			and substring([NewValue],charindex('|',[NewValue],1)+1,len(i.[NavInvoiceID])) = i.[NavInvoiceID] collate Latin1_General_100_CS_AS
		end
		else if @GetRecordType_MTV_ID in (147103,147104,147105)
		begin
			insert into @tmp (EntryNo,[Date],[OrderID],[Reason],[AddedBy],[Type],[InvoiceNo],[EstInvoiceNo])
			select [Entry No_]=[ID],[Date],[Order ID],[Reason]=[Update Reason],[Added by],[Type]=left([New Value],17),[InvoiceNo]=i.[NavInvoiceID],[EstInvoiceNo]=i.[EstimateID]
			from [PinnacleProd].[dbo].[Metropolitan$Audit History] ah with (nolock) 
			inner join @inv i on i.[OrderNo] = ah.[Order ID] and ah.[Column ID] in (488)
			and left([New Value],17) in ('Approval Rejected','Approval Cancelle')
			and substring([New Value],charindex('|',[New Value],1)+1,len(i.[NavInvoiceID])) = i.[NavInvoiceID]
		end

		Declare @tmp1 table 
		([ID] int
		,[EntryNo_] int
		,[Type] nvarchar(50) collate Latin1_General_100_CS_AS
		,[Date] datetime
		,[OrderID] int
		,[InvoiceNo] nvarchar(50) collate Latin1_General_100_CS_AS
		,[Reason] nvarchar(250) collate Latin1_General_100_CS_AS
		,[AddedBy] nvarchar(150) collate Latin1_General_100_CS_AS
		,[EstInvoiceNo] nvarchar(50) collate Latin1_General_100_CS_AS)
		
		insert into @tmp1 ([ID],[EntryNo_],[Type],[Date],[OrderID],[InvoiceNo],[Reason],[AddedBy],[EstInvoiceNo])
		select distinct [ID]=isnull(t.[EntryNo],0),[EntryNo_]=drl.[Entry No_],[Type]='Approval Rejected',[Date]=isnull(t.[Date],drl.[Rejected Time]),[OrderID]=i.OrderID
		,[InvoiceNo]=drl.[Document No_],drl.[Reason],[Added By]=isnull(t.[AddedBy],drl.[Rejected By]),[EstInvoiceNo]=i.[EstimateID]
		from [MetroPolitanNavProduction].[dbo].[Metropolitan$Document Rejection Log] drl with (nolock) 
		inner join @Inv i on i.[NavInvoiceID] = drl.[Document No_] left join @tmp t on t.[InvoiceNo] = drl.[Document No_] 
		and drl.Reason = t.[Reason] and drl.[Rejected Time] between dateadd(second,-60,t.[Date]) and t.[Date] where drl.[Document No_] = i.[NavInvoiceID]

		insert into @final ([Date],[OrderID],[InvoiceNo],[Reason],[RejectedBy],[EstInvoiceNo],[Type])
		select * from (
		select [Date],[OrderID],[InvoiceNo],[Reason],[AddedBy],[EstInvoiceNo],[Type] from @tmp1
		union
		select [Date],[OrderID],[InvoiceNo],[Reason],[AddedBy],[EstInvoiceNo]
		,[Type]=(case when [Type] = 'Approval Cancelle' then 'Approval Cancelled' else [Type] end) from @tmp where [EntryNo] not in (select ID from @tmp1)
		) ilv order by [Date]
	end

	if @IsCountOnly = 0
	begin
		Declare @TimeZoneName nvarchar(50) = null
		Declare @TimeZoneAbbr nvarchar(10) = null
		select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

		select @Reject_Count = 0 ,@Cancel_Count = 0
		
		insert into @ReturnTable
		select [orderid]=[OrderID]
		,Reject_Count=@Reject_Count
		,Cancel_Count=@Cancel_Count
		,[estinvoiceno]=[EstInvoiceNo]
		,[invoiceno]=[InvoiceNo]
		,[type]=[Type]
		,[reason]=[Reason]
		,[rejectedby]=[RejectedBy]
		,[rejectiontime]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC](f.[Date],@TimeZone_ID,null,@TimeZoneName)
		,[createdby]=sh.[Created By]
		,[createtime]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sh.[Create Time],@TimeZone_ID,null,@TimeZoneName)
		,[postingdate]=sh.[Posting Date]
		from @final f left join [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Header] sh with (nolock) on f.InvoiceNo = sh.No_ and sh.[Document Type] = 2
		order by f.[Date]
	end
	else
	begin
		select @Reject_Count = sum((case when [Type] = 'Approval Rejected' then 1 else 0 end))
		,@Cancel_Count = sum((case when [Type] = 'Approval Cancelled' then 1 else 0 end)) from @final group by [Type]

		insert into @ReturnTable
		select [orderid]=@ORDER_ID
		,Reject_Count=@Reject_Count
		,Cancel_Count=@Cancel_Count
		,[EstInvoiceNo]=@EstInvoiceNo
		,[InvoiceNo]=@InvoiceInvoiceNo
		,[Type]=null
		,[Reason]=null
		,[RejectedBy]=null
		,[RejectionTime]=null
		,[CreatedBy]=null
		,[CreateTime]=null
		,[PostingDate]=null
	end

	return
	

end
GO
