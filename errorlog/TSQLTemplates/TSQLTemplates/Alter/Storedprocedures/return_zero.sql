--use D0931_435_AGA_DEV
-- Delete the procedure
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'UpdGrpTyp')
   begin
        print 'Procedure aga.UpdGrpTyp exists and will be dropped'
        drop procedure aga.UpdGrpTyp;
    end else begin
        print 'Procedure aga.UpdGrpTyp does not exist, drop skipped';
   end;
go

-- Create the procedure
create procedure aga.UpdGrpTyp 
                @in_grouptypecd                  int,
                @iv_grouptypename                varchar (40),
                @iv_groupnameprefixtx            varchar (6),
                @in_allowgroupinclusionflg       smallint,
                @in_requirereportfrequencyflg    smallint,
                @in_requiredatesandamountsflg    smallint
as
   begin
/*
=pod

=begin text

Project: TSU - Account Group Goals

Name: UpdGrpTyp

Author: Patrick W. O'Brien 04/28/2010

Description: Updates a Group_Type row

Parameters:

  @in_GroupTypeCd                  Group_Type.Group_Type_Cd
                                   This field may no be null.

  @iv_GroupTypeName                Group_Type.Group_Type_Name
                                   This field may no be null.

  @iv_GroupNamePrefixTx            Group_Type.Group_Name_Prefix_Tx

  @in_AllowGroupInclusionFlg       Group_Type.Allow_Group_Inclusion_Flg
                                   This field may no be null.

  @in_RequireReportFrequencyFlg    Group_Type.Require_Report_Frequency_Flg

  @in_RequireDatesAndAmountsFlg    Group_Type.Require_Dates_And_Amounts_Flg

Returns:

    0 - Success

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
         if @iv_grouptypename is null
            begin
               raiserror ('GroupTypeName may not be null.', 16, 1);
            end

         if @in_allowgroupinclusionflg is null
            begin
               raiserror ('AllowGroupInclusionFlg may not be null.', 16, 1);
            end

         -- Begin the transaction
         begin tran updategrouptype

         -- Update the row
         update aga.Group_Type
            set Group_Type_Name = @iv_grouptypename,
                Group_Name_Prefix_Tx = @iv_groupnameprefixtx,
                Allow_Group_Inclusion_Flg = @in_allowgroupinclusionflg,
                Require_Report_Frequency_Flg = @in_requirereportfrequencyflg,
                Require_Dates_And_Amounts_Flg = @in_requiredatesandamountsflg,
                Group_Type_Ver_Num = Group_Type_Ver_Num + 1
          where Group_Type_Cd = @in_grouptypecd

         -- If we did not update a row
         if @@rowcount < 1
            begin
               raiserror ('No rows were updated.', 16, 1)
            end
         -- If we updated more then one row
         else
            if @@rowcount > 1
               begin
                  rollback
                  raiserror ('More then one row would be updated', 16, 1)
               end

         -- Commit the transaction
         commit tran updategrouptype

         -- Return zero as the return code
         return 0
      end try
      begin catch
         declare @errno int, @errmsg varchar (100), @errsev int, @errstate int;
         
         if @@trancount > 0
            rollback transaction;

         select @errno = error_number (),
                @errmsg = error_message (),
                @errsev = error_severity (),
                @errstate = error_state ();

         raiserror (@errmsg, @errsev, @errstate);
      end catch

      if @errno <> 0
         return @errno
      else
         return @sql_error;
   end
go

-- Validate if procedure has been created.
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'UpdGrpTyp')
   begin
      print 'Procedure aga.UpdGrpTyp has been created.';
   end
else
   begin
      print 'Procedure aga.UpdGrpTyp has NOT been created.';
   end;
go

print ''
