/*
** U_Tables.CQL    --- 1996/09/16 12:22
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
** ***********************
** If this file is updated for Denali, then do not forget to update the target level for u_table.sql
** in sql\ntdbms\mkmaster\scriptdlls\upgradesrc\sqlscriptupgrade.cpp
** 

c:\Program Files\Microsoft SQL Server\<InstanceDesignator>\MSSQL\Install
This is the SQL 2012 Version

*/

go
use master
go
set nocount on
go


declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Starting u_Tables.SQL at  %s',0,1,@vdt) with nowait
raiserror('This file creates all the system tables in master.',0,1)
go

-- Create a synonym spt_values in master pointing to spt_master in Resource DB,
-- for backward compat

if object_id('spt_values','U') IS NOT NULL
	begin
	print 'drop table spt_values ....'
	drop table spt_values
	end
go

if object_id('spt_values','SN') IS NOT NULL
	begin
	print 'drop synonym spt_values ....'
	drop synonym spt_values
	end
go

if object_id('spt_values','V') IS NOT NULL
	begin
	print 'drop view spt_values ....'
	drop view spt_values
	end
go

raiserror('Creating view ''%s''.', -1,-1,'spt_values')
go

create view spt_values as
select name collate database_default as name,
	number,
	type collate database_default as type,
	low, high, status
from sys.spt_values
go

EXEC sp_MS_marksystemobject 'spt_values'
go

grant select on spt_values to public
go

------------------------------------------------------------------

if object_id('spt_monitor','U') IS NOT NULL
	begin
	print 'drop table spt_monitor ....'
	drop table spt_monitor
	end
go

------------------------------------------------------------------
------------------------------------------------------------------

raiserror('Creating ''%s''.', -1,-1,'spt_monitor')
go

create table spt_monitor
(
	lastrun		datetime	NOT NULL,
	cpu_busy	int		NOT NULL,
	io_busy		int		NOT NULL,
	idle		int		NOT NULL,
	pack_received	int		NOT NULL,
	pack_sent	int		NOT NULL,
	connections	int		NOT NULL,
	pack_errors	int		NOT NULL,
	total_read	int		NOT NULL,
	total_write 	int		NOT NULL,
	total_errors 	int		NOT NULL
)
go

EXEC sp_MS_marksystemobject 'spt_monitor'
go

------------------------------------------------------------------

raiserror('Grant Select on spt_monitor',0,1)
go

grant select on spt_monitor to public
go


------------------------------------------------------------------
------------------------------------------------------------------


raiserror('Insert into spt_monitor ....',0,1)
go

insert into spt_monitor
	select
	lastrun = getdate(),
	cpu_busy = @@cpu_busy,
	io_busy = @@io_busy,
	idle = @@idle,
	pack_received = @@pack_received,
	pack_sent = @@pack_sent,
	connections = @@connections,
	pack_errors = @@packet_errors,
	total_read = @@total_read,
	total_write = @@total_write,
	total_errors = @@total_errors
go

-- Extended events default session
if exists(select * from sys.server_event_sessions where name='system_health')
	drop event session system_health on server
go
-- The predicates in this session have been carefully crafted to minimize impact of event collection
-- Changing the predicate definition may impact system performance
--
create event session system_health on server
add event sqlserver.error_reported
(
	action (package0.callstack, sqlserver.session_id, sqlserver.database_id, sqlserver.sql_text, sqlserver.tsql_stack)
	-- Get callstack, SPID, and query for all high severity errors ( above sev 20 )
	where severity >= 20
	-- Get callstack, SPID, and query for OOM errors ( 17803 , 701 , 802 , 8645 , 8651 , 8657 , 8902 )
	or (error_number = 17803 or error_number = 701 or error_number = 802 or error_number = 8645 or error_number = 8651 or error_number = 8657 or error_number = 8902)
),
add event sqlclr.clr_allocation_failure
	(action (package0.callstack, sqlserver.session_id)),
add event sqlclr.clr_virtual_alloc_failure
	(action (package0.callstack, sqlserver.session_id)),
