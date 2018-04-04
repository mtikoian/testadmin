select	object_name(mid.object_id) object_name,
		mid.equality_columns,
		mid.inequality_columns,
		mid.included_columns,
		(CONVERT(Numeric(19,6), migs.user_seeks)+CONVERT(Numeric(19,6), migs.unique_compiles))*CONVERT(Numeric(19,6), migs.avg_total_user_cost)*CONVERT(Numeric(19,6), migs.avg_user_impact/100.0) AS Score,
		migs.avg_user_impact,
		migs.avg_total_user_cost,
		migs.user_seeks,
		migs.user_scans
from	sys.dm_db_missing_index_details mid inner join sys.dm_db_missing_index_groups mig
on		mid.index_handle = mig.index_handle
		inner join sys.dm_db_missing_index_group_stats migs
on		mig.index_group_handle = migs.group_handle
where	mid.database_id = db_id()
order by (CONVERT(Numeric(19,6), migs.user_seeks)+CONVERT(Numeric(19,6), migs.unique_compiles))*CONVERT(Numeric(19,6), migs.avg_total_user_cost)*CONVERT(Numeric(19,6), migs.avg_user_impact/100.0) desc


