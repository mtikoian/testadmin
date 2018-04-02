--Connect to Distributor
use distribution

select top 100 *
from dbo.MSrepl_errors
order by time desc

exec sp_browsereplcmds 
	@xact_seqno_start = '0x00000018000001C9000B00000000', 
	@xact_seqno_end = '0x00000018000001C9000B00000000'	

	
