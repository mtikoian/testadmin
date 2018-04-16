--declare @dbid int
--set @dbid = db_id()	
--
--select	d.object_id,
--		object_name(d.object_id) objectname,
--		d.index_id,
--		i.name indexname,
--		d.avg_fragmentation_in_percent,
--		d.page_count,
--		d.avg_fragment_size_in_pages
--/*			d.partition_number,
--		d.index_type_desc, */
--from	sys.dm_db_index_physical_stats(@dbid,null,null,null,NULL) d inner join sys.indexes i
--on		d.object_id = i.object_id and d.index_id = i.index_id
--where	--d.avg_fragmentation_in_percent > 10.0 and
--		d.index_id > 0 and
--		d.page_count > 30

select	db_name(d.database_id) dbname,
		object_name(d.object_id) objectname,
		i.name,
		d.user_seeks,
		d.last_user_seek,
		d.user_scans,
		d.last_user_scan,
		d.user_lookups,
		d.user_updates,
		d.user_scans + d.user_seeks + d.user_lookups total_uses
from	sys.dm_db_index_usage_stats d inner join sys.indexes i
on		d.index_id = i.index_id and d.object_id = i.object_id
		inner join sys.objects o
on		d.object_id = o.object_id
where	database_id = db_id() and
		schema_name(o.schema_id) <> 'sys'
order by o.name,d.user_scans + d.user_seeks + d.user_lookups asc

