USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Temp_zip_code_database_enterprise]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Temp_zip_code_database_enterprise](
	[zip] [nvarchar](10) NOT NULL,
	[type] [nvarchar](50) NOT NULL,
	[decommissioned] [bit] NOT NULL,
	[primary_city] [nvarchar](50) NOT NULL,
	[acceptable_cities] [nvarchar](500) NULL,
	[unacceptable_cities] [nvarchar](1050) NULL,
	[state] [nvarchar](10) NOT NULL,
	[county] [nvarchar](50) NULL,
	[timezone] [nvarchar](50) NULL,
	[timezoneutc] [nvarchar](20) NULL,
	[newtimezone] [nvarchar](50) NULL,
	[timezoneid] [int] NULL,
	[area_codes] [nvarchar](100) NULL,
	[world_region] [nvarchar](50) NULL,
	[country] [nvarchar](50) NULL,
	[approximate_latitude] [float] NULL,
	[approximate_longitude] [float] NULL,
	[population_center_latitude] [float] NULL,
	[population_center_longitude] [float] NULL,
	[polygon_offset_latitude] [float] NULL,
	[polygon_offset_longitude] [float] NULL,
	[internal_point_latitude] [float] NULL,
	[internal_point_longitude] [float] NULL,
	[latitude_min] [float] NULL,
	[latitude_max] [float] NULL,
	[longitude_min] [float] NULL,
	[longitude_max] [float] NULL,
	[area_land] [bigint] NULL,
	[area_water] [bigint] NULL,
	[housing_count] [int] NULL,
	[irs_estimated_households] [int] NULL,
	[acs_estimated_households] [int] NULL,
	[population_count] [int] NULL,
	[irs_estimated_population] [int] NULL,
	[acs_estimated_population] [int] NULL,
	[white] [int] NULL,
	[black_or_african_american] [int] NULL,
	[american_indian_or_alaskan_native] [int] NULL,
	[asian] [int] NULL,
	[native_hawaiian_and_other_pacific_islander] [int] NULL,
	[other_race] [int] NULL,
	[two_or_more_races] [int] NULL,
	[hispanic_or_latino] [int] NULL,
	[total_male_population] [int] NULL,
	[total_female_population] [int] NULL,
	[pop_under_10] [int] NULL,
	[pop_10_to_19] [int] NULL,
	[pop_20_to_29] [int] NULL,
	[pop_30_to_39] [int] NULL,
	[pop_40_to_49] [int] NULL,
	[pop_50_to_59] [int] NULL,
	[pop_60_to_69] [int] NULL,
	[pop_70_to_79] [int] NULL,
	[pop_80_plus] [int] NULL,
	[percent_population_in_poverty] [float] NULL,
	[median_earnings_past_year] [int] NULL,
	[median_household_income] [int] NULL,
	[median_gross_rent] [int] NULL,
	[median_home_value] [int] NULL,
	[percent_high_school_graduate] [float] NULL,
	[percent_bachelors_degree] [float] NULL,
	[percent_graduate_degree] [float] NULL,
	[Original_Latitude] [float] NULL,
	[Original_Longitude] [float] NULL,
	[MilesDiff] [int] NULL,
	[Original_TimeZoneID] [int] NULL,
	[Applicable_Latitude] [float] NULL,
	[Applicable_Longitude] [float] NULL
) ON [PRIMARY]
GO
