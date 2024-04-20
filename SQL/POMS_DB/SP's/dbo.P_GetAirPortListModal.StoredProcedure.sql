USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetAirPortListModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [[P_GetAirPortListModal]] 1
Create Procedure [dbo].[P_GetAirPortListModal]
@AL_ID int
As
Begin
SELECT  AL_ID, AIRPORT_CODE , [Name], Number, [Address], Address2, City ,[State], ZipCode,
County, CountryRegionCode,Active = IsActive
FROM [POMS_DB].[dbo].[T_AirPort_List] WITH (NOLOCK) WHERE AL_ID = @AL_ID
End


 
GO
