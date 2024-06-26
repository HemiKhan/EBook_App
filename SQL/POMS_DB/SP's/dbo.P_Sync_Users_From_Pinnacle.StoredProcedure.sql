USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_Users_From_Pinnacle]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_Users_From_Pinnacle]
	
AS
BEGIN
	
	Begin Transaction

	begin try
		Declare @Marker varbinary(50) = null		Select @Marker = Max([TimeStamp]) from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] with (nolock) where TableName = 'T_Users'		Declare  @Pinnacle_WebUsersTable TABLE (			[TimeStamp] [varbinary](50) NOT NULL,			[Web UserID] [int] NOT NULL,
			[Username] [nvarchar](25) NOT NULL,
			[UserType_MTV_CODE] [nvarchar](20) NOT NULL,
			[Entity type] [int] NOT NULL,
			[Password Hash] [nvarchar](200) NOT NULL,
			[Password Salt] [nvarchar](200) NOT NULL,
			[Department] [int] NOT NULL,
			[Designation] [nvarchar](30) NOT NULL,
			[First Name] [nvarchar](50) NOT NULL,
			[Middle Name] [nvarchar](50) NOT NULL,
			[Last Name] [nvarchar](50) NOT NULL,
			[Company Name] [nvarchar](50) NOT NULL,
			[Address] [nvarchar](50) NOT NULL,
			[Address 2] [nvarchar](50) NOT NULL,
			[City] [nvarchar](30) NOT NULL,
			[State] [nvarchar](30) NOT NULL,
			[Pincode] [nvarchar](20) NOT NULL,
			[Country] [nvarchar](10) NOT NULL,
			[E-Mail] [nvarchar](80) NOT NULL,
			[Mobile] [nvarchar](30) NOT NULL,
			[Phone] [nvarchar](30) NOT NULL,
			[PhoneExt] [nvarchar](30) NOT NULL,
			[Security Question] [int] NOT NULL,
			[Securtiy Answer] [nvarchar](250) NOT NULL,
			[Time Zone ID] [int] NOT NULL,
			[Approved] [tinyint] NOT NULL,
			[Blocked] [int] NOT NULL,
			[APIAccess] [bit] NOT NULL,
			[ROLE_ID] [int] NOT NULL,
			[SELLER_CODE] [nvarchar](20) NOT NULL,
			[Dynamics UserName] [nvarchar](150) NOT NULL,
			[Order System Access] [bit] NOT NULL,
			[Dispatch System Access] [bit] NOT NULL,
			[Driver App Access] [bit] NOT NULL,
			[Warehouse Access] [bit] NOT NULL
		);		insert into @Pinnacle_WebUsersTable ([TimeStamp], [Web UserID] ,[Username] ,[UserType_MTV_CODE] ,[Entity type] ,[Password Hash] ,[Password Salt] ,[Department] ,[Designation] ,[First Name] 
			,[Middle Name] ,[Last Name] ,[Company Name] ,[Address] ,[Address 2] ,[City] ,[State] ,[Pincode] ,[Country] ,[E-Mail] ,[Mobile] ,[Phone] ,[PhoneExt]  ,[Security Question] ,[Securtiy Answer] 
			,[Time Zone ID] ,[Approved] ,[Blocked] ,[APIAccess] ,[ROLE_ID] ,[SELLER_CODE] ,[Dynamics UserName] ,[Order System Access] ,[Dispatch System Access] ,[Driver App Access] ,[Warehouse Access])		select [timestamp], [Web UserID] ,[Username]=upper([Username]) 
		,[UserType_MTV_CODE]=(case when [Entity type] = 1 then 'CLIENT-USER' when [Entity type] = 2 then 'METRO-USER' when [Entity type] = 3 then 'COD-USER' when [Entity type] = 4 then 'GUEST-USER' else '' end)
		,[Entity type] ,[Password Hash] ,[Password Salt] 
		,[Department] = (case when [Department] = 0 then 1 when [Department] = 10000 then 2 when [Department] = 20000 then 3 when [Department] = 30000 then 4
			when [Department] = 40000 then 5 when [Department] = 50000 then 6 when [Department] = 60000 then 7 else 0 end)
		,[Designation] ,[First Name] 
		,[Middle Name] = '' ,[Last Name] ,[Company Name] ,[Address] ,[Address 2] ,[City] ,[State] ,[Pincode] ,[Country] ,[E-Mail] ,[Mobile] ,wph.[PhoneNo] ,wph.[Extension]
		,[Security Question] = (case when [Security Question] = 1 then 150100 when [Security Question] = 2 then 150101 when [Security Question] = 3 then 150102			when [Security Question] = 4 then 150103 when [Security Question] = 5 then 150104 else 0 end)		,[Securtiy Answer] ,[Time Zone ID] ,[Approved] ,[Blocked] = (case when Blocked = 0 then 149100  when Blocked = 1 then 149101 else 0 end)		,[APIAccess]
		,[ROLE_ID]=(case when [Web Role] = 'ACCOUNTING' then 1
			when [Web Role] = 'ACC SUPERVISOR' then 2
			when [Web Role] = 'ACC USER' then 3
			when [Web Role] = 'CODL' then 4
			when [Web Role] = 'CSR' then 5
			when [Web Role] = 'CSR SUPERVISOR' then 6
			when [Web Role] = 'CSR USER' then 7
			when [Web Role] = 'DISPATCH' then 8
			when [Web Role] = 'DIS SUPERVISOR' then 9
			when [Web Role] = 'DIS USER' then 10
			when [Web Role] = 'DL' then 11
			when [Web Role] = 'METRO' then 12
			when [Web Role] = 'OED' then 13
			when [Web Role] = 'OED SUPERVISOR' then 14
			when [Web Role] = 'OED USER' then 15
			when [Web Role] = 'SUPER' then 16
			when [Web Role] = 'WAREHOUSE' then 17
			when [Web Role] = 'WR SUPERVISOR' then 18
			when [Web Role] = 'WR USER' then 19
			when [Web Role] = 'CA' then 20
			when [Web Role] = 'CU' then 21
			else 0 end)		,[Dynamics UserName]		,[SELLER_CODE]=replace([Customer No_],'C','S')
		,[Order System Access]
		,[Dispatch System Access]
		,[Driver App Access]
		,[Warehouse Access]
		from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] wul with (nolock) 		cross apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt] (wul.[Phone]) wph
		where wul.[timestamp] > @Marker or @Marker is null		Declare @POMS_UserTable table (			[USER_ID] [int] NOT NULL,
			[USERNAME] [nvarchar](50) NOT NULL,
			[UserType_MTV_CODE] [nvarchar](20) NOT NULL,
			[PasswordHash] [nvarchar](250) NOT NULL,
			[PasswordSalt] [nvarchar](250) NOT NULL,
			[D_ID] [int] NOT NULL,
			[Designation] [nvarchar](150) NOT NULL,
			[FirstName] [nvarchar](50) NULL,
			[MiddleName] [nvarchar](50) NULL,
			[LastName] [nvarchar](50) NULL,
			[Company] [nvarchar](250) NULL,
			[Address] [nvarchar](250) NULL,
			[Address2] [nvarchar](250) NULL,
			[City] [nvarchar](50) NULL,
			[State] [nvarchar](5) NULL,
			[ZipCode] [nvarchar](10) NULL,
			[Country] [nvarchar](50) NULL,
			[Email] [nvarchar](250) NULL,
			[Mobile] [nvarchar](30) NULL,
			[Phone] [nvarchar](20) NULL,
			[PhoneExt] [nvarchar](10) NULL,
			[SecurityQuestion_MTV_ID] [int] NOT NULL,
			[EncryptedAnswer] [nvarchar](250) NOT NULL,
			[TIMEZONE_ID] [int] NOT NULL,
			[IsApproved] [bit] NOT NULL,
			[BlockType_MTV_ID] [int] NOT NULL,
			[IsAPIUser] [bit] NOT NULL,
			[ROLE_ID] [int] NOT NULL,
			[SELLER_CODE] [nvarchar](20) NOT NULL,
			[Dynamics UserName] [nvarchar](150) NOT NULL,
			[Order System Access] [bit] NOT NULL,
			[Dispatch System Access] [bit] NOT NULL,
			[Driver App Access] [bit] NOT NULL,
			[Warehouse Access] [bit] NOT NULL
		)		insert into @POMS_UserTable ([USER_ID] ,[USERNAME] ,[UserType_MTV_CODE] ,[PasswordHash] ,[PasswordSalt] ,[D_ID] ,[Designation] ,[FirstName] ,[MiddleName] ,[LastName] 
			,[Company] ,[Address] ,[Address2] ,[City] ,[State] ,[ZipCode] ,[Country] ,[Email] ,[Mobile] ,[Phone] ,[PhoneExt] ,[SecurityQuestion_MTV_ID] ,[EncryptedAnswer] ,[TIMEZONE_ID] 			,[IsApproved] ,[BlockType_MTV_ID] ,IsAPIUser ,[ROLE_ID] ,[SELLER_CODE] ,[Dynamics UserName] ,[Order System Access] ,[Dispatch System Access] ,[Driver App Access] ,[Warehouse Access])		select [Web UserID] ,[Username] ,[UserType_MTV_CODE] ,[Password Hash] ,[Password Salt] ,[Department] ,[Designation] ,[First Name] ,[Middle Name] ,[Last Name] ,[Company Name] 
			,[Address] ,[Address 2] ,[City] ,[State]=left([State],2) ,[Pincode] ,[Country] ,[E-Mail] ,[Mobile] ,[Phone] ,[PhoneExt] ,[Security Question] ,[Securtiy Answer] ,[Time Zone ID] 			,[Approved], Blocked ,[APIAccess] ,[ROLE_ID] ,[SELLER_CODE] ,[Dynamics UserName] ,[Order System Access] ,[Dispatch System Access] ,[Driver App Access] ,[Warehouse Access]			from @Pinnacle_WebUsersTable 		SET IDENTITY_INSERT [POMS_DB].[dbo].[T_Users] ON 
		MERGE [POMS_DB].[dbo].[T_Users] AS Target			USING @POMS_UserTable AS Source			ON Source.[USERNAME] = Target.[USERNAME]    			-- For Inserts			WHEN NOT MATCHED BY Target THEN				INSERT ([USER_ID] 
				,[USERNAME] 
				,[UserType_MTV_CODE] 
				,[PasswordHash] 
				,[PasswordSalt] 
				,[D_ID] 
				,[Designation] 
				,[FirstName] 
				,[MiddleName] 
				,[LastName] 
				,[Company] 
				,[Address] 
				,[Address2] 
				,[City] 
				,[State] 
				,[ZipCode] 
				,[Country] 
				,[Email] 
				,[Mobile] 
				,[Phone] 
				,[PhoneExt] 
				,[SecurityQuestion_MTV_ID] 
				,[EncryptedAnswer] 
				,[TIMEZONE_ID] 				,[IsApproved] 				,[BlockType_MTV_ID]				,IsAPIUser				,AddedBy) 				VALUES (Source.[USER_ID] 
				,Source.[USERNAME] 
				,Source.[UserType_MTV_CODE] 
				,Source.[PasswordHash] 
				,Source.[PasswordSalt] 
				,Source.[D_ID] 
				,Source.[Designation] 
				,Source.[FirstName] 
				,Source.[MiddleName] 
				,Source.[LastName] 
				,Source.[Company] 
				,Source.[Address] 
				,Source.[Address2] 
				,Source.[City] 
				,Source.[State] 
				,Source.[ZipCode] 
				,Source.[Country] 
				,Source.[Email] 
				,Source.[Mobile] 
				,Source.[Phone] 
				,Source.[PhoneExt] 
				,Source.[SecurityQuestion_MTV_ID] 
				,Source.[EncryptedAnswer] 
				,Source.[TIMEZONE_ID] 				,Source.[IsApproved] 				,Source.[BlockType_MTV_ID]				,Source.IsAPIUser				,'AUTOSYNC')			-- For Updates			WHEN MATCHED THEN 				UPDATE SET				--Target.[USER_ID]				= Source.[USER_ID],
				Target.[USERNAME]				= Source.[USERNAME] 
				,Target.[UserType_MTV_CODE]		= Source.[UserType_MTV_CODE] 
				,Target.[PasswordHash]			= Source.[PasswordHash] 
				,Target.[PasswordSalt]			= Source.[PasswordSalt] 
				,Target.[D_ID]					= Source.[D_ID] 
				,Target.[Designation]			= Source.[Designation] 
				,Target.[FirstName]				= Source.[FirstName] 
				,Target.[MiddleName]			= Source.[MiddleName] 
				,Target.[LastName]				= Source.[LastName] 
				,Target.[Company]				= Source.[Company] 
				,Target.[Address]				= Source.[Address] 
				,Target.[Address2]				= Source.[Address2] 
				,Target.[City]					= Source.[City] 
				,Target.[State]					= Source.[State] 
				,Target.[ZipCode]				= Source.[ZipCode] 
				,Target.[Country]				= Source.[Country] 
				,Target.[Email]					= Source.[Email] 
				,Target.[Mobile]				= Source.[Mobile] 
				,Target.[Phone]					= Source.[Phone] 
				,Target.[PhoneExt]				= Source.[PhoneExt] 
				,Target.[SecurityQuestion_MTV_ID]	= Source.[SecurityQuestion_MTV_ID] 
				,Target.[EncryptedAnswer]		= Source.[EncryptedAnswer] 
				,Target.[TIMEZONE_ID]			= Source.[TIMEZONE_ID] 				,Target.[IsApproved]			= Source.[IsApproved] 				,Target.[BlockType_MTV_ID]		= Source.[BlockType_MTV_ID]				,Target.IsAPIUser				= Source.IsAPIUser				,Target.ModifiedBy				= 'AUTOSYNC'				,Target.ModifiedOn				= getutcdate();
		MERGE [POMS_DB].[dbo].[T_User_Role_Mapping] AS Target			USING @POMS_UserTable AS Source			ON Source.[USERNAME] = Target.[USERNAME]    			-- For Inserts			WHEN NOT MATCHED BY Target THEN				INSERT ([USERNAME]
				,[ROLE_ID]
				,[IsGroupRoleID]
				,AddedBy) 				VALUES (Source.[USERNAME] 
				,Source.[ROLE_ID]				,0				,'AUTOSYNC')			-- For Updates			WHEN MATCHED THEN 				UPDATE SET				Target.[ROLE_ID]				= Source.[ROLE_ID] 
				,Target.[IsGroupRoleID]			= 0 
				,Target.ModifiedBy				= 'AUTOSYNC'				,Target.ModifiedOn				= getutcdate();
				MERGE [POMS_DB].[dbo].[T_User_Application_Access] AS Target			USING @POMS_UserTable AS Source			ON Source.[USERNAME] = Target.[USERNAME] and Target.Application_MTV_ID = 148104    			-- For Inserts			WHEN NOT MATCHED BY Target THEN				INSERT (USERNAME
				,Application_MTV_ID
				,IsActive
				,AddedBy) 				VALUES (Source.[USERNAME] 
				,148104				,Source.[Order System Access]				,'AUTOSYNC')			-- For Updates			WHEN MATCHED THEN 				UPDATE SET				Target.IsActive					= Source.[Order System Access] 
				,Target.ModifiedBy				= 'AUTOSYNC'				,Target.ModifiedOn				= getutcdate();

		MERGE [POMS_DB].[dbo].[T_User_Application_Access] AS Target			USING @POMS_UserTable AS Source			ON Source.[USERNAME] = Target.[USERNAME] and Target.Application_MTV_ID = 148105    			-- For Inserts			WHEN NOT MATCHED BY Target THEN				INSERT (USERNAME
				,Application_MTV_ID
				,IsActive
				,AddedBy) 				VALUES (Source.[USERNAME] 
				,148105				,Source.[Dispatch System Access]				,'AUTOSYNC')			-- For Updates			WHEN MATCHED THEN 				UPDATE SET				Target.IsActive					= Source.[Dispatch System Access] 
				,Target.ModifiedBy				= 'AUTOSYNC'				,Target.ModifiedOn				= getutcdate();
				MERGE [POMS_DB].[dbo].[T_User_Application_Access] AS Target			USING @POMS_UserTable AS Source			ON Source.[USERNAME] = Target.[USERNAME] and Target.Application_MTV_ID = 148108    			-- For Inserts			WHEN NOT MATCHED BY Target THEN				INSERT (USERNAME
				,Application_MTV_ID
				,IsActive
				,AddedBy) 				VALUES (Source.[USERNAME] 
				,148108				,Source.[Driver App Access]				,'AUTOSYNC')			-- For Updates			WHEN MATCHED THEN 				UPDATE SET				Target.IsActive					= Source.[Driver App Access] 
				,Target.ModifiedBy				= 'AUTOSYNC'				,Target.ModifiedOn				= getutcdate();
		MERGE [POMS_DB].[dbo].[T_User_Application_Access] AS Target			USING @POMS_UserTable AS Source			ON Source.[USERNAME] = Target.[USERNAME] and Target.Application_MTV_ID = 148107    			-- For Inserts			WHEN NOT MATCHED BY Target THEN				INSERT (USERNAME
				,Application_MTV_ID
				,IsActive
				,AddedBy) 				VALUES (Source.[USERNAME] 
				,148107				,Source.[Warehouse Access]				,'AUTOSYNC')			-- For Updates			WHEN MATCHED THEN 				UPDATE SET				Target.IsActive					= Source.[Warehouse Access] 
				,Target.ModifiedBy				= 'AUTOSYNC'				,Target.ModifiedOn				= getutcdate();
						Select @Marker = Max([TimeStamp]) from @Pinnacle_WebUsersTable		update [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] set [TimeStamp] = @Marker where TableName = 'T_Users' and @Marker is not null
		if @@TRANCOUNT > 0
		begin
			COMMIT; 
		end
	end try
	begin catch
		if @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		print ERROR_MESSAGE()
	end catch

END
GO
