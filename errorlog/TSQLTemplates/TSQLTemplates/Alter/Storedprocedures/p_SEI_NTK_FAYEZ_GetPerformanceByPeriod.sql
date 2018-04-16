USE NETIKIP
GO

-- Drop stored procedure if it already exists
IF EXISTS (	SELECT 1 
		    FROM 
				INFORMATION_SCHEMA.ROUTINES 
			WHERE 
				SPECIFIC_SCHEMA = N'dbo'
		    AND 
				SPECIFIC_NAME = N'p_SEI_NTK_FAYEZ_GetPerformanceByPeriod' 
)
BEGIN
     DROP PROCEDURE [dbo].[p_SEI_NTK_FAYEZ_GetPerformanceByPeriod];
     PRINT 'PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod has been dropped.';
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod 
AS
BEGIN /count(1)----Procedure Begincount(1)/
SET NOCOUNT ON
/count(1)count(1)count(1)
================================================================================
 Name        : dbo.[p_SEI_NTK_FAYEZ_GetPerformanceByPeriod]
 Author      : RZKUMAR
 Description : Get the performance data for FAYEZ for all the time periods.
  
 Parameters  : 

 Name                     |I/O|         	Description
--------------------------------------------------------------------------------

Procedure is called from Netik CSAM application.

Returns		:  Table

Name						Type (length)		Description
--------------------------------------------------------------------------------
PORTFOLIO					VARCHAR(25)			Portfolio ID
SECTOR						VARCHAR(200)		Sector
START_DATE					DATETIME			Start date of data         
END_DATE					DATETIME			End date of data
TIME_PERIOD					VARCHAR(200)		Time perid of data
MARKET_VALUE				FLOAT				Market Value  
ACCRUED_INCOME				FLOAT				Accrued Income   
INCOME						FLOAT				Income
POSITIVE_FLOWS				FLOAT				Positive Flow   
NEGATIVE_FLOWS				FLOAT				Negative Flow       
UNIT_VALUE					FLOAT				Unit Value Return       
RATE_OF_RETURN				FLOAT				Rate of Return
 
Revisions    :
--------------------------------------------------------------------------------
 Ini		|   Date   	| Description
--------------------------------------------------------------------------------
RZKUMAR	    07/23/2013  First Version
RZKUMAR	    07/24/2013  Changes for the code review comments   Marked by --07242013
RZKUMAR	    07/25/2013  Changes for the code review comments   Marked by --07252013
================================================================================
Samples: 
EXECUTE dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod
count(1)count(1)count(1)/

--Thist ables holds the data less than 1000 rows		--07242013 
DECLARE @tblPerfF TABLE       
      (     
       Id							int identity(1,1),
       PORTFOLIO					VARCHAR(25),
       SECTOR						VARCHAR(200),
       START_DATE					DATETIME,       
       END_DATE						DATETIME,
	   TIME_PERIOD					VARCHAR(200),
       MARKET_VALUE				    FLOAT,   
	   ACCRUED_INCOME				FLOAT,   
       INCOME						FLOAT,
	   POSITIVE_FLOWS				FLOAT,   
       NEGATIVE_FLOWS				FLOAT,       
       UNIT_VALUE					FLOAT,       
       RATE_OF_RETURN				FLOAT       
       PRIMARY KEY (PORTFOLIO, SECTOR, TIME_PERIOD,Id)		--07252013 
       )

BEGIN TRY

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'WTD'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'MTD'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'QTD'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'YTD'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'Previous Month'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'Previous 2 Months'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'Previous 3 Months'

INSERT INTO @tblPerfF       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
EXEC p_SEI_NTK_FAYEZ_GetPerformance 'One Day'

SELECT PORTFOLIO,
       SECTOR,
       START_DATE,       
       END_DATE,
	   TIME_PERIOD,
		ROUND(CAST (MARKET_VALUE AS DECIMAL(18,2)),2) AS MARKET_VALUE,
		ROUND(CAST (ACCRUED_INCOME AS DECIMAL(18,2)),2) AS ACCRUED_INCOME,
		ROUND(CAST (INCOME AS DECIMAL(18,2)),2) AS INCOME,
		ROUND(CAST (POSITIVE_FLOWS AS DECIMAL(18,2)),2) AS POSITIVE_FLOWS,
		ROUND(CAST (NEGATIVE_FLOWS AS DECIMAL(18,2)),2) AS NEGATIVE_FLOWS,
        ROUND(CAST (UNIT_VALUE AS DECIMAL(18,5)),5) AS UNIT_VALUE, 
        ROUND(CAST (RATE_OF_RETURN AS DECIMAL(18,5)),5) AS RATE_OF_RETURN

FROM @tblPerfF 
ORDER BY PORTFOLIO, TIME_PERIOD, sector

END TRY 

BEGIN CATCH 
    DECLARE @errno    INT, 
            @errmsg   VARCHAR(2100), 
            @errsev   INT, 
            @errstate INT; 

    SET @errno = Error_number() 
    SET @errmsg = 'Error in dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod: ' 
                     + Error_message() 
    SET @errsev = Error_severity() 
    SET @errstate = Error_state(); 

    RAISERROR(@errmsg,@errsev,1); 
END CATCH 
END;/count(1)----Procedure Endcount(1)/
GO

-- Validate if procedure has been created.
IF EXISTS (	SELECT 1 
		    FROM 
				INFORMATION_SCHEMA.ROUTINES 
			WHERE 
				SPECIFIC_SCHEMA = N'dbo'
		    AND 
				SPECIFIC_NAME = N'p_SEI_NTK_FAYEZ_GetPerformanceByPeriod' 
)
BEGIN
     PRINT 'PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod has been created.';
END;
ELSE
BEGIN
    PRINT 'PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod has NOT been created.'
END;
GO

GRANT EXECUTE ON dbo.p_SEI_NTK_FAYEZ_GetPerformanceByPeriod TO netikapp_user
GO
