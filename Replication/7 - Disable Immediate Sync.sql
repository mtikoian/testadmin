--Connect to Publisher
use Publisher
go

exec sp_changepublication
	@publication = 'OOO',
	@property = 'allow_anonymous',
	@value = 'false'

exec sp_changepublication
	@publication = 'OOO',
	@property = 'immediate_sync',
	@value = 'false'




