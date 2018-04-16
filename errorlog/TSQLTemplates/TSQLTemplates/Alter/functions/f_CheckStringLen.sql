
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_CheckStringLen'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_CheckStringLen
end
go

go

create function dbo.f_CheckStringLen
             (
                @i_VarName  varchar(128),
                @i_VarValue varchar(8000),
                @i_MaxLen   int
             )
    returns varchar(200)

as
-- =pod
/**

Filename   : f_CheckStringLen.sql
Author     : Steve McLarnon
Created    : 2/5/2012 3:27:26 PM

Object: dbo.f_CheckStringLen
ObjectType : Table valued function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_CheckStringLen.sql $


Description:    This function returns a message for a string length check.
                If the length of the passed string exceeds the @i_MaxLen
                parameter, an error message is constructed otherwise the
                message returned is ''.

Params:
Name               | Datatype      | Description
----------------------------------------------------------------------------
@i_VarName          varchar(128)    The name of the variable or column tested.
@i_VarValue         varchar(8000)   The actual variable value.
@i_MaxLen           int             The max length that is allowable.

Revisions:
  Ini |    Date     | Description
---------------------------------
End
*/
-- =cut
begin

    return (
        case when len(@i_VarValue) > @i_MaxLen
                then 'Then length of ' + @i_VarName +
                    ' has exceeded the maximum size of ' +
                    cast(@i_MaxLen as varchar(5)) + ', ' +
                    'please reenter'
             else ''
        end
           );
end
go

go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_CheckStringLen'
      and ROUTINE_TYPE = 'Function'
        ) begin
        declare @Description    varchar(7500);

        set @Description =  'This function returns a message for a string length check. ' +
                            'If the length of the passed string exceeds the @i_MaxLen ' +
                            'parameter, an error message is constructed otherwise the ' +
                            'message returned is an empty string.';

            exec sys.sp_addextendedproperty
                    @name       = N'MS_Description',
                    @value      = @Description,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_CheckStringLen'

            exec sys.sp_addextendedproperty
                    @name       = N'SVN Revision',
                    @value      = N'$Rev: 394 $' ,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_CheckStringLen';


end else begin
    print 'Function dbo.f_CheckStringLen does not exist, create failed'
end
go

/*
-- Execution
declare @Field      varchar(8000) = replicate('*', 1000);
declare @MaxLen     int = 7999;
declare @FieldName  varchar(128)
declare @ResultMsg  varchar(200)
declare @ErrMsg     varchar

begin try
    set @FieldName = 'TestField'


	set @ResultMsg = dbo.f_CheckStringLen(@FieldName, @Field, @MaxLen)
	if @ResultMsg <> '' begin
	    raiserror(@ResultMsg, 16, 1)
	end

end try
begin catch
	select  error_number(),
	        error_message()

end catch

*/

