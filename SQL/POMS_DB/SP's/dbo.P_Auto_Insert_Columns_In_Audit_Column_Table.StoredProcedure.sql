USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Auto_Insert_Columns_In_Audit_Column_Table]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Auto_Insert_Columns_In_Audit_Column_Table]

AS
BEGIN
	
	drop table if exists #oldtmptablecolumn
	select * into #oldtmptablecolumn from (
		SELECT AC_ID, [TableName] ,[DbName] ,[ConcTableAndColumnName]=([TableName] + ' (' + [DbName] + ')')
		FROM [POMS_DB].[dbo].[T_Audit_Column] with (nolock)
	) ilv
	
	drop table if exists #newtmptablecolumn
	SELECT [Table Name]=ilv.[TABLE_NAME], [Column Name] = ilv.COLUMN_NAME, [Conc Table Column Name] = (ilv.[TABLE_NAME] + ' (' + ilv.[COLUMN_NAME] + ')') into #newtmptablecolumn FROM (
		SELECT isc.[TABLE_NAME],COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS isc
		inner join INFORMATION_SCHEMA.TABLES ist on isc.[TABLE_NAME] = ist.[TABLE_NAME] and ist.TABLE_TYPE = 'BASE TABLE' and ist.[TABLE_NAME] <> 'T_Audit_Column' 
		and isc.COLUMN_NAME not in ('TimeStamp','CreatedBy','CreatedOn','AddedBy','AddedOn','ModifiedBy','ModifiedOn','OrderID','OrderNo','OrderNoGUID')
	) ilv

	insert into [POMS_DB].[dbo].[T_Audit_Column] ([TableName],[DbName],[Name],[AddedBy])
	select [Table Name] ,[Column Name] ,[Column Name] ,'AUTOIMPORT' from #newtmptablecolumn A
	where A.[Conc Table Column Name] not in (Select B.[ConcTableAndColumnName] from #oldtmptablecolumn B)

	drop table if exists #deleteACIDs
	select * into #deleteACIDs from [POMS_DB].[dbo].[T_Audit_Column] au with (nolock)
	where (au.[TableName] + ' (' + au.[DbName] + ')') not in (select n.[Conc Table Column Name] from #newtmptablecolumn n)
	and au.AC_ID not in (select ah.AC_ID from [POMS_DB].[dbo].[T_Audit_History] ah with (nolock))

	delete from [POMS_DB].[dbo].[T_Audit_Column] where AC_ID in (select d.AC_ID from #deleteACIDs d)

END
GO
