USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_AirPort_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[P_AddOrEdit_AirPort_List] 
   @AL_ID             INT,
  @Name              NVARCHAR(500),
  @Number            NVARCHAR(40),
  @Address           NVARCHAR(500),
  @Address2          NVARCHAR(500),
  @City              NVARCHAR(100),
  @State             NVARCHAR(10),
  @ZipCode           NVARCHAR(10),
  @County            NVARCHAR(100),
  @CountryRegionCode NVARCHAR(20),
  @Active            BIT,
  @Username          NVARCHAR(150),
  @IPAddress         NVARCHAR(20) =NULL
AS
  BEGIN
      DECLARE @maxSortValue INT
      DECLARE @Return_Code BIT = 1
      DECLARE @Return_Text NVARCHAR(1000) = ''
      DECLARE @AIRPORT_CODE NVARCHAR(20) = ''

      SELECT @AIRPORT_CODE = AL_ID
      FROM   [POMS_DB].[dbo].[T_AirPort_List] WITH (nolock)
      WHERE  airport_code = @AIRPORT_CODE

      SET @AIRPORT_CODE = Isnull(@AIRPORT_CODE, '')

      IF @AL_ID > 0
        BEGIN
            IF @AIRPORT_CODE <> ''
              BEGIN
                  DECLARE @OldName NVARCHAR(500)
                  DECLARE @OldNumber NVARCHAR(40)
                  DECLARE @OldAddress NVARCHAR(500)
                  DECLARE @OldAddress2 NVARCHAR(500)
                  DECLARE @OldCity NVARCHAR(100)
                  DECLARE @OldState NVARCHAR(10)
                  DECLARE @OldZipCode NVARCHAR(10)
                  DECLARE @OldCounty NVARCHAR(100)
                  DECLARE @OldCountryRegionCode NVARCHAR(20)
                  DECLARE @OldActive BIT

                  SELECT @OldActive = isactive,
                         @OldName = [name],
                         @OldNumber = number,
                         @OldAddress = [address],
                         @OldAddress2 = address2,
                         @OldCity = city,
                         @OldState = state,
                         @OldZipCode = zipcode,
                         @OldCounty = county,
                         @OldCountryRegionCode = countryregioncode,
                         @OldActive = isactive
                  FROM   [POMS_DB].[dbo].[T_AirPort_List] WITH (nolock)
                  WHERE  al_id = @AL_ID;

                  UPDATE [POMS_DB].[dbo].[T_AirPort_List]
                  SET    [Name] = @Name,
                         Number = @Number,
                         [Address] = @Address,
                         Address2 = @Address2,
                         City = @City,
                         [State] = @State,
                         ZipCode = @ZipCode,
                         County = @County,
                         CountryRegionCode = @CountryRegionCode,
                         IsActive= @Active,
                         ModifiedBy = @Username,
                         ModifiedOn = Getutcdate()
                  WHERE  AL_ID = @AL_ID;

                  IF @OldName <> @Name
                    BEGIN
                        EXEC P_add_audit_history
                          'Name',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                          @AIRPORT_CODE,
                          '',
                          @OldName,
                          @Name,
                          @OldName,
                          @Name,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldNumber <> @Number
                    BEGIN
                        EXEC P_add_audit_history
                          'Number',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                           @AIRPORT_CODE,
                          '',
                          @OldNumber,
                          @Number,
                          @OldNumber,
                          @Number,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldAddress <> @Address
                    BEGIN
                        EXEC P_add_audit_history
                          'Address',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                          @AIRPORT_CODE,
                          '',
                          @OldAddress,
                          @Address,
                          @OldAddress,
                          @Address,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldAddress2 <> @Address2
                    BEGIN
                        EXEC P_add_audit_history
                          'Address2',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                          @AIRPORT_CODE,
                          '',
                          @OldAddress2,
                          @Address2,
                          @OldAddress2,
                          @Address2,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldCity <> @City
                    BEGIN
                        EXEC P_add_audit_history
                          'City',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                           @AIRPORT_CODE,
                          '',
                          @OldCity,
                          @City,
                          @OldCity,
                          @City,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldState <> @State
                    BEGIN
                        EXEC P_add_audit_history
                          'State',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                          @AIRPORT_CODE,
                          '',
                          @OldState,
                          @State,
                          @OldState,
                          @State,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldZipCode <> @ZipCode
                    BEGIN
                        EXEC P_add_audit_history
                          'ZipCode',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                           @AIRPORT_CODE,
                          '',
                          @OldZipCode,
                          @ZipCode,
                          @OldZipCode,
                          @ZipCode,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldCounty <> @County
                    BEGIN
                        EXEC P_add_audit_history
                          'Country',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                           @AIRPORT_CODE,
                          '',
                          @OldCounty,
                          @County,
                          @OldCounty,
                          @County,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldCountryRegionCode <> @CountryRegionCode
                    BEGIN
                        EXEC P_add_audit_history
                          'CountryRegionCode',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                          @AIRPORT_CODE,
                          '',
                          @OldCountryRegionCode,
                          @CountryRegionCode,
                          @OldCountryRegionCode,
                          @CountryRegionCode,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  IF @OldActive <> @Active
                    BEGIN
                        DECLARE @OldIsActiveText NVARCHAR(10) = ( CASE
                              WHEN @OldActive = 1 THEN 'Yes'
                              ELSE 'No'
                            END )
                        DECLARE @IsActiveText NVARCHAR(10) = ( CASE
                              WHEN @Active = 1 THEN 'Yes'
                              ELSE 'No'
                            END )

                        EXEC P_add_audit_history
                          'IsActive',
                          'T_AirPort_List',
                          @AL_ID,
                          166149 ,
                          @AL_ID,
                          @AIRPORT_CODE,
                          '',
                          @OldActive,
                          @Active,
                          @OldIsActiveText,
                          @IsActiveText,
                          '',
                          0,
                          107100,
                          @UserName
                    END

                  SET @Return_Text = 'AirPort List Updated Successfully!'
                  SET @Return_Code = 1
              END
            ELSE
              BEGIN
                  SET @Return_Text = 'AirPort List does not exist!'
                  SET @Return_Code = 0
              END
        END
      ELSE
        BEGIN
            IF @Name <> ''
              BEGIN
                  EXEC [POMS_DB].[dbo].[P_generate_airport_id]
                    @Ret_AirPort_ID = @AL_ID out

                  SET @AIRPORT_CODE = 'A' + Format(@AL_ID, '000000')

                  INSERT INTO [POMS_DB].[dbo].[T_AirPort_List]
                              (AL_ID,
                               [Name],
                               AIRPORT_CODE,
                               Number,
                               [Address],
                               Address2,
                               City,
                               [State],
                               ZipCode,
                               County,
                               CountryRegionCode,
                               IsActive,
                               AddedBy,
                               AddedOn)
                  VALUES      ( @AL_ID,
                                @Name,
                                @AIRPORT_CODE,
                                @Number,
                                @Address,
                                @Address2,
                                @City,
                                @State,
                                @ZipCode,
                                @County,
                                @CountryRegionCode,
                                @Active,
                                @Username,
                                Getutcdate() );

                  SET @Return_Text = 'AirPort List Added Successfully!'
                  SET @Return_Code = 1
              END
			  
             
        END

      SELECT @Return_Text Return_Text,
             @Return_Code Return_Code
  END 
GO
