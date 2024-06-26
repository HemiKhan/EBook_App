USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Dates]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Dates](
	[TimeStamp] [timestamp] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [nvarchar](20) NOT NULL,
	[Week] [nvarchar](20) NOT NULL,
	[Month] [nvarchar](50) NOT NULL,
	[Year] [int] NOT NULL,
	[DateNum] [int] NOT NULL,
	[DayNum] [int] NOT NULL,
	[WeekNum] [int] NOT NULL,
	[MonthNum] [int] NOT NULL,
 CONSTRAINT [PK_T_Dates] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
