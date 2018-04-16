
print '------------------------------------------------------------'
print '***** Procedure script for dbo.p_Load_Table_Dimension_Date *****'
print 'Start time is: ' + cast(sysdatetime() as varchar(36))
print ''

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'p_Load_Table_Dimension_Date'
      and ROUTINE_TYPE = 'Procedure'
        ) begin
    print 'Dropping procedure dbo.p_Load_Table_Dimension_Date'
    drop procedure dbo.p_Load_Table_Dimension_Date
end else begin
    print 'Procedure dbo.p_Load_Table_Dimension_Date does not exist, skipping drop'
end
go

print 'Creating procedure dbo.p_Load_Table_Dimension_Date';
go
/*
   ================================================================================
   Name : dbo.p_Load_Table_Dimension_Date
   Author : Don Clark
   Description : Populates dbo.Dimension_Date table based on parameters.

   Revision: $Rev: 400 $
   URL: $URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Procedures/p_Load_Table_Dimension_Date.sql $
   Last Checked in: $Author: pobrien $
   ===============================================================================
   Revisions:

   Author      Date

   POBrien     09/05/2013  Tag 20130905.1
      Added date format YYYYMMDD.

   LByalsky    2009/02/05
      To avoid column aliases in the ORDER BY clause be prefixed by
      the table alias (SQL Server 2005).

   Don Clark   2005/5/10
      Initial version.
*/

create procedure dbo.p_Load_Table_Dimension_Date
   (
   -- Starting date to load into Dimension_Date
   @Start_Date                   date  = null,

   -- Ending date to load into Dimension_Date
   @End_Date                     date  = null,

   -- Start date for computing the value of Dimension_Date
   -- The default is '1753/01/01
   -- It must be the same as the date in check constraint
   -- CHK_T_DIMENSION_DATE_ID_DATE_OFFSET created when table
   -- T_DIMENSION_DATE was created.
   @Start_Date_For_Id_Calculation      date  = null,

   -- If 0, rows that fall outside the @Start_Date to @End_Date
   -- will be deleted from Dimension_Date
   -- If 1, no rows will be deleted
   -- Default to 0
   @Do_No_Delete_From_Table_Indicator  int      = null,

   -- If 1 and @Start_Date_FOR_ID_CALCULATION <> 1
   -- table Dimension_Date will be truncated.
   -- Otherwise, Dimension_Date will not be truncated.
   @Truncate_Table_Indicator        int      = null ,

   --  Standard error handling output parameters
   @SQLErrorCode  int         = null  output,
   @Errorcode     int         = null  output,
   @ErrorMessage  varchar(400) = null  output
   )
as

--------------Standard Header Begin -----------------------------------

SET  NOCOUNT ON
-- Set to Quoted Identifiers off
SET  QUOTED_IDENTIFIER OFF
-- Set to ANSI null default
SET  ANSI_NULLS ON

-- Standard local variables used in all procedures
DECLARE @Error   INT
DECLARE @Retcode   INT
DECLARE @Rowcount   INT

DECLARE @Fetch_Status   INT

DECLARE @Message   VARCHAR(400)

DECLARE @Tab   VARCHAR(1)
DECLARE @Cr   VARCHAR(2)

DECLARE @Start_No   INT
DECLARE @End_No   INT
DECLARE @Rows_Needed   INT
DECLARE @Rows_Needed_Root   INT

DECLARE @iso_start_year   INT
DECLARE @iso_end_year   INT

-- Initialize Return code, Row Count, Transaction count,
-- fetch_status,  and Errorcode parameters
SET @Error        = 0
SET @Retcode      = 0
SET @Rowcount     = 0
SET @Fetch_Status = 0
SET @Errorcode    = 0
SET @SQLErrorCode = 0
SET @ErrorMessage = ''

-- Load tab and cr strings for formatting dynamic SQL
SET @tab          = char( 9)
SET @cr           = char( 13) + Char( 10)
--------------Standard Header End -----------------------------------

