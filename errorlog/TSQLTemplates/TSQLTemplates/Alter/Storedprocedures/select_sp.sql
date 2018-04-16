--use D0931_435_AGA_DEV
-- Delete the procedure
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'GetActGrp')
   begin
        print 'Procedure aga.GetActGrp exists and will be dropped'
        drop procedure aga.GetActGrp;
        print 'Procedure aga.GetActGrp has been dropped.';
    end else begin
        print 'Procedure aga.GetActGrp does not exist, drop skipped'
   end;
go

-- Create the procedure
create procedure aga.GetActGrp
            @in_actgrpnum int
as
   begin
/*
=pod

=begin text

Project: TSU - Account Group Goals

Name: GetActGrp

Author: Patrick W. O'Brien 04/28/2010

Description: Retrieves a Account_Group row

Parameters:

 @in_ActGrpNum    Account_Group.Account_Group_Num
                  This parameter may not be null.

Returns:

        Account_Group.account_group_num
        Account_Group.account_group_name
        Account_Group.account_group_purpose_tx
        Account_Group.account_group_desc
        Account_Group.account_group_id
        Account_Group.group_type_cd
        Group_Type.group_type_name
        Account_Group.beginning_dt
        Account_Group.beginning_amt
        Account_Group.ending_dt
        Account_Group.ending_amt
        Account_Group.group_is_active_flg
        Account_Group.send_to_reporting_flg
        Account_Group.send_to_performance_flg
        Account_Group.reporting_extract_dt
        Account_Group.performance_extract_dt
        Account_Group.create_dt
        Account_Group.create_user_id
        Account_Group.update_dt
        Account_Group.update_user_id
        Account_Group.account_group_ver_num

Updated:
Revisions:
--------------------------------------------------------------------------------
INI Date            Description
--------------------------------------------------------------------------------
SRM 2011-08-17.1    Modified to use the aga schema for all aga objects. Changed
                    the BIS object references from synonyms to the dbo.<table>.
                    Changed the format somewhat.
	
=end text

=cut

*/
      declare @sql_error   integer;

      begin try
         -- Validate parameters
         if @in_actgrpnum is null
            begin
               raiserror ('ActGrpNum may not be null.', 16, 1);
            end

        select ag.account_group_num,
               ag.account_group_name,
               ag.account_group_purpose_tx,
               ag.account_group_desc,
               ag.account_group_id,
               ag.group_type_cd,
               gt.group_type_name,
               ag.beginning_dt,
               ag.beginning_amt,
               ag.ending_dt,
               ag.ending_amt,
               ag.group_is_active_flg,
               ag.send_to_reporting_flg,
               ag.send_to_performance_flg,
               ag.reporting_extract_dt,
               ag.performance_extract_dt,
               ag.create_dt,
               ag.create_user_id,
               ag.update_dt,
               ag.update_user_id,
               ag.account_group_ver_num
        from aga.Account_Group ag
            inner join aga.Group_Type gt on gt.group_type_cd = ag.group_type_cd
        where Account_Group_Num = @in_actgrpnum

      end try
      begin catch
         declare @errno int, @errmsg varchar (100), @errsev int, @errstate int;

         select @errno = error_number (),
                @errmsg = error_message (),
                @errsev = error_severity (),
                @errstate = error_state ();

         raiserror (@errmsg, @errsev, @errstate);
      end catch

      if @errno <> 0
         return @errno
      else
         return @sql_error
   end
go

-- Validate if procedure has been created.
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'GetActGrp')
   begin
      print 'Procedure aga.GetActGrp has been created.'
   end
else
   begin
      print 'Procedure aga.GetActGrp has NOT been created.'
   end;
go

print ''