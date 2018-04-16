USE NETIKDP
GO

PRINT '------------------------------------------------------------'
PRINT '***** Procedure script for dbo.Inf_que_transfer_accountactivity_geneva *****'
PRINT 'Start time is: ' + cast(getutcdate() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT 1
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbo'
			AND ROUTINE_NAME = 'Inf_que_transfer_accountactivity_geneva'
			AND ROUTINE_TYPE = 'Procedure'
		)
BEGIN
	PRINT 'Dropping procedure dbo.Inf_que_transfer_accountactivity_geneva'

	DROP PROCEDURE dbo.Inf_que_transfer_accountactivity_geneva
END
ELSE
BEGIN
	PRINT 'Procedure dbo.Inf_que_transfer_accountactivity_geneva does not exist, skipping drop'
END
GO

PRINT ''
PRINT 'End time is: ' + cast(getutcdate() AS VARCHAR(36))
PRINT '***** End of Procedure script for dbo.Inf_que_transfer_accountactivity_geneva *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO


