declare	@pctusedThreshold	decimal(5,2) = 80.0;

declare	@name		sysname,
		@filename	sysname,
		@filesizeMB	int,
		@freeMB		int,
		@usedMB		int,
		@pctfree	int,
		@pctused	int;
		
declare	@message	varchar(2047);

declare	@session_id	int,
		@task_alloc	int,
		@query_text	varchar(max);
		
set nocount on

--	This outer query only exists so that we can easily filter on pcused
select	*
into	#t1
from	(
		--	This query adds percentage free and percentage used information
		select	fileid,
				name,
				filename,
				filesizeMB,
				freeMB,
				usedMB,
				pctfree = freeMB / filesizeMB * 100.0,
				pctused = usedMB / filesizeMB * 100.0
		from	(
				--	This query is useful all by itself, it returns information on a per-file basis
				select	f.fileid,
						f.name,
						f.filename,
						filesizeMB	= 
							SUM(unallocated_extent_page_count 
							+	user_object_reserved_page_count 
							+	internal_object_reserved_page_count 
							+	mixed_extent_page_count 
							+	version_store_reserved_page_count)	* (8.0/1024.0),
						freeMB		=
							SUM(unallocated_extent_page_count)		* (8.0/1024.0),
						usedMB		=
							SUM(user_object_reserved_page_count 
							+	internal_object_reserved_page_count 
							+	mixed_extent_page_count 
							+	version_store_reserved_page_count)	* (8.0/1024.0)	
				from	tempdb.sys.dm_db_file_space_usage	u	--	Note that sys.dm_db_file_space_usage is 
																--	only relevant within the tempdb database
				join	tempdb.sys.sysfiles					f	on (f.fileid = u.file_id)
				group by
						f.fileid,
						f.name,
						f.filename
				) a
		) b
where	pctused > @pctusedThreshold

if exists (select * from #t1)
begin
	declare	fullfiles cursor for 
	select	name,
			filename,
			filesizeMB,
			freeMB,
			usedMB,
			pctfree,
			pctused
	from	#t1
	order by
			fileid,
			name,
			filename;
	open fullfiles
	fetch fullfiles into @name, @filename, @filesizeMB, @freeMB, @usedMB, @pctfree, @pctused
	while	@@fetch_status = 0
	begin
		set @message = 'tempdb file ' + @name + ' (' + @filename + ') is ' + cast(@pctused as varchar(3)) + ' percent full'
		raiserror (@message, 10, 1) with log;
		fetch fullfiles into @name, @filename, @filesizeMB, @freeMB, @usedMB, @pctfree, @pctused
	end
	close fullfiles
	deallocate fullfiles
		
	declare tempdb_consumers cursor for
	select	session_id,
			task_alloc,
			query_text
	from	(
			--query sourced from http://blogs.msdn.com/b/sqlserverstorageengine/archive/2009/01/12/tempdb-monitoring-and-troubleshooting-out-of-space.aspx
			--We're not using everything it returns, just kept it all here for reference
			select	top 5
					t1.session_id, 
					t1.request_id, 
					t1.task_alloc,
						 t1.task_dealloc,  
						(SELECT SUBSTRING(text, t2.statement_start_offset/2 + 1,
							  (CASE WHEN statement_end_offset = -1 
								  THEN LEN(CONVERT(nvarchar(max),text)) * 2 
									   ELSE statement_end_offset 
								  END - t2.statement_start_offset)/2)
						 FROM sys.dm_exec_sql_text(sql_handle)) AS query_text,
					 (SELECT query_plan from sys.dm_exec_query_plan(t2.plan_handle)) as query_plan
					 
					from      (Select session_id, request_id,
					sum(internal_objects_alloc_page_count +   user_objects_alloc_page_count) as task_alloc,
					sum (internal_objects_dealloc_page_count + user_objects_dealloc_page_count) as task_dealloc
						   from sys.dm_db_task_space_usage 
						   group by session_id, request_id) as t1, 
						   sys.dm_exec_requests as t2
			where	t1.session_id = t2.session_id
			and		t1.request_id = t2.request_id
			and		t1.session_id > 50
			order by 
					t1.task_alloc DESC
			) a
		order by
			task_alloc desc
		
		open tempdb_consumers
		fetch tempdb_consumers into @session_id, @task_alloc, @query_text
		while @@fetch_status = 0
		begin
			set @message = 'Session ' + cast(@session_id as varchar(20)) + ' is consuming ' + cast(@task_alloc as varchar(20)) + ' pages in tempdb.  Current statement = ' + @query_text
			raiserror (@message, 10, 1) with log;
			fetch tempdb_consumers into @session_id, @task_alloc, @query_text
		end
		close tempdb_consumers
		deallocate tempdb_consumers
end
drop table #t1




		
