-- Delete the procedure
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'PERFSTA_Extract')
   begin
        print 'Procedure aga.PERFSTA_Extract exists and will be dropped'
        drop procedure aga.PERFSTA_Extract;
    end else begin
        print 'Procedure aga.PERFSTA_Extract does not exist, drop skipped'
   end;
go

-- Create the procedure
create procedure aga.perfsta_extract
            @id_oldextractdt datetime = null,
            @id_newextractdt datetime = null
as
   begin
/*
=pod

=begin text

Project: TSU - Account Group Goals

Name: PerformanceExtract

Author: Patrick W. O'Brien 04/28/2010

Description:

    This procedure will produce a result set that is the extract data from the
    Account Group Goals database for Performance Station.

    A delta methodology is used to determine what to export. Each time the
    procedure is executed (see note below), the current state of the Account_Group
    and Group_Detail is rendered into the PERFSTA_STATE table. This state is then compared
    to the last performance extract state.


    Note: If the parameters are specified, the existing state for each the parameter
          dates is used.

Parameters:

    @id_OldExtractDt - Datetime

       If valued, used as the last extract date.
       The existing PERSTA_STATE rows are used.

    @id_NewExtractDt - Datetime

       If valued, used as the current extract date.
       The existing PERSTA_STATE rows are used.

Returns:

    See #extract table.

Updated: 06/21/2010 Patrick W. O'Brien

    Changed extract table field sizes for second specification.
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
         -- Local declarations
         declare @ln_count   int;
         declare @ld_performanceextractdt   datetime;
         declare @ld_lastperformanceextractdt   datetime;

         -- Extract table variables
         declare @lv_ext_account            varchar (14);
         declare @lv_ext_agg                varchar (11);
         declare @lv_ext_status             varchar (01);
         declare @lv_ext_aggname            varchar (05);
         declare @lv_ext_aggtype            varchar (03);
         declare @lv_ext_leadaccount        varchar (14);
         declare @lv_ext_goalname           varchar (100);
         declare @lv_ext_goalstartdt        varchar (08);
         declare @lv_ext_goalstartvalue     varchar (14);
         declare @lv_ext_goaltargetdt       varchar (08);
         declare @lv_ext_goaltargetvalue    varchar (14);


         -- Stop messaging of the rows affected by SQL statements
         set nocount on;

         -- Begin the transaction
         begin tran psextract

         -- If the caller did not pass any values for the parameters ...
         if (@id_newextractdt is null) and (@id_oldextractdt is null)
            begin
               -- We need to make sure that any account_group that is sent to performance station
               -- does not have an account_group_id with a length greater than 11.
               select @ln_count = count (*)
               from aga.Account_Group
               where Send_To_Performance_Flg = 1
                 and len (Account_Group_ID) > 11;

               if @ln_count > 0
                  begin
                     raiserror ('An Account_Group to be sent to Performance Station has an Account_Group_ID with a length greater than eleven.', 16, 1);
                  end;

               -- Get the current datetime
               set @ld_performanceextractdt = getdate ();

               -- Get the last completed extract date from the account group table
               select @ld_lastperformanceextractdt = max (Performance_Extract_Dt)
               from aga.Account_Group;

               -- Create the temporary table to hold the flattened account group accounts
               if exists
                     (select *
                        from sys.objects
                       where object_id = object_id (N'#actgrpacts') and type in (N'U'))
                  begin
                     drop table #actgrpacts;
                  end

               create table #actgrpacts (
                  Account_Group_Num   int not null,
                  Account_ID          varchar (20) not null,
                  constraint ActGrpActs_PK primary key nonclustered (Account_Group_Num , Account_ID )
               );

               -- Get all the accounts related to the account groups flattened
               with cte (level, Account_Group_Num, Group_Detail_Num, Included_Account_Group_Num, Account_ID)
                       as (select 0,
                                  gd.account_group_num,
                                  gd.group_detail_num,
                                  gd.included_account_group_num,
                                  gd.account_id
                             from aga.Group_Detail gd
                           union all
                           select 1,
                                  cte.account_group_num,
                                  gd2.group_detail_num,
                                  gd2.included_account_group_num,
                                  gd2.account_id
                             from    aga.Group_Detail gd2
                                  inner join
                                     cte
                                  on cte.included_account_group_num = gd2.account_group_num)
               insert into #actgrpacts
                  select distinct Account_Group_Num, Account_ID
                    from cte
                   where Account_ID is not null;

               -- Add the Account_Group information to the PERFSTA_STATE table
               -- where the account group is being sent to performance station.
               insert into aga.Perfsta_State
                  select @ld_performanceextractdt,
                         ag.account_group_num,
                         right(ag.account_group_id,len(ag.account_group_id)-3),
                         ag.group_type_cd,
                         ag.account_group_name,
                         ag.account_group_purpose_tx,
                         ag.beginning_amt,
                         ag.beginning_dt,
                         ag.ending_amt,
                         ag.ending_dt,
                         aga.account_id
                  from aga.Account_Group ag
                    inner join #actgrpacts aga on ag.account_group_num = aga.account_group_num
                  where Send_To_Performance_Flg = 1;
            end
         -- The caller specified the old and new extract dates.  Use these
         -- on the existing perfsta_state rows to produce the extract.
         else
            begin
               set @ld_performanceextractdt = @id_newextractdt;
               set @ld_lastperformanceextractdt = @id_oldextractdt;
            end

         -- Drop the temporary extract table
         if exists
               (select *
                  from sys.objects
                 where object_id = object_id (N'[dbo].[#Extract]') and type in (N'U'))
            begin
         drop table [dbo].[#extract];
            end

         -- Create the temporary Performance Extract table
         create table #extract
         (
            Account_Group_Num   int not null,
            ACCOUNT             char (014) null,
            agg                 char (011) null,
            status              char (001) not null,
            aggname             char (050) null,
            aggtype             char (003) null,
            leadaccount         char (014) null,
            goalname            char (100) null,
            goalstartdt         char (008) null,
            goalstartvalue      char (015) null,
            goaltargetdt        char (008) null,
            goaltargetvalue     char (015) null
         );

         -- New Groups - Status 1
         insert into #extract
            select distinct ps.account_group_num,
                            ps.account_id,
                            ps.account_group_id,                                                                  -- AGG
                            '1',                                                                               -- Status
                            ps.account_group_name,
                            'G',
                            '',                                                                         -- LeadAccount
                            ps.account_group_purpose_tx,
                            convert (varchar (8), ps.beginning_dt, 112),
                            cast (ps.beginning_amt as decimal (15, 2)),
                            convert (varchar (8), ps.ending_dt, 112),
                            cast (ps.ending_amt as decimal (15, 2))
              from    (select distinct new.account_group_num
                         from aga.Perfsta_State new
                        where Extract_Dt = @ld_performanceextractdt
                              and new.account_group_num not in (select distinct old.account_group_num
                                                                  from aga.Perfsta_State old
                                                                 where Extract_Dt = @ld_lastperformanceextractdt)) xx
                   inner join
                      aga.Perfsta_State ps
                   on xx.account_group_num = ps.account_group_num;

         -- Deleted Groups - Status B
         insert into #extract
            select distinct ps.account_group_num,
                            null,
                            ps.account_group_id,                                                                  -- AGG
                            'B',                                                                               -- Status
                            null,
                            null,
                            '',                                                                           -- LeadAccount
                            null,
                            null,
                            null,
                            null,
                            null
              from    (select distinct old.account_group_num
                         from aga.Perfsta_State old
                        where Extract_Dt = @ld_lastperformanceextractdt
                              and old.account_group_num not in (select distinct new.account_group_num
                                                                  from aga.Perfsta_State new
                                                                 where Extract_Dt = @ld_performanceextractdt)) xx
                   inner join
                      aga.Perfsta_State ps
                   on xx.account_group_num = ps.account_group_num;

         -- Existing Groups, New Accounts - Status 2
         insert into #extract
            select distinct ps.account_group_num,
                            ps.account_id,
                            ps.account_group_id,                                                                  -- AGG
                            '2',                                                                               -- Status
                            null,
                            null,
                            '',                                                                           -- LeadAccount
                            null,
                            null,
                            null,
                            null,
                            null
              from    (select distinct new.account_group_num, new.account_id
                         from aga.Perfsta_State new
                        where new.extract_dt = @ld_performanceextractdt
                              and new.account_id not in
                                     (select distinct old.account_id
                                        from aga.Perfsta_State old
                                       where old.extract_dt = @ld_lastperformanceextractdt
                                             and old.account_group_num = new.account_group_num)) xx
                   inner join
                      aga.Perfsta_State ps
                   on xx.account_group_num = ps.account_group_num and xx.account_id = ps.account_id;

         -- Existing Groups, Deleted Accounts - Status 3
         insert into #extract
            select distinct ps.account_group_num,
                            ps.account_id,
                            ps.account_group_id,                                                                  -- AGG
                            '3',                                                                               -- Status
                            null,
                            null,
                            '',                                                                           -- LeadAccount
                            null,
                            null,
                            null,
                            null,
                            null
              from    (select distinct old.account_group_num, old.account_id
                         from aga.Perfsta_State old
                        where old.extract_dt = @ld_lastperformanceextractdt
                              and old.account_id not in
                                     (select distinct new.account_id
                                        from aga.Perfsta_State new
                                       where new.extract_dt = @ld_performanceextractdt
                                             and new.account_group_num = old.account_group_num)) xx
                   inner join
                      aga.Perfsta_State ps
                   on xx.account_group_num = ps.account_group_num and xx.account_id = ps.account_id;

         -- Aggregate Name Changed - Status 4
         insert into #extract
            select yy.account_group_num,
                   null,
                   ag.account_group_id,                                                                           -- AGG
                   '4',                                                                                        -- Status
                   yy.account_group_name,
                   null,
                   '',                                                                                    -- LeadAccount
                   null,
                   null,
                   null,
                   null,
                   null
              from    (select distinct new.account_group_num, new.account_group_name
                         from    (select distinct old.account_group_num, old.account_group_name
                                    from aga.Perfsta_State old
                                   where old.extract_dt = @ld_lastperformanceextractdt) xx
                              inner join
                                 aga.Perfsta_State new
                              on xx.account_group_num = new.account_group_num
                        where new.extract_dt = @ld_performanceextractdt
                              and nullif (xx.account_group_name, '') <> nullif (new.account_group_name, '')) yy
                   inner join
                      aga.Account_Group ag
                   on yy.account_group_num = ag.account_group_num

         -- Existing aggregate that is not a statement group - Status 5
         --
         -- *** We do not have this status type. N/A
         --

         -- Goal Name changed - Status 6
         insert into #extract
            select yy.account_group_num,
                   null,
                   ag.account_group_id,                                                                           -- AGG
                   '6',                                                                                        -- Status
                   ag.account_group_name,
                   null,
                   '',                                                                                    -- LeadAccount
                   null,
                   null,
                   null,
                   null,
                   null
              from    (select distinct new.account_group_num, new.account_group_purpose_tx
                         from    (select distinct old.account_group_num, old.account_group_purpose_tx
                                    from aga.Perfsta_State old
                                   where old.extract_dt = @ld_lastperformanceextractdt) xx
                              inner join
                                 aga.Perfsta_State new
                              on xx.account_group_num = new.account_group_num
                        where new.extract_dt = @ld_performanceextractdt
                              and xx.account_group_purpose_tx <> new.account_group_purpose_tx) yy
                   inner join
                      aga.Account_Group ag
                   on yy.account_group_num = ag.account_group_num;


         -- Goal Start Date changed - Status 7
         insert into #extract
            select yy.account_group_num,
                   null,
                   ag.account_group_id,                                                                           -- AGG
                   '7',                                                                                        -- Status
                   null,
                   null,
                   '',                                                                                    -- LeadAccount
                   null,
                   convert (varchar (8), yy.beginning_dt, 112),
                   null,
                   null,
                   null
              from    (select distinct new.account_group_num, new.beginning_dt
                         from    (select distinct old.account_group_num, old.beginning_dt
                                    from aga.Perfsta_State old
                                   where old.extract_dt = @ld_lastperformanceextractdt) xx
                              inner join
                                 aga.Perfsta_State new
                              on xx.account_group_num = new.account_group_num
                        where new.extract_dt = @ld_performanceextractdt
                              and isnull (xx.beginning_dt, 0) <> isnull (new.beginning_dt, 0)) yy
                   inner join
                      aga.Account_Group ag
                   on yy.account_group_num = ag.account_group_num;

         -- Goal Start Value changed - Status 8
         insert into #extract
            select yy.account_group_num,
                   null,
                   ag.account_group_id,                                                                           -- AGG
                   '8',                                                                                        -- Status
                   null,
                   null,
                   '',                                                                                    -- LeadAccount
                   null,
                   null,
                   cast (yy.beginning_amt as decimal (15, 2)),
                   null,
                   null
              from    (select distinct new.account_group_num, new.beginning_amt
                         from    (select distinct old.account_group_num, old.beginning_amt
                                    from aga.Perfsta_State old
                                   where old.extract_dt = @ld_lastperformanceextractdt) xx
                              inner join
                                 aga.Perfsta_State new
                              on xx.account_group_num = new.account_group_num
                        where new.extract_dt = @ld_performanceextractdt
                              and isnull (xx.beginning_amt, 0) <> isnull (new.beginning_amt, 0)) yy
                   inner join
                      aga.Account_Group ag
                   on yy.account_group_num = ag.account_group_num;

         -- Goal Target Date changed - Status 9
         insert into #extract
            select yy.account_group_num,
                   null,
                   ag.account_group_id,                                                                           -- AGG
                   '9',                                                                                        -- Status
                   null,
                   null,
                   '',                                                                                    -- LeadAccount
                   null,
                   null,
                   null,
                   convert (varchar (8), yy.ending_dt, 112),
                   null
              from    (select distinct new.account_group_num, new.ending_dt
                         from    (select distinct old.account_group_num, old.ending_dt
                                    from aga.Perfsta_State old
                                   where old.extract_dt = @ld_lastperformanceextractdt) xx
                              inner join
                                 aga.Perfsta_State new
                              on xx.account_group_num = new.account_group_num
                        where new.extract_dt = @ld_performanceextractdt
                              and isnull (xx.ending_dt, 0) <> isnull (new.ending_dt, 0)) yy
                   inner join
                      aga.Account_Group ag
                   on yy.account_group_num = ag.account_group_num;

         -- Goal Target Value changed - Status A
         insert into #extract
            select yy.account_group_num,
                   null,
                   ag.account_group_id,                                                                           -- AGG
                   'A',                                                                                        -- Status
                   null,
                   null,
                   '',                                                                                    -- LeadAccount
                   null,
                   null,
                   null,
                   null,
                   cast (yy.ending_amt as decimal (15, 2))
              from    (select distinct new.account_group_num, new.ending_amt
                         from    (select distinct old.account_group_num, old.ending_amt
                                    from aga.Perfsta_State old
                                   where old.extract_dt = @ld_lastperformanceextractdt) xx
                              inner join
                                 aga.Perfsta_State new
                              on xx.account_group_num = new.account_group_num
                        where new.extract_dt = @ld_performanceextractdt
                              and isnull (xx.ending_amt, 0) <> isnull (new.ending_amt, 0)) yy
                   inner join
                      aga.Account_Group ag
                   on yy.account_group_num = ag.account_group_num;

         -- We need to adjust the formats of the dates in the extract table
         -- to MMDDYYYY from YYYYMMDD
         update #extract
            set goalstartdt =
                     substring (convert (varchar (8), goalstartdt, 112), 5, 2)
                   + substring (convert (varchar (8), goalstartdt, 112), 7, 2)
                   + substring (convert (varchar (8), goalstartdt, 112), 1, 4)
          where goalstartdt is not null;

         update #extract
            set goaltargetdt =
                     substring (convert (varchar (8), goaltargetdt, 112), 5, 2)
                   + substring (convert (varchar (8), goaltargetdt, 112), 7, 2)
                   + substring (convert (varchar (8), goaltargetdt, 112), 1, 4)
          where goaltargetdt is not null;

         -- Update the account groups that are processed
         update aga.Account_Group
            set Performance_Extract_Dt = @ld_performanceextractdt
          where Account_Group_Num in (select distinct Account_Group_Num
                                        from Perfsta_State
                                       where Extract_Dt = @ld_performanceextractdt);

         -- Commit the transaction
         commit tran psextract;

         -- Select the data to be exported to performance station.
         select cast(ACCOUNT as char(14)) [ACCOUNT],
                cast(agg as char(11)) [AGG],
                cast(status as char(1)) [Status],
                cast(aggname as char(50)) [AGGName],
                cast(aggtype as char(3)) [AGGType],
                cast(leadaccount as char(14)) [LeadAccount],
                cast(goalname as char(100)) [GoalName],
                cast(goalstartdt as char(8)) [GoalStartDt],
                cast(ltrim(goalstartvalue) as char(15)) [GoalStartValue],
                cast(goaltargetdt as char(8)) [GoalTargetDt],
                cast(ltrim(goaltargetvalue) as char(15)) [GoalTargetValue],
                cast(Account_Group_Num as char(30)) [Account_Group_Num]
           from #extract;
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
         return @sql_error
   end
go

-- Validate if procedure has been created.
if exists
      (select *
         from information_schema.routines
        where specific_schema = N'aga' and specific_name = N'PERFSTA_Extract')
   begin
      print 'Procedure aga.PERFSTA_Extract has been created.'
   end
else
   begin
      print 'Procedure aga.PERFSTA_Extract has NOT been created.'
   end;
go

print ''