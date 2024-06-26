USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Client_Service_Type_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Client_Service_Type_List] (125100, '42A988E7-12FA-48B6-BF38-EF900E6ED9AB', 0 , 'S100052','GlobalTranz',null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Client_Service_Type_List]
(	
	@Type_MTV_ID int
	,@SELLER_KEY nvarchar(36)
	,@IsAll bit = 0
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(250) = null
	,@ST_CODE nvarchar(max) = null
)
returns @ReturnTable table
(ID int identity(1,1)
,SellerKey nvarchar(36)
,SellerCode nvarchar(20)
,SellerName nvarchar(250)
,Required_CODE nvarchar(50)
,ST_CODE nvarchar(20)
,ServiceName nvarchar(100)
,SST_CODE nvarchar(20)
,SubServiceName nvarchar(100)
,ServiceLevelDetails nvarchar(max)
,Type_MTV_ID int
,[Type_Name] nvarchar(100)
,IsDefault bit
,IsActive bit
,IsAllowed bit
)
AS
Begin

	set @SELLER_KEY = isnull(@SELLER_KEY,'')

	DECLARE @ListOf_ST_CODE TABLE (ST_CODE nvarchar(20));
	if @ST_CODE is not null
	begin
		insert into @ListOf_ST_CODE(ST_CODE) 
		select id from [dbo].SplitIntoTable(@ST_CODE);
	end

	Declare @SellerTable table (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250))
	
	if @SELLER_CODE is null
	begin
		insert into @SellerTable
		select SellerKey , SellerCode , SellerName  from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SELLER_KEY,null)
	end
	else
	begin
		insert into @SellerTable
		select @SELLER_KEY, @SELLER_CODE, @SELLER_NAME
	end

	Declare @CONFIG_TYPE nvarchar(50) = ''
	Declare @Default_ST_CODE nvarchar(20) = ''
	Declare @Default_SST_CODE nvarchar(20) = ''
	Declare @TypeName nvarchar(150) = ''
	
	if (@ST_CODE is null)
	begin
		set @CONFIG_TYPE = (case when @Type_MTV_ID = 125100 then 'PICKUP_ST_CODE'
		when @Type_MTV_ID = 125101 then 'DELIVERY_FORWARD_ST_CODE'
		when @Type_MTV_ID = 125102 then 'DELIVERY_REVERSE_ST_CODE'
		else '' end)
	
		select @Default_ST_CODE = REFNO1, @Default_SST_CODE = REFNO2 from [POMS_DB].[dbo].[T_Client_Default_Value_Setup] with (nolock) 
		where SELLER_CODE in (select SellerCode from @SellerTable) and CONFIG_TYPE = @CONFIG_TYPE 

		if (isnull(@Default_ST_CODE,'') = '')
		begin
			select @Default_ST_CODE = REFNO1, @Default_SST_CODE = REFNO2 from [POMS_DB].[dbo].[T_Default_Value_Setup] with (nolock) 
			where CONFIG_TYPE = @CONFIG_TYPE 
		end

		set @Default_ST_CODE = isnull(@Default_ST_CODE,'')
		set @Default_SST_CODE = isnull(@Default_SST_CODE,'')
	end

	if @Type_MTV_ID is not null
	begin
		select top 1 @TypeName = [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = @Type_MTV_ID
		set @TypeName = isnull(@TypeName,'')
	end

	insert into @ReturnTable 
	select ilv2.SellerKey
	,ilv2.SellerCode
	,ilv2.SellerName
	,Required_CODE = (case when ilv2.SST_CODE = '' then ilv2.ST_CODE else ilv2.ST_CODE + '-' + ilv2.SST_CODE end)
	,ilv2.ST_CODE
	,ilv2.ServiceName
	,ilv2.SST_CODE
	,ilv2.SubServiceName
	,[ServiceLevelDetails]=(case when ilv2.[ServiceLevelDetails] is null then '' else left(([ServiceLevelDetails]),len([ServiceLevelDetails])-1) end)
	,ilv2.Type_MTV_ID
	,ilv2.[Type_Name]
	,IsDefault = (case when @Default_ST_CODE = ilv2.ST_CODE and @Default_SST_CODE = ilv2.SST_CODE then 1 else 0 end)
	,ilv2.IsActive 
	,IsAllowed=isnull(cst.IsAllowed,ilv2.IsAllowed)
	from (select ilv.SellerKey
	,ilv.SellerCode
	,ilv.SellerName
	,ilv.ST_CODE
	,ilv.ServiceName
	,SST_CODE=isnull(sst.SST_CODE,'')
	,SubServiceName=isnull(sst.SubServiceName,'')
	,[ServiceLevelDetails]=(Select [ServiceDetail] + '; ' AS [text()] From [POMS_DB].[dbo].[T_Service_Type_Detail] std with(nolock) 
		Where std.SST_CODE = isnull(sst.SST_CODE,'') and std.ST_CODE = ilv.ST_CODE and std.[IsActive] = 1 order by std.Sort_ For XML Path(''), TYPE).value('.', 'nvarchar(MAX)')
	,ilv.Type_MTV_ID
	,ilv.[Type_Name]
	,ilv.IsActive
	,ilv.IsAllowed
	,ilv.MainSort_
	,SubSort_=sst.Sort_
	from (Select c.SellerKey
	,c.SellerCode
	,c.SellerName
	,st.ST_CODE
	,st.ServiceName
	,st.Type_MTV_ID
	,[Type_Name] = isnull((case when @TypeName = '' then (select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = st.Type_MTV_ID)
		else @TypeName end),'')
	,MainSort_=st.Sort_
	,st.IsActive
	,st.IsAllowed
	FROM [POMS_DB].[dbo].[T_Service_Type] st with (nolock)
	cross apply @SellerTable c 
	where st.IsActive = 1 
	and (st.Type_MTV_ID = @Type_MTV_ID or @Type_MTV_ID is null)
	and (st.ST_CODE in (select * from @ListOf_ST_CODE) or @ST_CODE is null)
	) ilv left join [POMS_DB].[dbo].[T_Sub_Service_Type] sst with (nolock) on ilv.ST_CODE = sst.ST_CODE and sst.IsActive = 1
	) ilv2 left join [POMS_DB].[dbo].[T_Client_Service_Type] cst with (nolock) on ilv2.ST_CODE = cst.ST_CODE and ilv2.SellerCode = cst.SELLER_CODE
	where (isnull(cst.IsAllowed,ilv2.IsAllowed) = 1 or @IsAll = 1)
	order by ilv2.Type_MTV_ID,ilv2.MainSort_,ilv2.SubSort_

	return

end
GO