begin try
   set   @Start_Date =
      case
         when @Start_Date is null
         -- Default to first day of year of five years before today
         then dateadd(year, datediff(year, 0, getdate())-5, 0)
         -- make sure @Start_Date begins at 00:00:00 (midnight)
         else dateadd(DAY, datediff(day, 0, @Start_Date), 0)
      end

   set   @End_Date   =
      case
         when @End_Date is null
         -- Default to last day of year of three years after today
         then dateadd(dd, -1, dateadd(year, datediff(year, 0, getdate())+ 4, 0))
         -- make sure @End_Date begins at 00:00:00 (midnight)
         else dateadd(day, datediff(day, 0, @End_Date), 0)
      end

   if @Start_Date > @End_Date begin
      set @ErrorMessage =
         '@Start_Date cannot be after @End_Date'+
         ', @Start_Date = '+isnull(convert(varchar(40),@Start_Date,121),'NULL')+
         ', @End_Date = '+isnull(convert(varchar(40),@End_Date,121),'NULL')
      set @Errorcode = 100
      raiserror(@ErrorMessage, 16, 1)
   end

   if @Start_Date < '17540101' begin
      set @ErrorMessage =
         '@Start_Date cannot be before 1754-01-01'+
         ', @Start_Date = ' + isnull(convert(varchar(40), @Start_Date, 121),'NULL')
      set @Errorcode = 110
      raiserror(@ErrorMessage, 16, 1)
   end

   if @End_Date > '99971231' begin
      set @ErrorMessage =
         '@End_Date cannot be after 9997-12-31'+
         ', @End_Date = ' + isnull(convert(varchar(40), @End_Date, 121),'NULL')
      set @Errorcode = 120
      raiserror(@ErrorMessage, 16, 1)
   end

   set @Start_Date_FOR_Id_Calculation =
      case
         when @Start_Date_For_Id_Calculation is not null
            then dateadd(dd,datediff(dd, 0, @Start_Date_FOR_ID_CALCULATION),0)
         else convert(datetime,'1969-12-31')
      end

   set @Do_No_Delete_From_Table_Indicator =
      case
         when @Do_No_Delete_From_Table_Indicator = 1 then 1
         else 0
      end

   select @Truncate_Table_Indicator =
      case
         -- Do not truncate table if delete from table is not enabled
         when @Do_No_Delete_From_Table_Indicator = 1 then 0
         when @Truncate_Table_Indicator = 1 then 1
         else 0
      end

   select @Start_no = datediff(dd, '1753/01/01', @Start_Date),
          @End_no   = datediff(dd, '1753/01/01', @End_Date)

   set @Message = '@Start_Date = ' + isnull(convert(varchar(40), @Start_Date, 121),'NULL')
   print @Message

   set @Message = '@End_Date   = ' + isnull(convert(varchar(40), @End_Date, 121),'NULL')
   print @Message

   set @Message = '@Start_Date_FOR_ID_CALCULATION = ' + isnull(convert(varchar(40), @Start_Date_FOR_ID_CALCULATION, 121), 'NULL')
   print @Message

   set @Message = '@DO_NO_DELETE_FROM_TABLE_INDICATOR = ' + isnull(convert(varchar(40), @DO_NO_DELETE_FROM_TABLE_INDICATOR), 'NULL')
   print @Message

   set @Message = '@TRUNCATE_TABLE_INDICATOR = ' + isnull(convert(varchar(40), @TRUNCATE_TABLE_INDICATOR), 'NULL')
   print @Message

   IF object_id( 'tempdb..#num1') IS NOT NULL
     BEGIN
       DROP TABLE #num1
     END

   IF object_id( 'tempdb..#num2') IS NOT NULL
     BEGIN
       DROP TABLE #num2
     END

   IF object_id( 'tempdb..#num3') IS NOT NULL
     BEGIN
       DROP TABLE #num3
     END

   IF object_id( 'tempdb..#ISO_WEEK') IS NOT NULL
     BEGIN
       DROP TABLE #ISO_Week
     END

   IF object_id( 'tempdb..#DIMENSION_DATE') IS NOT NULL
     BEGIN
       DROP TABLE #Dimension_Date
     END
  
   create table #num1 (
      Number int not null primary key clustered
   )

   create table #num2 (
      Number int not null primary key clustered
   )

   create table #num3 (
      Number int not null primary key clustered
   )

   create table #ISO_Week (
      Iso_Week_Year              int   not null primary key clustered,
      Iso_Week_Year_Start_Date   datetime not null,
      Iso_Week_Year_End_Date     datetime not null,
   )

   create table #Dimension_Date(
     Dimension_Date_Id                 int not null
    ,Calendar_Date                     datetime not null primary key clustered
    ,Next_Day_Date                     datetime not null
    ,Calendar_Year                     smallint not null
    ,Year_Quarter                      int not null
    ,Year_Month                        int not null
    ,Year_Day_Of_Year                  int not null
    ,Calendar_Quarter                  tinyint not null
    ,Calendar_Month                    tinyint not null
    ,Day_Of_Year                       smallint not null
    ,Day_Of_month                      smallint not null
    ,Day_of_Week                       tinyint not null
    ,Year_Name                         varchar(4) not null
    ,Year_Quarter_Name                 varchar(7) not null
    ,Year_Month_Name                   varchar(8) not null
    ,Year_Month_Name_Long              varchar(14) not null
    ,Quarter_Name                      varchar(2) not null
    ,Month_Name                        varchar(3) not null
    ,Month_Name_Long                   varchar(9) not null
    ,Weekday_Name                      varchar(3) not null
    ,Weekday_Name_Long                 varchar(9) not null
    ,Start_of_Year_Date                datetime not null
    ,End_of_Year_Date                  datetime not null
    ,Start_of_Quarter_Date             datetime not null
    ,End_of_Quarter_Date               datetime not null
    ,Start_of_Month_Date               datetime not null
    ,End_of_Month_Date                 datetime not null
    ,Start_of_Week_Starting_Sun_Date   datetime not null
    ,End_of_Week_Starting_Sun_Date     datetime not null
    ,Start_of_Week_Starting_Mon_Date   datetime not null
    ,End_of_Week_Starting_Mon_Date     datetime not null
    ,Start_of_Week_Starting_Tue_Date   datetime not null
    ,End_of_Week_Starting_Tue_Date     datetime not null
    ,Start_of_Week_Starting_Wed_Date   datetime not null
    ,End_of_Week_Starting_Wed_Date     datetime not null
    ,Start_of_Week_Starting_Thu_Date   datetime not null
    ,End_of_Week_Starting_Thu_Date     datetime not null
    ,Start_of_Week_Starting_Fri_Date   datetime not null
    ,End_of_Week_Starting_Fri_Date     datetime not null
    ,Start_of_Week_Starting_Sat_Date   datetime not null
    ,End_of_Week_Starting_Sat_Date     datetime not null
    ,Quarter_Seq_No                    int not null
    ,Month_Seq_No                      int not null
    ,Week_Starting_Sun_Seq_No          int not null
    ,Week_Starting_Mon_Seq_No          int not null
    ,Week_Starting_Tue_Seq_No          int not null
    ,Week_Starting_Wed_Seq_No          int not null
    ,Week_Starting_Thu_Seq_No          int not null
    ,Week_Starting_Fri_Seq_No          int not null
    ,Week_Starting_Sat_Seq_No          int not null
    ,Julian_Date                       int not null
    ,Modified_Julian_Date              int not null
    ,ISO_Date                          varchar(10) not null
    ,ISO_Year_Week_No                  int not null
    ,ISO_Week_No                       smallint not null
    ,ISO_Day_of_Week                   tinyint not null
    ,ISO_Year_Week_Name                varchar(8) not null
    ,ISO_Year_Week_Day_of_Week_Name    varchar(10) not null
    ,Date_Format_yyyy_mm_dd            varchar(10) not null
    ,Date_Format_yyyy_m_d              varchar(10) not null
    ,Date_Format_mm_dd_yyyy            varchar(10) not null
    ,Date_Format_m_d_yyyy              varchar(10) not null
    ,Date_Format_mmm_d_yyyy            varchar(12) not null
    ,Date_Format_mmmmmmmmm_d_yyyy      varchar(18) not null
    ,Date_Format_mm_dd_yy              varchar(8) not null
    ,Date_Format_m_d_yy                varchar(8) not null
    ,Date_Format_yyyymmdd              varchar(8) not null -- Tag 20130905.1
   )

   set @rows_needed = @end_no - @start_no + 1
   set @rows_needed =
      case
         when @rows_needed < 10 then 10
         else @rows_needed
      end
   set   @rows_needed_root = convert(int,ceiling(sqrt(@rows_needed)))

   set @Message = 'Load table #num1'
   print @Message

   -- insert 15 rows
   insert into #Num1 (Number)
   values   (0), (1), (2), (3), (4), (5), (6), (7), (8),
         (9), (10), (11), (12), (13), (14), (15)

   insert into #Num2 (Number)
   select  Number = a.Number + (16 * b.Number) + (256 * c.Number)
   from #Num1 a
      cross join #Num1 b
      cross join #Num1 c
   where a.Number + (16 * b.Number) + (256 * c.Number) < @Rows_Needed_Root
   order by 1

   insert into #num3 (Number)
   select  Number = a.Number + (@Rows_Needed_Root * b.Number)
   from #num2 a
      cross join #num2 b
   where a.Number + (@Rows_Needed_Root * b.Number) < @Rows_Needed
   order by 1

   set   @iso_start_year   = datepart(year, dateadd(year, -1, @start_date))
   set   @iso_end_year  = datepart(year, dateadd(year, 1, @end_date))

   insert into #ISO_Week (
         ISO_Week_Year,
         ISO_Week_Year_Start_Date,
         ISO_Week_Year_End_Date
   )
   select  ISO_Week_Year = a.Number,
         ISO_Week_Year_Start_Date   = dateadd(dd,(datediff(dd,'1753/01/01', dateadd(day,3,dateadd(year,a.Number-1900,0)))/7)*7,'1753/01/01'),
         ISO_Week_Year_End_Date  = dateadd(dd,-1,dateadd(dd,(datediff(dd,'1753/01/01', dateadd(day,3,dateadd(year,a.Number+1-1900,0)))/7)*7,'1753/01/01'))
   from (   --F_TABLE_NUMBER_RANGE(1753,9998) a
      select Number = Number + @iso_start_year
      from #num3
      where Number + @iso_start_year <= @iso_end_year
      ) a
   order by
   -- a.ISO_Week_Year
      a.Number

   --select * from #ISO_Week

   insert into #Dimension_Date
   select  Dimension_Date_Id     = a.Dimension_Date_Id,
         Calendar_Date        = a.Calendar_Date,
         Next_Day_Date        = dateadd(day, 1, a.Calendar_Date),
         Calendar_Year        = datepart(year, a.Calendar_Date),
         Year_Quarter         = (10 * datepart(year, a.Calendar_Date)) + datepart(quarter, a.Calendar_Date),
         Year_Month           = (100 * datepart(year, a.Calendar_Date)) + datepart(month, a.Calendar_Date) ,
         Year_Day_of_Year     = (1000 * datepart(year,a.Calendar_Date)) + datediff(dd, dateadd(yy, datediff(yy, 0, a.Calendar_Date), 0), a.Calendar_Date) + 1,
         Calendar_Quarter     = datepart(quarter,a.Calendar_Date),
         Calendar_Month       = datepart(month,a.Calendar_Date),
         Day_of_Year           = datediff(dd, dateadd(yy, datediff(yy, 0, a.Calendar_Date), 0), a.Calendar_Date) + 1,
         Day_of_Month         = datepart(day, a.Calendar_Date),
         Day_of_Week          = (datediff(dd, '1753/01/07', a.Calendar_Date) % 7) + 1  ,  -- Sunday = 1, Monday = 2, ,,,Saturday = 7
         Year_Name            = datename(year, a.Calendar_Date),
         Year_Quarter_Name    = datename(year, a.Calendar_Date) + ' Q' + datename(quarter, a.Calendar_Date),
         Year_Month_Name         = datename(year, a.Calendar_Date) + ' ' + left(datename(month, a.Calendar_Date), 3),
         Year_Month_Name_Long = datename(year, a.Calendar_Date) + ' ' + datename(month, a.Calendar_Date),
         Quarter_Name         = 'Q' + datename(quarter, a.Calendar_Date),
         Month_Name           = left(datename(month, a.Calendar_Date), 3),
         Month_Name_Long         = datename(month, a.Calendar_Date),
         Weekday_Name         = left(datename(weekday, a.Calendar_Date), 3),
         Weekday_Name_Long    = datename(weekday, a.Calendar_Date),
         Start_of_Year_Date      = dateadd(year, datediff(year, 0, a.Calendar_Date), 0),
         End_of_Year_Date     = dateadd(day, -1, dateadd(year, datediff(year, 0, a.Calendar_Date) + 1, 0)),
         Start_of_Quarter_Date   = dateadd(quarter,datediff(quarter,0,a.Calendar_Date),0) ,
         End_of_Quarter_Date     = dateadd(day,-1,dateadd(quarter,datediff(quarter,0,a.Calendar_Date)+1,0)) ,
         Start_of_Month_Date     = dateadd(month,datediff(month,0,a.Calendar_Date),0) ,
         End_of_Month_Date    = dateadd(day,-1,dateadd(month,datediff(month,0,a.Calendar_Date)+1,0)),
         Start_of_Week_Starting_Sun_Date  = dateadd(dd,(datediff(dd,'1753/01/07',a.Calendar_Date)/7)*7,'1753/01/07'),
         End_of_Week_Starting_Sun_Date = dateadd(dd,((datediff(dd,'1753/01/07',a.Calendar_Date)/7)*7)+6,'1753/01/07'),
         Start_of_Week_Starting_Mon_Date  = dateadd(dd,(datediff(dd,'1753/01/01',a.Calendar_Date)/7)*7,'1753/01/01'),
         End_of_Week_Starting_Mon_Date = dateadd(dd,((datediff(dd,'1753/01/01',a.Calendar_Date)/7)*7)+6,'1753/01/01'),
         Start_of_Week_Starting_Tue_Date  = dateadd(dd,(datediff(dd,'1753/01/02',a.Calendar_Date)/7)*7,'1753/01/02'),
         End_of_Week_Starting_Tue_Date = dateadd(dd,((datediff(dd,'1753/01/02',a.Calendar_Date)/7)*7)+6,'1753/01/02'),
         Start_of_Week_Starting_Wed_Date  = dateadd(dd,(datediff(dd,'1753/01/03',a.Calendar_Date)/7)*7,'1753/01/03'),
         End_of_Week_Starting_Wed_Date = dateadd(dd,((datediff(dd,'1753/01/03',a.Calendar_Date)/7)*7)+6,'1753/01/03'),
         Start_of_Week_Starting_Thu_Date  = dateadd(dd,(datediff(dd,'1753/01/04',a.Calendar_Date)/7)*7,'1753/01/04'),
         End_of_Week_Starting_Thu_Date = dateadd(dd,((datediff(dd,'1753/01/04',a.Calendar_Date)/7)*7)+6,'1753/01/04'),
         Start_of_Week_Starting_Fri_Date  = dateadd(dd,(datediff(dd,'1753/01/05',a.Calendar_Date)/7)*7,'1753/01/05'),
         End_of_Week_Starting_Fri_Date = dateadd(dd,((datediff(dd,'1753/01/05',a.Calendar_Date)/7)*7)+6,'1753/01/05'),
         Start_of_Week_Starting_Sat_Date  = dateadd(dd,(datediff(dd,'1753/01/06',a.Calendar_Date)/7)*7,'1753/01/06'),
         End_of_Week_Starting_Sat_Date = dateadd(dd,((datediff(dd,'1753/01/06',a.Calendar_Date)/7)*7)+6,'1753/01/06'),
         Quarter_Seq_No             = datediff(quarter,'1753/1/1',a.Calendar_Date),
         Month_Seq_No               = datediff(month,'1753/1/1',a.Calendar_Date),
         Week_Starting_Sun_Seq_No      = datediff(day,'1753/1/7',a.Calendar_Date) / 7,
         Week_Starting_Mon_Seq_No      = datediff(day,'1753/1/1',a.Calendar_Date) / 7,
         Week_Starting_Tue_Seq_No      = datediff(day,'1753/1/2',a.Calendar_Date) / 7,
         Week_Starting_Wed_Seq_No      = datediff(day,'1753/1/3',a.Calendar_Date) / 7,
         Week_Starting_Thu_Seq_No      = datediff(day,'1753/1/4',a.Calendar_Date) / 7,
         Week_Starting_Fri_Seq_No      = datediff(day,'1753/1/5',a.Calendar_Date) / 7,
         Week_Starting_Sat_Seq_No      = datediff(day,'1753/1/6',a.Calendar_Date) / 7,
         Julian_Date                = datediff(day,'1753/1/1',a.Calendar_Date) + 2361331,
         Modified_Julian_Date       = datediff(day,'1858/11/17',a.Calendar_Date),
         ISO_Date                = replace(convert(char(10),a.Calendar_Date,111),'/','-') ,
         ISO_Year_Week_No           = (100 * b.ISO_Week_Year) + (datediff(dd,b.ISO_Week_Year_START_Date,a.Calendar_Date)/7)+1 ,
         ISO_Week_No                = (datediff(dd,b.ISO_Week_Year_START_Date,a.Calendar_Date)/7) + 1,
         ISO_Day_of_Week               = (datediff(dd,'1753/01/01',a.Calendar_Date)%7) + 1, -- Sunday = 1, Monday = 2, ,,,Saturday = 7
         ISO_Year_Week_Name            = convert(varchar(4),b.ISO_Week_Year)+'-W'+
                                   right('00'+convert(varchar(2),(datediff(dd,b.ISO_Week_Year_START_Date,a.Calendar_Date)/7)+1),2) ,
         ISO_Year_Week_Day_of_Week_Name   = convert(varchar(4),b.ISO_Week_Year)+'-W'+
                                    right('00' + convert(varchar(2),(datediff(dd,b.ISO_Week_Year_START_Date,a.Calendar_Date)/7)+1),2) +
                                    '-' + convert(varchar(1),(datediff(dd,'1753/01/01',a.Calendar_Date)%7)+1) ,
         Date_Format_yyyy_mm_dd        = convert(char(10),a.Calendar_Date,111),
         Date_Format_yyyy_M_D       = convert(varchar(10), convert(varchar(4),year(a.Calendar_Date)) + '/' +
                                    convert(varchar(2),day(a.Calendar_Date)) + '/' +
                                    convert(varchar(2),month(a.Calendar_Date))),
         Date_Format_mm_dd_yyyy        = convert(char(10),a.Calendar_Date,101),
         Date_Format_M_d_yyyy       = convert(varchar(10), convert(varchar(2),month(a.Calendar_Date)) + '/' +
                                    convert(varchar(2),day(a.Calendar_Date))+'/'+
                                    convert(varchar(4),year(a.Calendar_Date))),
         Date_Format_mmm_d_yyyy        = convert(varchar(12), left(datename(month,a.Calendar_Date),3)+' '+
                                    convert(varchar(2),day(a.Calendar_Date))+', '+
                                    convert(varchar(4),year(a.Calendar_Date))),
         Date_Format_mmmmmmmmm_d_yyyy  = convert(varchar(18), datename(month,a.Calendar_Date) + ' ' +
                                    convert(varchar(2),day(a.Calendar_Date)) + ', ' +
                                    convert(varchar(4),year(a.Calendar_Date))),
         Date_Format_mm_dd_YY       = convert(char(8),a.Calendar_Date,1) ,
         Date_Format_M_d_YY            = convert(varchar(8), convert(varchar(2),month(a.Calendar_Date)) + '/' +
                                    convert(varchar(2),day(a.Calendar_Date))+'/'+
                                    right(convert(varchar(4),year(a.Calendar_Date)),2)),
         Date_Format_yyyymmdd       = convert(char(8),a.Calendar_Date,112) -- Tag 20130905.1
   from (
      select   top 100 percent
            Dimension_Date_Id = aa.Number + datediff(dd, @Start_Date_FOR_Id_CALCULATION,'1753/01/01 00:00:00'),
            Calendar_Date = dateadd(dd, aa.Number,'1753/01/01 00:00:00')
      from (
         select Number = Number + @start_no
         from #num3
         where Number + @start_no <= @end_no
          ) aa
      order by aa.Number
       ) a
      inner join #ISO_Week b on a.Calendar_Date between b.ISO_Week_Year_START_Date and b.ISO_Week_Year_END_Date
   order by a.Dimension_Date_Id

   if @TRUNCATE_TABLE_INDICATOR <> 1 begin goto Truncate_T_Dimension_Date_End end

