USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_POMS_Orders_Search_Value_Character_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_POMS_Orders_Search_Value_Character_IU] null,null
-- =============================================
CREATE PROCEDURE [dbo].[P_POMS_Orders_Search_Value_Character_IU]
	-- Add the parameters for the stored procedure here
	@Orders int -- 0 for all pending order
	,@Type nvarchar(max) -- null for all types
AS
BEGIN
	--return
	if (@Type = '')
		begin return end

	begin try
		--@Type = 'ALL,ALLSL,ALLSH,REF1,REF2,TAG,CARRIER,PRO,DESTNAME,SHIPFROMNAME,SHIPFROMCONTACT,SHIPFROMADDRESS,SHIPTONAME,SHIPTOCONTACT,SHIPTOADDRESS'
		
		Declare @Starttime datetime = getutcdate()

		if @Type is null
		begin
			set @Type = upper(@Type)
		end

		drop table if exists #TypeTlb
		Create Table #TypeTlb (ID int identity(1,1) NOT NULL, MainCode nvarchar(20),Code nvarchar(20));
		
		if @Orders = 0 or @Type is null
		begin 
			insert into #TypeTlb (MainCode,Code) select MAINCODE,CODE from [POMS_DB].[dbo].[T_Order_Index_Creation_Type] with (nolock) where IsActive = 1;
		end
		else if @Type = 'ALL'
		begin 
			insert into #TypeTlb (MainCode,Code) select MAINCODE,CODE from [POMS_DB].[dbo].[T_Order_Index_Creation_Type] with (nolock) where IsActive = 1;
		end
		else if @Type = 'ALLCI'
		begin 
			insert into #TypeTlb (MainCode,Code) select MAINCODE,CODE from [POMS_DB].[dbo].[T_Order_Index_Creation_Type] with (nolock) where IsActive = 1 and MAINCODE = @Type;
		end
		else if @Type = 'ALLSF'
		begin 
			insert into #TypeTlb (MainCode,Code) select MAINCODE,CODE from [POMS_DB].[dbo].[T_Order_Index_Creation_Type] with (nolock) where IsActive = 1 and MAINCODE = @Type;
		end
		else if @Type = 'ALLST'
		begin 
			insert into #TypeTlb (MainCode,Code) select MAINCODE,CODE from [POMS_DB].[dbo].[T_Order_Index_Creation_Type] with (nolock) where IsActive = 1 and MAINCODE = @Type;
		end
		else 
		begin 
			insert into #TypeTlb (MainCode,Code) 
			select MAINCODE,CODE from [POMS_DB].[dbo].[T_Order_Index_Creation_Type] with (nolock) where IsActive = 1 
				and MAINCODE in (select distinct id from [POMS_DB].[dbo].[SplitIntoTable](upper(@Type)));
		end
		
		drop table if exists #OrdersList
		Create table #OrdersList (OrderID int)
		if @Orders = 0
		begin
			print datediff(millisecond,@Starttime,getutcdate())
			insert into #OrdersList (OrderID) Select top 200 ORDER_ID from [POMS_DB].[dbo].[T_Order_Additional_Info] with (nolock) where IsIndexUpdated is null
			print datediff(millisecond,@Starttime,getutcdate())
		end
		else
		begin
			insert into #OrdersList (OrderID) Select @Orders
		end

		drop table if exists #OrderDetail
		Create table #OrderDetail 
		(ORDER_ID int
		,[IndexTypeCode] nvarchar(20)
		,[Value] nvarchar(250))
		
		if exists(select * from #TypeTlb)
		begin
			print datediff(millisecond,@Starttime,getutcdate())
			Declare @ClientIdentifiers Table (ORDER_ID int ,OIF_CODE nvarchar(20) ,Value_ nvarchar(250))
			if exists (select * from #TypeTlb where MainCode = 'ALLCI')
			begin
				insert into @ClientIdentifiers (ORDER_ID, OIF_CODE, Value_)
				select ORDER_ID,OIF_CODE,Value_ from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock) where oci.ORDER_ID in (select OrderID from #OrdersList)
				and oci.OIF_CODE in (select replace(CODE,'CI_','') from #TypeTlb where MainCode = 'ALLCI')
			end

			Declare @Records table ([ORDER_ID] int
			,CI_CARRER nvarchar(250)
			,CI_PRO nvarchar(250)
			,CI_TAG nvarchar(250)
			,CI_PONUMBER nvarchar(250)
			,CI_REF2 nvarchar(250)
			,SF_FIRSTNAME nvarchar(250)
			,SF_MIDDLENAME nvarchar(250)
			,SF_LASTNAME nvarchar(250)
			,SF_COMPANY nvarchar(250)
			,SF_ADDRESS nvarchar(250)
			,SF_CONTACTPERSON nvarchar(250)
			,ST_FIRSTNAME nvarchar(250)
			,ST_MIDDLENAME nvarchar(250)
			,ST_LASTNAME nvarchar(250)
			,ST_COMPANY nvarchar(250)
			,ST_ADDRESS nvarchar(250)
			,ST_CONTACTPERSON nvarchar(250))

			insert into @Records ([ORDER_ID] ,CI_CARRER ,CI_PRO ,CI_TAG ,CI_PONUMBER ,CI_REF2 ,SF_FIRSTNAME ,SF_MIDDLENAME ,SF_LASTNAME ,SF_COMPANY ,SF_ADDRESS ,SF_CONTACTPERSON 
				,ST_FIRSTNAME ,ST_MIDDLENAME ,ST_LASTNAME ,ST_COMPANY ,ST_ADDRESS ,ST_CONTACTPERSON)
			select [ORDER_ID]=O.ORDER_ID
			,CI_CARRER=cicarrier.Value_
			,CI_PRO=cipro.Value_
			,CI_TAG=citag.Value_
			,CI_PONUMBER=cipo.Value_
			,CI_REF2=ciref2.Value_
			,SF_FIRSTNAME=O.ShipFrom_FirstName
			,SF_MIDDLENAME=O.ShipFrom_MiddleName
			,SF_LASTNAME=O.ShipFrom_LastName
			,SF_COMPANY=O.ShipFrom_Company
			,SF_ADDRESS=O.ShipFrom_Address
			,SF_CONTACTPERSON=O.ShipFrom_ContactPerson
			,ST_FIRSTNAME=O.ShipTo_FirstName
			,ST_MIDDLENAME=O.ShipTo_MiddleName
			,ST_LASTNAME=O.ShipTo_LastName
			,ST_COMPANY=O.ShipTo_Company
			,ST_ADDRESS=O.ShipTo_Address
			,ST_CONTACTPERSON=O.ShipTo_ContactPerson
			from [POMS_DB].[dbo].[T_Order] O with (nolock) 
			left join @ClientIdentifiers cicarrier on O.ORDER_ID = cicarrier.ORDER_ID and cicarrier.OIF_CODE = 'CARRIER'
			left join @ClientIdentifiers cipro on O.ORDER_ID = cipro.ORDER_ID and cicarrier.OIF_CODE = 'PRO'
			left join @ClientIdentifiers citag on O.ORDER_ID = citag.ORDER_ID and cicarrier.OIF_CODE = 'TAG'
			left join @ClientIdentifiers cipo on O.ORDER_ID = cipo.ORDER_ID and cicarrier.OIF_CODE = 'PONUMBER'
			left join @ClientIdentifiers ciref2 on O.ORDER_ID = ciref2.ORDER_ID and cicarrier.OIF_CODE = 'REF2'
			where O.ORDER_ID in (select OrderID from #OrdersList)
			
			insert into #OrderDetail (ORDER_ID ,[IndexTypeCode] ,[Value])
			select * from (
				SELECT 
					[ORDER_ID],
					[IndexTypeCode],
					[Value]=isnull([Value],'')
				FROM 
					@Records
				UNPIVOT
				(
					[Value] FOR [IndexTypeCode] IN 
					(
						CI_CARRER, CI_PRO, CI_TAG, CI_PONUMBER, CI_REF2,
						SF_FIRSTNAME, SF_MIDDLENAME, SF_LASTNAME, SF_COMPANY, SF_ADDRESS, SF_CONTACTPERSON,
						ST_FIRSTNAME, ST_MIDDLENAME, ST_LASTNAME, ST_COMPANY, ST_ADDRESS, ST_CONTACTPERSON
					)
				) AS UnpivotedData
			) ilv where [IndexTypeCode] in (Select Code from #TypeTlb)
			
			print datediff(millisecond,@Starttime,getutcdate())
		end

		drop table if exists #Table1_ValueChr
		Create table #Table1_ValueChr 
		([ORDER_ID] int,
		[OriginalValue] nvarchar(250),
		[ValueChr] nvarchar(250),
		[Type] nvarchar(20));

		drop table if exists #Table2_ValueChr_2
		Create table #Table2_ValueChr_2 
		([ORDER_ID] int,
		[ValueChr] nvarchar(250),
		[Type] nvarchar(20),
		[Len] int);
	
		drop table if exists #Final_Table3_ValueChr
		Create table #Final_Table3_ValueChr 
		([ORDER_ID] int,
		[ValueChr] nvarchar(250),
		[Type] nvarchar(20));
	
		Declare @MaxRows int = 0
		Declare @CurrentRow int = 0
		select @MaxRows = max(ID) from #TypeTlb
		set @MaxRows = isnull(@MaxRows,0)
		set @CurrentRow=1
		if (@MaxRows > 0)
		begin
			Declare @tmpTemp nvarchar(20) = ''
			while (@CurrentRow <= @MaxRows)
			begin
				set @tmpTemp = ''
				select @tmpTemp = Code from #TypeTlb where ID = @CurrentRow;
				WITH CTE_TMP AS 
				(
					SELECT [ORDER_ID],[Value],(STUFF([Value],1,1,'')) ValueChr FROM #OrderDetail where IndexTypeCode = @tmpTemp
					UNION ALL
					SELECT [ORDER_ID],[Value],(STUFF(ValueChr,1,1,'')) ValueChr FROM CTE_TMP WHERE LEN(ValueChr) > 0
				)
				insert into #Table1_ValueChr (ORDER_ID,OriginalValue,ValueChr,[Type])
				select ORDER_ID,[Value],ValueChr=(case when ValueChr = '' then [Value] else ValueChr end),@tmpTemp from CTE_TMP OPTION (MAXRECURSION 300)
				insert into #Table1_ValueChr (ORDER_ID,OriginalValue,ValueChr,[Type])
				SELECT ORDER_ID,[Value],ValueChr=[Value],@tmpTemp FROM #OrderDetail where IndexTypeCode = @tmpTemp
				
				set @CurrentRow = @CurrentRow + 1
			end
		end

		if exists(select top 1 ORDER_ID from #Table1_ValueChr)
		begin

			insert into #Table2_ValueChr_2 (ORDER_ID,ValueChr,[Type],[Len])
			select Distinct ORDER_ID,ValueChr,[Type],[Len]=len(ValueChr) from #Table1_ValueChr where ValueChr is not null
			drop table if exists #Table1_ValueChr
		
			insert into #Final_Table3_ValueChr (ORDER_ID,ValueChr,[Type])
			select ORDER_ID,ValueChr,[Type] from #Table2_ValueChr_2
		
			print datediff(millisecond,@Starttime,getutcdate())
			print 'Start Loop'
			Declare @TryCount int = 1
			Declare @MaxTryCount int = 0
			set @MaxTryCount = isnull((select max([Len]) from #Table2_ValueChr_2),0)
			while (@TryCount<=@MaxTryCount and @TryCount<=250)
			begin
				insert into #Final_Table3_ValueChr (ORDER_ID,ValueChr,[Type])
				select ORDER_ID,ValueChr=left(ValueChr,@TryCount),[Type] from #Table2_ValueChr_2 where [Len] > @TryCount
				set @TryCount=@TryCount+1
			end

			print datediff(millisecond,@Starttime,getutcdate())
			print 'Start Delete'
			
			drop table if exists #OrderListAndType
			--create table #OrderListAndType (ORDER_ID int, [Type] nvarchar(20))
			select Distinct t.ORDER_ID,t.[Type] into #OrderListAndType from #Table2_ValueChr_2 t
			
			DECLARE @BatchSize INT = 100;
			DECLARE @RowCount INT = 1;
			if 1 = 1--@Orders is null
			begin
				Declare @MaxTimeStamp1 varbinary(50) = null				Select @MaxTimeStamp1 = Max([TimeStamp]) from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Original_Value] with (nolock)
				if exists(select top 1 posov.ORDER_ID from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Original_Value] posov with (nolock) 
					inner join #OrderListAndType t on posov.ORDER_ID = t.ORDER_ID and posov.Type_ = t.[Type])
				begin
					set @BatchSize = 100;
					set @RowCount = 1;
					WHILE @RowCount > 0
					BEGIN
						delete TOP (@BatchSize) posov from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Original_Value] posov
						inner join #OrderListAndType t on posov.ORDER_ID = t.ORDER_ID and posov.Type_ = t.[Type]

						SET @RowCount = @@ROWCOUNT;

						-- Add a delay if needed
						--WAITFOR DELAY '00:00:01'; -- 1-second delay, adjust as needed
					END
					
				end
				
				if exists(select top 1 posvc.ORDER_ID from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Value_Character] posvc with (nolock) 
					inner join #OrderListAndType t on posvc.ORDER_ID = t.ORDER_ID and posvc.Type_ = t.[Type])
				begin
					Declare @MaxTimeStamp varbinary(50) = null					Select @MaxTimeStamp = Max([TimeStamp]) from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Value_Character] with (nolock)
					set @BatchSize = 100;
					set @RowCount = 1;
					WHILE @RowCount > 0
					BEGIN
						delete TOP (@BatchSize) posvc from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Value_Character] posvc
						inner join #OrderListAndType t on posvc.ORDER_ID = t.ORDER_ID and posvc.Type_ = t.[Type] and posvc.[TimeStamp] < @MaxTimeStamp

						SET @RowCount = @@ROWCOUNT;

						-- Add a delay if needed
						--WAITFOR DELAY '00:00:01'; -- 1-second delay, adjust as needed
					END
					
				end
				
				print datediff(millisecond,@Starttime,getutcdate())
				print 'Start Insert'
				insert into [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Original_Value] (ORDER_ID,OriginalValue,[Type_])
				select distinct od.ORDER_ID,od.[Value],od.IndexTypeCode from #OrderDetail od 
				where od.ORDER_ID not in (select posov.ORDER_ID from [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Original_Value] posov with (nolock) where posov.[TimeStamp] > @MaxTimeStamp1)  
				order by od.ORDER_ID
				
				insert into [PinnacleIndexDB].[dbo].[T_POMS_Orders_Search_Value_Character] (ORDER_ID,ValChr,[Type_])
				select distinct ORDER_ID,ValueChr,[Type] from #Final_Table3_ValueChr order by ORDER_ID, [Type]
				print datediff(millisecond,@Starttime,getutcdate())
				print 'Start Update'
				
				if exists(select oai.ORDER_ID from [POMS_DB].[dbo].[T_Order_Additional_Info] oai with (nolock) where isnull(oai.IsIndexUpdated,0) = 0 and oai.ORDER_ID in (select t.ORDER_ID from #OrderListAndType t))
				begin
					set @BatchSize = 100;
					set @RowCount = 1;
					WHILE @RowCount > 0
					BEGIN
						update TOP (@BatchSize) oai set 
							oai.IsIndexUpdated = 1 
						from [POMS_DB].[dbo].[T_Order_Additional_Info] oai where isnull(oai.IsIndexUpdated,0) = 0 and oai.ORDER_ID in (select t.ORDER_ID from #OrderListAndType t)

						SET @RowCount = @@ROWCOUNT;

						-- Add a delay if needed
						--WAITFOR DELAY '00:00:01'; -- 1-second delay, adjust as needed
					END

				end
			end
			print datediff(millisecond,@Starttime,getutcdate())
			print 'All Done'
		end
	end try
	begin catch
		--select ERROR_MESSAGE()
	end catch
	
END
GO