add event sqlos.scheduler_monitor_non_yielding_ring_buffer_recorded,
add event sqlserver.xml_deadlock_report,
add event sqlos.wait_info
(
	action (package0.callstack, sqlserver.session_id, sqlserver.sql_text)
	where 
	(duration > 15000 and 
		(	
			(wait_type > 31	-- Waits for latches and important wait resources (not locks ) that have exceeded 15 seconds. 
				and
				(
					(wait_type > 47 and wait_type < 54)
					or wait_type < 38
					or (wait_type > 63 and wait_type < 70)
					or (wait_type > 96 and wait_type < 100)
					or (wait_type = 107)
					or (wait_type = 113)
					or (wait_type > 174 and wait_type < 179)
					or (wait_type = 186)
					or (wait_type = 207)
					or (wait_type = 269)
					or (wait_type = 283)
					or (wait_type = 284)
				)
			)
			or 
			(duration > 30000		-- Waits for locks that have exceeded 30 secs.
				and wait_type < 22
			) 
		)
	)
),
add event sqlos.wait_info_external
(
	action (package0.callstack, sqlserver.session_id, sqlserver.sql_text)
	where 
	(duration > 5000 and
		(   
			(	-- Login related preemptive waits that have exceeded 5 seconds.
				(wait_type > 365 and wait_type < 372)
				or	(wait_type > 372 and wait_type < 377)
				or	(wait_type > 377 and wait_type < 383)
				or	(wait_type > 420 and wait_type < 424)
				or	(wait_type > 426 and wait_type < 432)
				or	(wait_type > 432 and wait_type < 435)
			)
			or 
			(duration > 45000 	-- Preemptive OS waits that have exceeded 45 seconds. 
				and 
				(	
					(wait_type > 382 and wait_type < 386)
					or	(wait_type > 423 and wait_type < 427)
					or	(wait_type > 434 and wait_type < 437)
					or	(wait_type > 442 and wait_type < 451)
					or	(wait_type > 451 and wait_type < 473)
					or	(wait_type > 484 and wait_type < 499)
					or wait_type = 365
					or wait_type = 372
					or wait_type = 377
					or wait_type = 387
					or wait_type = 432
					or wait_type = 502
				)
			)
		)
	)
),
add event sqlos.memory_broker_ring_buffer_recorded,
add event sqlos.scheduler_monitor_deadlock_ring_buffer_recorded,
add event sqlos.scheduler_monitor_system_health_ring_buffer_recorded,
add event sqlos.scheduler_monitor_non_yielding_iocp_ring_buffer_recorded,
add event sqlos.scheduler_monitor_non_yielding_rm_ring_buffer_recorded,
add event sqlos.scheduler_monitor_stalled_dispatcher_ring_buffer_recorded,
add event sqlos.memory_node_oom_ring_buffer_recorded
	(action (package0.callstack, sqlserver.session_id, sqlserver.sql_text, sqlserver.tsql_stack)),
add event sqlserver.security_error_ring_buffer_recorded
	(set collect_call_stack = 1),
add event sqlserver.connectivity_ring_buffer_recorded
	(set collect_call_stack = 1),
add event sqlserver.sp_server_diagnostics_component_result
(
	set collect_data = 1
	where
		sqlserver.is_system = 1 and
		component != 4 /* DiagnoseComponent::DCCI_EVENTS */
)
add target package0.event_file		-- Store events on disk (in the LOG folder of the instance)
(
	set filename           = N'system_health.xel',
		max_file_size      = 5, /* MB */
		max_rollover_files = 4
),
add target package0.ring_buffer		-- Store events in the ring buffer target
	(set max_memory = 4096, max_events_limit = 5000)
with
(
	MAX_DISPATCH_LATENCY = 120 SECONDS,
	startup_state = on
)
go
if not exists (select * from sys.dm_xe_sessions where name = 'system_health')
	alter event session system_health on server state=start
go

-- AlwaysOn default session: AlwaysOn_health
-- For now the session is off by default.
if exists(select * from sys.server_event_sessions where name='AlwaysOn_health')
	drop event session AlwaysOn_health on server;
go

create event session AlwaysOn_health on server 
    add event sqlserver.alwayson_ddl_executed,
    add event sqlserver.availability_group_lease_expired,
    add event sqlserver.availability_replica_automatic_failover_validation,
    add event sqlserver.availability_replica_manager_state_change,
    add event sqlserver.availability_replica_state_change,
    add event lock_redo_blocked,
    add event sqlserver.error_reported
    (
        where 
        (
            --endpoint issue:stopped
            [error_number]=(9691)  
            or [error_number]=(35204) 
        
            --endpoint issue:invalid ip address
            or [error_number]=(9693) 
            or [error_number]=(26024)
         
            --endpoint issue:encryption and handshake issue
            or [error_number]=(28047)

            --endpoint issue:port conflict
            or [error_number]=(26023)
            or [error_number]=(9692) 

            --endpoint issue:authentication failure
            or [error_number]=(28034) 
            or [error_number]=(28036) 
            or [error_number]=(28048) 
            or [error_number]=(28080) 
            or [error_number]=(28091) 

            --endpoint:listening
            or [error_number]=(26022) 

            --endpoint issue:generic message
            or [error_number]=(9642) 

            --alwayson connection timeout information
            or [error_number]=(35201) --new connection timeout
            or [error_number]=(35202) --connected
            or [error_number]=(35206) --existing connection timeout
            or [error_number]=(35207) --general connection issue message

            --alwayson listener state
            or [error_number]=(26069) --started 
            or [error_number]=(26070) --stopped

            --wsfc cluster issues
            or [error_number]>(41047) and [error_number]<(41056)

            --failover validation message
            or [error_number]=(41142) 

            --availability group resource failure
            or [error_number]=(41144) 
            
            --database replica role change	
            or [error_number]=(1480) 

            --automatic page repair event
            or [error_number]=(823) 
            or [error_number]=(824) 
            or [error_number]=(829) 
            
            --database replica suspended resumed
            or [error_number]=(35264) 
            or [error_number]=(35265)
        )
    ) 

    add target package0.event_file
    (
        set filename = N'AlwaysOn_health.xel',
            max_file_size = 5,
            max_rollover_files = 4
    )
    with 
    (
        max_memory = 4 mb,
        event_retention_mode = allow_single_event_loss,
        max_dispatch_latency = 30 seconds,
        max_event_size = 0 mb,
        memory_partition_mode = none,
        track_causality = off,
        startup_state=off
    );
go

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Finishing at  %s',0,1,@vdt)
go

checkpoint
go