Truncate_T_Dimension_Date:

   truncate table dbo.Dimension_Date
   goto Insert_into_T_Dimension_Date

Truncate_T_Dimension_Date_End:

Update_T_Dimension_Date:

   select @Message = 'Update table T_Dimension_Date'
   print @Message

   update a
   set Dimension_Dt_Id               = b.Dimension_Date_Id,
      Dimension_Dt               = b.Calendar_Date,
      Next_Day_Dt                 = b.Next_Day_Date,
      Calendar_Year              = b.Calendar_Year,
      Year_Quarter               = b.Year_Quarter,
      Year_Month                 = b.Year_Month,
      Year_Day_of_Year           = b.Year_Day_of_Year,
      Calendar_Quarter           = b.Calendar_Quarter,
      Calendar_Month             = b.Calendar_Month,
      Day_of_Year                = b.Day_of_Year,
      Day_of_Month               = b.Day_of_Month,
      Day_of_Week                = b.Day_of_Week,
      Year_Nm                     = b.Year_Name,
      Year_Quarter_Nm            = b.Year_Quarter_Name,
      Year_Month_Nm              = b.Year_Month_Name,
      Year_Month_Nm_Long         = b.Year_Month_Name_Long,
      Quarter_Nm                 = b.Quarter_Name,
      Month_Nm                = b.Month_Name,
      Month_Nm_Long              = b.Month_Name_Long,
      Weekday_Nm                 = b.Weekday_Name,
      Weekday_Nm_Long            = b.Weekday_Name_Long,
      Start_of_Year_Dt           = b.Start_of_Year_Date,
      End_of_Year_Dt             = b.End_of_Year_Date,
      Start_of_Quarter_Dt        = b.Start_of_Quarter_Date,
      End_of_Quarter_Dt          = b.End_of_Quarter_Date,
      Start_of_Month_Dt          = b.Start_of_Month_Date,
      End_of_Month_Dt            = b.End_of_Month_Date,
      Start_of_Week_Starting_Sun_Dt = b.Start_of_Week_Starting_Sun_Date,
      End_of_Week_Starting_Sun_Dt   = b.End_of_Week_Starting_Sun_Date,
      Start_of_Week_Starting_Mon_Dt = b.Start_of_Week_Starting_Mon_Date,
      End_of_Week_Starting_Mon_Dt   = b.End_of_Week_Starting_Mon_Date,
      Start_of_Week_Starting_Tue_Dt = b.Start_of_Week_Starting_Tue_Date,
      End_of_Week_Starting_Tue_Dt   = b.End_of_Week_Starting_Tue_Date,
      Start_of_Week_Starting_Wed_Dt = b.Start_of_Week_Starting_Wed_Date,
      End_of_Week_Starting_Wed_Dt       = b.End_of_Week_Starting_Wed_Date,
      Start_of_Week_Starting_Thu_Dt = b.Start_of_Week_Starting_Thu_Date,
      End_of_Week_Starting_Thu_Dt   = b.End_of_Week_Starting_Thu_Date,
      Start_of_Week_Starting_Fri_Dt = b.Start_of_Week_Starting_Fri_Date,
      End_of_Week_Starting_Fri_Dt   = b.End_of_Week_Starting_Fri_Date,
      Start_of_Week_Starting_Sat_Dt = b.Start_of_Week_Starting_Sat_Date,
      End_of_Week_Starting_Sat_Dt   = b.End_of_Week_Starting_Sat_Date,
      Quarter_Seq_No             = b.Quarter_Seq_No,
      Month_Seq_No               = b.Month_Seq_No,
      Week_Starting_Sun_Seq_No      = b.Week_Starting_Sun_Seq_No,
      Week_Starting_Mon_Seq_No      = b.Week_Starting_Mon_Seq_No,
      Week_Starting_Tue_Seq_No      = b.Week_Starting_Tue_Seq_No,
      Week_Starting_Wed_Seq_No      = b.Week_Starting_Wed_Seq_No,
      Week_Starting_Thu_Seq_No      = b.Week_Starting_Thu_Seq_No,
      Week_Starting_Fri_Seq_No      = b.Week_Starting_Fri_Seq_No,
      Week_Starting_Sat_Seq_No      = b.Week_Starting_Sat_Seq_No,
      Julian_Dt                  = b.Julian_Date,
      Modified_Julian_Dt         = b.Modified_Julian_Date,
      ISO_Dt                  = b.ISO_Date,
      ISO_Year_Week_No           = b.ISO_Year_Week_No,
      ISO_Week_No                = b.ISO_Week_No,
      ISO_Day_of_Week               = b.ISO_Day_of_Week,
      ISO_Year_Week_Nm           = b.ISO_Year_Week_Name,
      ISO_Year_Week_Day_of_Week_Nm  = b.ISO_Year_Week_Day_of_Week_Name,
      Date_Format_yyyy_mm_dd        = b.Date_Format_yyyy_mm_dd,
      Date_Format_yyyy_M_D       = b.Date_Format_yyyy_M_D,
      Date_Format_mm_dd_yyyy        = b.Date_Format_mm_dd_yyyy,
      Date_Format_M_d_yyyy       = b.Date_Format_M_d_yyyy,
      Date_Format_mmm_d_yyyy        = b.Date_Format_mmm_d_yyyy,
      Date_Format_mmmmmmmmm_d_yyyy  = b.Date_Format_mmmmmmmmm_d_yyyy,
      Date_Format_mm_dd_YY       = b.Date_Format_mm_dd_YY,
      Date_Format_M_d_YY            = b.Date_Format_M_d_YY
   from
      dbo.Dimension_Date a
      join #Dimension_Date b on a.Dimension_Dt = b.Calendar_Date
   where
      a.Dimension_Dt_Id             <> b.Dimension_Date_Id  or
      a.Dimension_Dt                <> b.Calendar_Date      or
      a.Next_Day_Dt                 <> b.Next_Day_Date      or
      a.Calendar_Year                  <> b.Calendar_Year      or
      a.Year_Quarter                <> b.Year_Quarter    or
      a.Year_Month                  <> b.Year_Month         or
      a.Year_Day_of_Year               <> b.Year_Day_of_Year   or
      a.Calendar_Quarter               <> b.Calendar_Quarter   or
      a.Calendar_Month              <> b.Calendar_Month     or
      a.Day_of_Year                 <> b.Day_of_Year     or
      a.Day_of_Month                <> b.Day_of_Month    or
      a.Day_of_Week                 <> b.Day_of_Week     or
      a.Year_Nm                     <> b.Year_Name       or
      a.Year_Quarter_Nm             <> b.Year_Quarter_Name  or
      a.Year_Month_Nm               <> b.Year_Month_Name or
      a.Year_Month_Nm_Long          <> b.Year_Month_Name_Long  or
      a.Quarter_Nm                  <> b.Quarter_Name    or
      a.Month_Nm                    <> b.Month_Name         or
      a.Month_Nm_Long               <> b.Month_Name_Long or
      a.Weekday_Nm                  <> b.Weekday_Name    or
      a.Weekday_Nm_Long             <> b.Weekday_Name_Long  or
      a.Start_of_Year_Dt            <> b.Start_of_Year_Date or
      a.End_of_Year_Dt              <> b.End_of_Year_Date   or
      a.Start_of_Quarter_Dt            <> b.Start_of_Quarter_Date or
      a.End_of_Quarter_Dt              <> b.End_of_Quarter_Date   or
      a.Start_of_Month_Dt               <> b.Start_of_Month_Date  or
      a.End_of_Month_Dt             <> b.End_of_Month_Date     or
      a.Start_of_Week_Starting_Sun_Dt  <> b.Start_of_Week_Starting_Sun_Date   or
      a.End_of_Week_Starting_Sun_Dt    <> b.End_of_Week_Starting_Sun_Date     or
      a.Start_of_Week_Starting_Mon_Dt  <> b.Start_of_Week_Starting_Mon_Date   or
      a.End_of_Week_Starting_Mon_Dt    <> b.End_of_Week_Starting_Mon_Date     or
      a.Start_of_Week_Starting_Tue_Dt  <> b.Start_of_Week_Starting_Tue_Date   or
      a.End_of_Week_Starting_Tue_Dt    <> b.End_of_Week_Starting_Tue_Date     or
      a.Start_of_Week_Starting_Wed_Dt  <> b.Start_of_Week_Starting_Wed_Date   or
      a.End_of_Week_Starting_Wed_Dt    <> b.End_of_Week_Starting_Wed_Date     or
      a.Start_of_Week_Starting_Thu_Dt  <> b.Start_of_Week_Starting_Thu_Date   or
      a.End_of_Week_Starting_Thu_Dt    <> b.End_of_Week_Starting_Thu_Date     or
      a.Start_of_Week_Starting_Fri_Dt  <> b.Start_of_Week_Starting_Fri_Date   or
      a.End_of_Week_Starting_Fri_Dt    <> b.End_of_Week_Starting_Fri_Date     or
      a.Start_of_Week_Starting_Sat_Dt  <> b.Start_of_Week_Starting_Sat_Date   or
      a.End_of_Week_Starting_Sat_Dt    <> b.End_of_Week_Starting_Sat_Date     or
      a.Quarter_Seq_No              <> b.Quarter_Seq_No           or
      a.Month_Seq_No                <> b.Month_Seq_No          or
      a.Week_Starting_Sun_Seq_No       <> b.Week_Starting_Sun_Seq_No or
      a.Week_Starting_Mon_Seq_No       <> b.Week_Starting_Mon_Seq_No or
      a.Week_Starting_Tue_Seq_No       <> b.Week_Starting_Tue_Seq_No or
      a.Week_Starting_Wed_Seq_No       <> b.Week_Starting_Wed_Seq_No or
      a.Week_Starting_Thu_Seq_No       <> b.Week_Starting_Thu_Seq_No or
      a.Week_Starting_Fri_Seq_No       <> b.Week_Starting_Fri_Seq_No or
      a.Week_Starting_Sat_Seq_No       <> b.Week_Starting_Sat_Seq_No or
      a.Julian_Dt                   <> b.Julian_Date        or
      a.Modified_Julian_Dt          <> b.Modified_Julian_Date  or
      a.ISO_Dt                   <> b.ISO_Date           or
      a.ISO_Year_Week_No               <> b.ISO_Year_Week_No      or
      a.ISO_Week_No                 <> b.ISO_Week_No        or
      a.ISO_Day_of_Week             <> b.ISO_Day_of_Week    or
      a.ISO_Year_Week_Nm            <> b.ISO_Year_Week_Name    or
      a.ISO_Year_Week_Day_of_Week_Nm   <> b.ISO_Year_Week_Day_of_Week_Name or
      a.Date_Format_yyyy_mm_dd         <> b.Date_Format_yyyy_mm_dd   or
      a.Date_Format_yyyy_M_D           <> b.Date_Format_yyyy_M_D  or
      a.Date_Format_mm_dd_yyyy         <> b.Date_Format_mm_dd_yyyy   or
      a.Date_Format_M_d_yyyy           <> b.Date_Format_M_d_yyyy  or
      a.Date_Format_mmm_d_yyyy         <> b.Date_Format_mmm_d_yyyy   or
      a.Date_Format_mmmmmmmmm_d_yyyy      <> b.Date_Format_mmmmmmmmm_d_yyyy   or
      a.Date_Format_mm_dd_YY           <> b.Date_Format_mm_dd_YY  or
      a.Date_Format_M_d_YY          <> b.Date_Format_M_d_YY

   select @Message = @Message+', Rowcount = '+isnull(convert(varchar(20),@rowcount),'NULL')
   print @Message

   Delete_from_T_Dimension_Date:

   if @DO_No_DELETE_FROM_TABLE_INDICATOR = 1 begin
      set @Message = 'Do not delete from table T_Dimension_Date'
      print @Message
      goto Delete_from_T_Dimension_Date_End
   end

   set @Message = 'Delete from table T_Dimension_Date'
   print @Message

   delete from dbo.Dimension_Date
   from dbo.Dimension_Date
      left join #Dimension_Date b on Dimension_Date.Calendar_Date = b.Calendar_Date
   where b.Calendar_Date is null

   select @Message = @Message+', Rowcount = '+isnull(convert(varchar(20),@rowcount),'NULL')
   print @Message

   Delete_from_T_Dimension_Date_End:

   Insert_into_T_Dimension_Date:

   select @Message = 'Insert into table T_Dimension_Date'
   print @Message

   insert into dbo.Dimension_Date (
      Dimension_Dt_Id,
      Dimension_Dt,
      Next_Day_Dt,
      Calendar_Year,
      Year_Quarter,
      Year_Month,
      Year_Day_of_Year,
      Calendar_Quarter,
      Calendar_Month,
      Day_of_Year,
      Day_of_Month,
      Day_of_Week,
      Year_Nm,
      Year_Quarter_Nm,
      Year_Month_Nm,
      Year_Month_Nm_Long,
      Quarter_Nm,
      Month_Nm,
      Month_Nm_Long,
      Weekday_Nm,
      Weekday_Nm_Long,
      Start_of_Year_Dt,
      End_of_Year_Dt,
      Start_of_Quarter_Dt,
      End_of_Quarter_Dt,
      Start_of_Month_Dt,
      End_of_Month_Dt,
      Start_of_Week_Starting_Sun_Dt,
      End_of_Week_Starting_Sun_Dt,
      Start_of_Week_Starting_Mon_Dt,
      End_of_Week_Starting_Mon_Dt,
      Start_of_Week_Starting_Tue_Dt,
      End_of_Week_Starting_Tue_Dt,
      Start_of_Week_Starting_Wed_Dt,
      End_of_Week_Starting_Wed_Dt,
      Start_of_Week_Starting_Thu_Dt,
      End_of_Week_Starting_Thu_Dt,
      Start_of_Week_Starting_Fri_Dt,
      End_of_Week_Starting_Fri_Dt,
      Start_of_Week_Starting_Sat_Dt,
      End_of_Week_Starting_Sat_Dt,
      Quarter_Seq_No,
      Month_Seq_No,
      Week_Starting_Sun_Seq_No,
      Week_Starting_Mon_Seq_No,
      Week_Starting_Tue_Seq_No,
      Week_Starting_Wed_Seq_No,
      Week_Starting_Thu_Seq_No,
      Week_Starting_Fri_Seq_No,
      Week_Starting_Sat_Seq_No,
      Julian_Dt,
      Modified_Julian_Dt,
      ISO_Dt,
      ISO_Year_Week_No,
      ISO_Week_No,
      ISO_Day_of_Week,
      ISO_Year_Week_Nm,
      ISO_Year_Week_Day_of_Week_Nm,
      Date_Format_yyyy_mm_dd,
      Date_Format_yyyy_M_D,
      Date_Format_mm_dd_yyyy,
      Date_Format_M_d_yyyy,
      Date_Format_mmm_d_yyyy,
      Date_Format_mmmmmmmmm_d_yyyy,
      Date_Format_mm_dd_YY,
      Date_Format_M_d_YY
   )
   select   top 100 percent
      a.Dimension_Date_Id,
      a.Calendar_Date,
      a.Next_Day_Date,
      a.Calendar_Year,
      a.Year_Quarter,
      a.Year_Month,
      a.Year_Day_of_Year,
      a.Calendar_Quarter,
      a.Calendar_Month,
      a.Day_of_Year,
      a.Day_of_Month,
      a.Day_of_Week,
      a.Year_Name,
      a.Year_Quarter_Name,
      a.Year_Month_Name,
      a.Year_Month_Name_Long,
      a.Quarter_Name,
      a.Month_Name,
      a.Month_Name_Long,
      a.Weekday_Name,
      a.Weekday_Name_Long,
      a.Start_of_Year_Date,
      a.End_of_Year_Date,
      a.Start_of_Quarter_Date,
      a.End_of_Quarter_Date,
      a.Start_of_Month_Date,
      a.End_of_Month_Date,
      a.Start_of_Week_Starting_Sun_Date,
      a.End_of_Week_Starting_Sun_Date,
      a.Start_of_Week_Starting_Mon_Date,
      a.End_of_Week_Starting_Mon_Date,
      a.Start_of_Week_Starting_Tue_Date,
      a.End_of_Week_Starting_Tue_Date,
      a.Start_of_Week_Starting_Wed_Date,
      a.End_of_Week_Starting_Wed_Date,
      a.Start_of_Week_Starting_Thu_Date,
      a.End_of_Week_Starting_Thu_Date,
      a.Start_of_Week_Starting_Fri_Date,
      a.End_of_Week_Starting_Fri_Date,
      a.Start_of_Week_Starting_Sat_Date,
      a.End_of_Week_Starting_Sat_Date,
      a.Quarter_Seq_No,
      a.Month_Seq_No,
      a.Week_Starting_Sun_Seq_No,
      a.Week_Starting_Mon_Seq_No,
      a.Week_Starting_Tue_Seq_No,
      a.Week_Starting_Wed_Seq_No,
      a.Week_Starting_Thu_Seq_No,
      a.Week_Starting_Fri_Seq_No,
      a.Week_Starting_Sat_Seq_No,
      a.Julian_Date,
      a.Modified_Julian_Date,
      a.ISO_Date,
      a.ISO_Year_Week_No,
      a.ISO_Week_No,
      a.ISO_Day_of_Week,
      a.ISO_Year_Week_Name,
      a.ISO_Year_Week_Day_of_Week_Name,
      a.Date_Format_yyyy_mm_dd,
      a.Date_Format_yyyy_M_D,
      a.Date_Format_mm_dd_yyyy,
      a.Date_Format_M_d_yyyy,
      a.Date_Format_mmm_d_yyyy,
      a.Date_Format_mmmmmmmmm_d_yyyy,
      a.Date_Format_mm_dd_YY,
      a.Date_Format_M_d_YY
   from
      #Dimension_Date a left join
      dbo.Dimension_Date b on a.Calendar_Date = b.Dimension_Dt
   where b.Dimension_Dt is null
   order by a.Calendar_Date

   dbcc dbreindex ('dbo.Dimension_Date') with no_infomsgs

   update statistics dbo.Dimension_Date with fullscan

   exec sp_spaceused 'dbo.Dimension_Date','true'

