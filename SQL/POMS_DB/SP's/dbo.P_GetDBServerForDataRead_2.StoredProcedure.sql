USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetDBServerForDataRead_2]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_GetDBServerForDataRead_2] 'SEND_RODB_DISPATCH'
create PROCEDURE [dbo].[P_GetDBServerForDataRead_2]
	@Config_Key nvarchar(150) = null
  
AS  
  
BEGIN  
  
	Declare @IsReadOnlyServerActive int = 0

	if (@Config_Key = '')
	begin
		set @Config_Key = null
	end

	select @IsReadOnlyServerActive = [Val_num] from [PPlus_DB].[dbo].[T_Config] with (nolock) where [Config_Key] = 'IS_READONLY_SERVER_ACTIVE'

	if @Config_Key is not null and @IsReadOnlyServerActive = 1
	begin
		select @IsReadOnlyServerActive = [Val_num] from [PPlus_DB].[dbo].[T_Config] with (nolock) where [Config_Key] = @Config_Key
		set @IsReadOnlyServerActive = isnull(@IsReadOnlyServerActive,1)
	end

	if @IsReadOnlyServerActive = 1
	begin
		select top 1 [ServerRole] = case when ar.replica_server_name like '%01' then 'PRIMARY' else 'SECONDARY' end--, ar.replica_server_name, rs.role_desc  
		from sys.dm_hadr_availability_replica_states rs  
		join sys.availability_replicas ar on ar.replica_id = rs.replica_id  
		where rs.connected_state != 0  and synchronization_health = 2
		order by [role] desc  
	end
	else
	begin
		select [ServerRole] = 'PRIMARY'
	end
  
	select [ServerRole] = 'PRIMARY'

END


GO
