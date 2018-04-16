
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_DelimitedSplit8K'
      and ROUTINE_TYPE = 'Function'
        ) 
begin
    drop function dbo.f_DelimitedSplit8K
end
go


create function dbo.f_DelimitedSplit8K
        (
            @pString varchar(8000),
            @pDelimiter char(1)
        )
returns table with SCHEMABINDING
as
/*

Filename: f_DelimitedSplit8K.sql
Author: Jeff Moden

Object: f_DelimitedSplit8K
ObjectType: table-valued function

$Author: smclarnon $
$Date: 2013-01-17 07:39:17 -0500 (Thu, 17 Jan 2013) $
$Rev: 235 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_DelimitedSplit8K.sql $

Description:    Yet another approach for taking a single string value
                that has a series of characters separated by a delimiter. The function
                splits the string using the delimiter character into a table of elements.
                The approach here is to create a table of integers that has as many rows
                as the string to be split. This guarantees that there will be enough
                elements in the table. This is the fastest split method we have tested.

Param1: @pString - the string to be split.
Param2: @pDelimiter - the character used as the delimiter.

OutputType: table

Output1: Item number - This is a ordinal value that is the row order.
Output2: Item_Value - This is the element that is the result of the split.

Revisions
Ini |    Date     | Description
---------------------------------
 $End:
*/

 RETURN
--===== "Inline" CTE Driven "Tally Table" produces values from 0 up to 10,000...
     -- enough to cover VARCHAR(8000)
  WITH E1(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),                          --10E+1 or 10 rows
       E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
       E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
 cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                     -- for both a performance gain and prevention of accidental "overruns"
                 SELECT TOP (ISNULL(DATALENGTH(@pString),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
                ),
cteStart(N1) AS (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
                 SELECT 1 UNION ALL
                 SELECT t.N+1 FROM cteTally t WHERE SUBSTRING(@pString,t.N,1) = @pDelimiter
                ),
cteLen(N1,L1) AS(--==== Return start and length (for use in substring)
                 SELECT s.N1,
                        ISNULL(NULLIF(CHARINDEX(@pDelimiter,@pString,s.N1),0)-s.N1,8000)
                   FROM cteStart s
                )
--===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
 SELECT ItemNumber = ROW_NUMBER() OVER(ORDER BY l.N1),
        Item       = SUBSTRING(@pString, l.N1, l.L1)
   FROM cteLen l
;
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_DelimitedSplit8K'
      and ROUTINE_TYPE = 'Function'
        ) 
begin

        declare @Description    varchar(7500);

        set @Description =  'Yet another approach for taking a single string value ' +
                            'that has a series of characters separated by a delimiter. The function ' +
                            'splits the string using the delimiter character into a table of elements. ' +
                            'The approach here is to create a table of integers that has as many rows ' +
                            'as the string to be split. This guarantees that there will be enough ' +
                            'elements in the table. This is the fastest split method we have tested.';

            exec sys.sp_addextendedproperty
                    @name       = N'MS_Description',
                    @value      = @Description,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_DelimitedSplit8K'

            exec sys.sp_addextendedproperty
                    @name       = N'SVN Revision',
                    @value      = N'$Rev: 235 $' ,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_DelimitedSplit8K';
end else begin
    print 'Function dbo.f_DelimitedSplit8K does not exist, create failed'
end
go