end try
begin catch
   select error_number() as ErrNum,
         error_line() as ErrLine,
         error_message() as ErrMsg
   if (@@TRANCOUNT > 0)
      Rollback;

   return 1;
end catch

return 0;

go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'p_Load_Table_Dimension_Date'
      and ROUTINE_TYPE = 'Procedure'
        ) begin
    print 'Function dbo.p_Load_Table_Dimension_Date was created successfully'
end else begin
    print 'Function dbo.p_Load_Table_Dimension_Date does not exist, create failed'
end


print ''
print 'End time is: ' + cast(sysdatetime() as varchar(36))
print '***** End of Procedure script for dbo.p_Load_Table_Dimension_Date *****'
print '------------------------------------------------------------'
print ''
go
go

/*

declare  @StartDate  date
declare  @EndDate date
declare  @CalcDate   date
declare  @NoDelete   int
declare  @TruncTbl   int
declare  @SQLECode   int
declare  @ErrCode int
declare  @ErrMsg     varchar(4000)

set @StartDate = '1980-01-01'
set @EndDate   = '2029-12-31'
set @CalcDate  = '1969-12-31'
set @NoDelete  = 0
set @TruncTbl  = 1

begin try

   exec dbo.p_Load_Table_Dimension_Date

         -- Starting date to load into Dimension_Date
         @Start_Date    = @StartDate,

         -- Ending date to load into Dimension_Date
         @End_Date      = @EndDate,

         -- Start date for computing the value of DIMENSION_DATE_ID
         -- The default is '1753/01/01
         -- It must be the same as the date in check constraint
         -- CHK_T_DIMENSION_DATE_ID_DATE_OFFSET created when table
         -- T_DIMENSION_DATE was created.
         @Start_Date_For_Id_Calculation   = @CalcDate,

         -- If 0, rows that fall outside the @Start_Date to @End_Date
         -- will be deleted from Dimension_Date
         -- If 1, no rows will be deleted
         -- Default to 0
         @Do_No_Delete_From_Table_Indicator  = @NoDelete,

         -- If 1 and @Start_Date_FOR_ID_CALCULATION <> 1
         -- table Dimension_Date will be truncated.
         -- Otherwise, Dimension_Date will not be truncated.
         @Truncate_Table_Indicator        =  @TruncTbl,

         --  Standard error handling output parameters
         @SQLErrorCode  = @SQLECode  output,
         @Errorcode     = @ErrCode  output,
         @ErrorMessage  = @ErrMsg  output

   select   @ErrCode as ErrorCode,
         @ErrMsg as ErrorMsg

end try
begin catch
   select   error_number() as ErrorNumber,
         error_message() as ErrorMEssage,
         error_line() as ErrorLine,
         error_state() as ErrorState,
         error_severity() as ErrorSeverity,
         error_procedure() as ErrorProcedure;
end catch

*/
