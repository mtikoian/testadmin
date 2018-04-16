-- Delete the procedure
if exists
      (select *
         from sys.objects
        where object_id = object_id (N'aga.Audit_Activity_Report')
              and type in (N'P', N'PC'))
    begin
        print 'Procedure aga.Audit_Activity_Report exists and will be dropped, ' + convert(varchar(30), getdate(), 121);
        drop procedure aga.Audit_Activity_Report;
    end else begin
        print 'Procedure aga.Audit_Activity_Report does not exist, drop skipped'
    end
go

-- Create the procedure
create procedure aga.Audit_Activity_Report
            @id_BegDateTime  datetime = null,
            @id_EndDateTime  datetime = null
as
   begin
/*
=pod

=begin text

  Project: TSU - Account Group Goals

  Procedure: USER_AUDIT_ACTIVITY_REPORT

  Description:

      Generates the information needed to product and audit report based on the information in
      the Audit_Trail table for a specified date range.

  Parameters:

  Created: 05/13/2010

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

      -- While they are not actual constants, declare values that should be treated
      -- as constants
      declare @CONST_AUDIT_TYPE_INSERT varchar(6);
      declare @CONST_AUDIT_TYPE_UPDATE varchar(6);
      declare @CONST_AUDIT_TYPE_DELETE varchar(6);

      declare @CONST_TABLE_ACCOUNT_GROUP varchar(32);
      declare @CONST_TABLE_GROUP_DETAIL varchar(32);
      declare @CONST_TABLE_GROUP_RECIPIENT varchar(32);
      declare @CONST_TABLE_ACCOUNT_RECIPIENT varchar(32);

      declare @CONST_COL_INTERESTED_PARTY_ID varchar(32);
      declare @CONST_COL_ACCOUNT_ID varchar(32);
      declare @CONST_COL_ACCOUNT_GROUP_NUM varchar(32);
      declare @CONST_COL_GROUP_DETAIL_NUM varchar(32);

      -- Local declarations
      declare @AuditTrailID int;
      declare @AuditType varchar(10);
      declare @TableName varchar(32);
      declare @PrimaryKeyValue varchar(200);
      declare @PKField1 int;
      declare @PKField2 int;

      -- Temporary table for the Audit Report data
      create table #AuditReport (
         Audit_Trail_ID         numeric (15, 0) not null,
         Structure_Version_Tag  varchar (20) null,
         Table_Name             varchar (32) not null,
         Column_Name            varchar (32) not null,
         Audit_Type             varchar (10) not null,
         [user_id]              int null,
         Audit_Timestamp        datetime not null,
         Old_Value              varchar (200) null,
         New_Value              varchar (200) null,
         Primary_Key_Value      varchar (200) not null,
         Account_Group_Num      int null,
         Group_Detail_Num       int null,
         Account_ID             varchar(20) null,
         Interested_Party_ID    varchar(20) null
         constraint AUDIT_TRAIL_PK primary key nonclustered (Audit_Trail_ID asc))

      -- Cursor to iterate over qualified data in the temporary audit report table
      declare ar_cursor cursor for
         select Audit_Trail_ID,
               Table_Name,
               Audit_Type,
               Primary_Key_Value
         from #AuditReport

      -- Validate the date range for the report
      if (@id_BegDateTime is null) or (isdate(@id_BegDateTime) = 0)
      begin
         raiserror ('Begin datetime is null or an invalid datetime value.', 16, 1)
      end

      if (@id_EndDateTime is null) or (isdate(@id_EndDateTime) = 0)
      begin
         raiserror ('End datetime is null or an invalid datetime value.', 16, 1)
      end

      -- Set the values for are psuedo constants
      set @CONST_AUDIT_TYPE_INSERT = 'INSERT';
      set @CONST_AUDIT_TYPE_UPDATE = 'UPDATE';
      set @CONST_AUDIT_TYPE_DELETE = 'DELETE';

      set @CONST_COL_INTERESTED_PARTY_ID = 'INTERESTED_PARTY_ID';
      set @CONST_COL_ACCOUNT_ID = 'ACCOUNT_ID';
      set @CONST_COL_ACCOUNT_GROUP_NUM = 'ACCOUNT_GROUP_NUM';
      set @CONST_COL_GROUP_DETAIL_NUM = 'GROUP_DETAIL_NUM';

      set @CONST_TABLE_ACCOUNT_GROUP = 'ACCOUNT_GROUP';
      set @CONST_TABLE_GROUP_DETAIL = 'GROUP_DETAIL';
      set @CONST_TABLE_GROUP_RECIPIENT = 'GROUP_RECIPIENT';
      set @CONST_TABLE_ACCOUNT_RECIPIENT = 'ACCOUNT_RECIPIENT';

      -- Populated the temporary audit report table with the rows from the audit table that
      -- qualify withing the specified date range.
      insert into #AuditReport
         select Audit_Trail_ID,
               Structure_Version_Tag,
               Table_Name,
               Column_Name,
               Audit_Type,
               [user_id],
               Audit_Timestamp,
               Old_Value,
               New_Value,
               Primary_Key_Value,
               null,
               null,
               null,
               null
         from aga.Audit_Trail
         where Audit_Timestamp >= @id_BegDateTime
           and Audit_Timestamp <= @id_EndDateTime;

      -- Open the cursor to iterate over the temporary audit report table
      open ar_cursor;

      -- Fetch a row
      fetch next from ar_cursor
      into @AuditTrailID, @TableName, @AuditType, @PrimaryKeyValue;

      -- Process the rows
      while @@fetch_status = 0
      begin
         -- If the audit type is a delete
         if @AuditType <> @CONST_AUDIT_TYPE_DELETE
         begin
            -- and the table name is account group
            if @TableName = @CONST_TABLE_ACCOUNT_GROUP
            begin
               -- Get the PK field value
               select @PKField1 = cast(aga.GetAuditTrailPKField(@PrimaryKeyValue,@CONST_COL_ACCOUNT_GROUP_NUM) as int)
               -- Update the row with the PK value
               update #AuditReport
                  set Account_Group_Num = @PKField1
               where Audit_Trail_ID = @AuditTrailID;
            end
            -- or the table name is group_detail
            else if @TableName = @CONST_TABLE_GROUP_DETAIL
            begin
               select @PKField1 = cast(aga.GetAuditTrailPKField(@PrimaryKeyValue,@CONST_COL_GROUP_DETAIL_NUM) as int)
               -- Update the row with the PK value
               update #AuditReport
                  set Group_Detail_Num = @PKField1
               where Audit_Trail_ID = @AuditTrailID;
            end
            -- or the table name is group_recipient
            else if @TableName = @CONST_TABLE_GROUP_RECIPIENT
            begin
               -- Get the PK field
               select @PKField1 = cast(aga.GetAuditTrailPKField(@PrimaryKeyValue,@CONST_COL_ACCOUNT_GROUP_NUM) as int)
               select @PKField2 = cast(aga.GetAuditTrailPKField(@PrimaryKeyValue,@CONST_COL_INTERESTED_PARTY_ID) as varchar(20))
               -- Update the row with the PK value
               update #AuditReport
                  set Account_Group_Num = @PKField1, Interested_Party_ID = @PKField2
               where Audit_Trail_ID = @AuditTrailID;
            end
            else if @TableName = @CONST_TABLE_ACCOUNT_RECIPIENT
            begin
               -- Get the PK field
               select @PKField1 = cast(aga.GetAuditTrailPKField(@PrimaryKeyValue,@CONST_COL_ACCOUNT_ID) as varchar(20))
               select @PKField2 = cast(aga.GetAuditTrailPKField(@PrimaryKeyValue,@CONST_COL_INTERESTED_PARTY_ID) as varchar(20))
               -- Update the row with the PK value
               update #AuditReport
                set Account_ID = @PKField1,
                    Interested_Party_ID = @PKField2
               where Audit_Trail_ID = @AuditTrailID;
            end;
         end;

         -- Fetch the next row
         fetch next from ar_cursor
         into @AuditTrailID, @TableName, @AuditType, @PrimaryKeyValue;
      end

      -- Close and deallocate the cursor
      close ar_cursor;
      deallocate ar_cursor;

      -- Select the rows from the temporary audit report table order by the audit trail id and timestamp.
      -- Join in the account group and recipient table for additional info.
      select ar.Audit_Trail_ID,
             ar.Structure_Version_Tag,
             ar.Table_Name,
             ar.Column_Name,
             ar.Audit_Type,
             ar.[User_ID],
             ar.Audit_Timestamp,
             ar.Old_Value,
             ar.New_Value,
             ar.Primary_Key_Value,
             ar.Account_Group_Num,
             ag.Account_Group_Name,
             ar.Group_Detail_Num,
             ar.Account_ID,
             oa.Account_Short_Nm,
             ar.Interested_Party_ID,
             oip.Address_Line_1_Tx,
             oip.Effective_Dt,
             oip.Effective_Expire_Dt
      from #AuditReport ar
      left outer join aga.Account_Group ag on ar.Account_Group_Num = ag.Account_Group_Num
      left outer join dbo.ACCOUNT oa on ar.Account_ID = oa.Account_ID
      left outer join dbo.INTERESTED_PARTY oip on ar.Interested_Party_ID = oip.Interested_Party_ID
      order by Audit_Trail_ID,
               Audit_Timestamp
   end
go

-- Validate if procedure has been created.
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'Audit_Activity_Report')
   begin
      print 'Procedure aga.Audit_Activity_Report has been created, ' + convert(varchar(30), getdate(), 121);
   end
else
   begin
      print 'Procedure aga.Audit_Activity_Report has NOT been created.'
   end;
go
print ''

