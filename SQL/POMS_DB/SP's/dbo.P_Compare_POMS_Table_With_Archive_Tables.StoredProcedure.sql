USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Compare_POMS_Table_With_Archive_Tables]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Compare_POMS_Table_With_Archive_Tables]
-- =============================================
CREATE PROCEDURE [dbo].[P_Compare_POMS_Table_With_Archive_Tables]
	
AS
BEGIN
	
	drop table if exists #POMSTableColumns
	SELECT * into #POMSTableColumns FROM [POMS_DB].INFORMATION_SCHEMA.COLUMNS

	drop table if exists #POMSArchiveTableColumns
	SELECT * into #POMSArchiveTableColumns FROM [POMSArchive_DB].INFORMATION_SCHEMA.COLUMNS

	select TABLE_SCHEMA ,TABLE_NAME ,COLUMN_NAME ,COLUMN_DEFAULT ,IS_NULLABLE ,DATA_TYPE ,CHARACTER_MAXIMUM_LENGTH ,CHARACTER_OCTET_LENGTH ,NUMERIC_PRECISION ,NUMERIC_PRECISION_RADIX ,NUMERIC_SCALE ,DATETIME_PRECISION
	,CHARACTER_SET_CATALOG ,CHARACTER_SET_SCHEMA ,CHARACTER_SET_NAME ,COLLATION_CATALOG ,COLLATION_SCHEMA ,COLLATION_NAME ,DOMAIN_CATALOG ,DOMAIN_SCHEMA ,DOMAIN_NAME from #POMSTableColumns ptc
	where ptc.TABLE_NAME in (select patc.TABLE_NAME from #POMSArchiveTableColumns patc) --and ptc.TABLE_NAME = 'T_Order_Items_Additional_Info' order by COLUMN_NAME
	
	except
	
	select TABLE_SCHEMA ,TABLE_NAME ,COLUMN_NAME ,COLUMN_DEFAULT ,IS_NULLABLE ,DATA_TYPE ,CHARACTER_MAXIMUM_LENGTH ,CHARACTER_OCTET_LENGTH ,NUMERIC_PRECISION ,NUMERIC_PRECISION_RADIX ,NUMERIC_SCALE ,DATETIME_PRECISION
	,CHARACTER_SET_CATALOG ,CHARACTER_SET_SCHEMA ,CHARACTER_SET_NAME ,COLLATION_CATALOG ,COLLATION_SCHEMA ,COLLATION_NAME ,DOMAIN_CATALOG ,DOMAIN_SCHEMA ,DOMAIN_NAME from #POMSArchiveTableColumns patc
	--where patc.TABLE_NAME = 'T_Order' order by COLUMN_NAME

END
GO
