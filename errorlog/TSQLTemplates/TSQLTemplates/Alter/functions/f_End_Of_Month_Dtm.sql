

IF EXISTS
     (SELECT 1
      FROM   information_schema.ROUTINES
      WHERE  SPECIFIC_SCHEMA = 'dbo' AND ROUTINE_NAME = 'f_End_Of_Month_Dtm' AND ROUTINE_TYPE = 'Function')
  BEGIN
    DROP FUNCTION dbo.f_End_Of_Month_Dtm
  END
ELSE
  BEGIN
    PRINT 'Function dbo.f_End_Of_Month_Dtm does not exist, skipping drop'
  END
go

CREATE FUNCTION dbo.f_End_Of_Month_Dtm(@DAY DATETIME)
  RETURNS DATETIME
AS
/**

Filename: f_End_Of_Month_Dtm.sql
Author: Patrick W O'Brien.
Created: 05/24/2012

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_End_Of_Month_Dtm.sql $

Object: f_End_Of_Month_Dtm
ObjectType: Scalar function

Description:    Finds the end of last day of month at 23:59:59.997
                for input datetime, @DAY.
                Valid for all SQL Server datetimes.

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@Day                 datetimes    Date to be processed


OutputParams:
----------------------------------------------------------------------------
EndOfMonth           datetime


Revisions:
  Ini |    Date     | Description
 ---------------------------------

*/

  /*
  Function: f_End_Of_Month_Dtm
   
   Finds end of last day of month at 23:59:59.997
   for input datetime, @DAY.
   Valid for all SQL Server datetimes.

   Example:
   
      -- Calculate the start and end datetime values for a month
      DECLARE @MyDate DATETIME;
      DECLARE @StartDt DATETIME;
      DECLARE @EndDt DATETIME;

      -- Original date
      SET @MyDate  = CAST('05/24/2012 12:00:00' AS DATETIME);

      -- The start datetime
      SET @StartDt = dbo.f_Start_Of_Month(@MyDate);

      -- The end datetime
      SET @EndDt   = dbo.f_End_Of_Month_Dtm(@MyDate);

      SELECT @MyDate MyDate, @StartDt StartDt, CONVERT(VARCHAR(30), @EndDt, 109) EndDt;
   
  */
  BEGIN

    RETURN DATEADD(ms, -3, DATEADD(mm, DATEDIFF(mm, 0, DATEADD(mm, 1, @day)), 0));

end
go

IF EXISTS (
    SELECT 1
    FROM   information_schema.ROUTINES
    WHERE  SPECIFIC_SCHEMA = 'dbo' 
      AND ROUTINE_NAME = 'f_End_Of_Month_Dtm' 
      AND ROUTINE_TYPE = 'Function'
          ) BEGIN

    declare @Description    varchar(7500);

    set @Description =  'Finds the end of last day of month at 23:59:59.997 ' +
                        'for input datetime, @DAY. ' +
                        'Valid for all SQL Server datetimes.;'

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = @Description,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_Of_Month_Dtm'

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 394 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_Of_Month_Dtm';


END ELSE BEGIN
    PRINT 'Function dbo.f_End_Of_Month_Dtm does not exist, create failed'
  END
go