--select spid, blocked, waittype
--    , waittime, lastwaittype, dbid
--    , uid, cpu, physical_io, memusage
--    , login_time, last_batch, hostname
--    , program_name, nt_domain, nt_username, loginame 
-- from master..sysprocesses
-- where blocked <> 0 
-- or spid in (select blocked from master..sysprocesses)

select convert(char(24),getdate(),13)
	select 'Blocker(s) causing the problem.'
	select distinct
	'ID'       = str( spid, 5 ),
	'Status'   = convert( char(10), status ),
	'Blk'      = str( blocked, 2 ),
	'Station'  = convert( char(15), hostname ),
	'User'     = convert( char(15), loginame ),
	'DbName'   = convert( char(15), db_name( dbid ) ),       
	'Program'  = convert( char(10), program_name ),
	'Command'  = convert( char(16), cmd ),
	'    CPU'  = str( cpu, 7 ),
	'     IO'  = str( physical_io, 7 )
	from master..sysprocesses
	where spid in ( select blocked from master..sysprocesses )
	and blocked = 0
	order by str(spid,5)

	/* show victims */

	select 'Victims of the above blocker(s).'
	select 'ID'= str( spid, 5 ),
	'Status'   = convert( char(15), status ),
	'Blk'      = str( blocked, 3 ),
	'Station'  = convert( char(15), hostname ),
	'User'     = convert( char(15), loginame ),
	'DbName'   = convert( char(15), db_name( dbid ) ),
	'Program'  = convert( char(10), program_name ),
	'Command'  = convert( char(16), cmd ),
	'    CPU'  = str( cpu, 7 ),
	'     IO'  = str( physical_io, 7 )
	from master..sysprocesses
	where blocked <> 0
	order by spid
