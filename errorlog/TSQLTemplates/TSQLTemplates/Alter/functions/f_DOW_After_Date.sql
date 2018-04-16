IF EXISTS (
        SELECT 1
        FROM   information_schema.ROUTINES
        WHERE  SPECIFIC_SCHEMA = 'dbo' 
          AND ROUTINE_NAME = 'f_DOW_After_Date' 
          AND ROUTINE_TYPE = 'Function'
          )
  BEGIN
        DROP FUNCTION dbo.f_DOW_After_Date;
  END;
go

CREATE FUNCTION dbo.f_DOW_After_Date (
        @StartDate DATETIME, 
        @SkipDaysNum INT, 
        @DayOfWeek SMALLINT
)
  RETURNS DATETIME
AS
/**
Filename: f_DOW_After_Date.sql
Author: Patrick W.O'Brien
Created: 11/17/2011

Object: f_DOW_After_Date
ObjectType: Scalar function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_DOW_After_Date.sql $

Description:    Finds the date of the day of the week after the start date
                with an option to skip a number of days after the start date
                before finding the date.

Params:
Name              | Datatype   | Description
----------------------------------------------------------------------------
@StartDate          datetime    Starting date for calculation
@SkipDaysNum        int         Number of days to add to start date before
                                calculating the date of the day of week
                                desired.
DayOfWeek           smallint    Day of week for date desired.
                                        1 - Sunday
                                        2 - Monday
                                        3 - Tuesday
                                        4 - Wednesday
                                        5 - Thursday
                                        6 - Friday
                                        7 - Saturday

OutputParams:
----------------------------------------------------------------------------
DayDate               datetime


Revisions:
 Ini |    Date     | Description
---------------------------------

*/

  /*
  Function: f_DOW_After_Date

    Finds the date of a day of the week after a starting date and number of days to skip.

    Valid for all SQL Server datetimes.
  */
  BEGIN
    DECLARE @DayDate DATETIME;

    -- Initialize function result value
    SET @DayDate = NULL;

    -- The start date must be valued
    IF (@StartDate IS NULL)
      RETURN @DayDate;

    -- The number of days to skip must be valued
    IF (@SkipDaysNum IS NULL) OR (@SkipDaysNum < 0)
      RETURN @DayDate;

    -- The day of the week of the date to calculate must to valued and in a valid range.
    IF (@DayOfWeek IS NULL) OR (@DayOfWeek < 1 OR @DayOfWeek > 7)
      RETURN @DayDate;

    -- Calculate the date
    SELECT @DayDate = DATEADD(d, (@SkipDaysNum + (7 - (7 + DATEPART(weekday, DATEADD(d, @SkipDaysNum, @StartDate)) - @DayOfWeek)) % 7), @StartDate);

    -- Return the calculated date.
    RETURN @DayDate;
  END;
Go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_DOW_After_Date'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Finds the date of the day of the week after the start date ' +
                            'with an option to skip a number of days after the start date ' +
                            'before finding the date.';

        exec sys.sp_addextendedproperty
                @name       = N'MS_Description',
                @value      = @Description,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_DOW_After_Date'

        exec sys.sp_addextendedproperty
                @name       = N'SVN Revision',
                @value      = N'$Rev: 394 $' ,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_DOW_After_Date';
end else begin
    print 'Function dbo.f_DOW_After_Date does not exist, create failed'
end
go