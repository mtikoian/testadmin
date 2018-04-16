

PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for RELATEDCONTACT_RELATIONSHIP'
PRINT '----------------------------------------'

BEGIN TRY

	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'RELATEDCONTACT_RELATIONSHIP'  
		)
		BEGIN
			DROP Table dbo.RELATEDCONTACT_RELATIONSHIP
			PRINT 'Table dbo.RELATEDCONTACT_RELATIONSHIP has been dropped.'
		END


	/*
	================================================================================
	 Name        : RELATEDCONTACT_RELATIONSHIP 
	 Author      : SGottipati - 05/30/2013
	 Description : Table to information relationship information between Investor and Intrested party
	===============================================================================
			
	 Revisions    :
	--------------------------------------------------------------------------------
	 Ini		    |   Date		|	 Description
	 SGottipati		|  05/30/2013	|	 Initial Version
	 Venu Perala	|  06/09/2013   |	 
	--------------------------------------------------------------------------------

	================================================================================
	*/


	CREATE TABLE dbo.RELATEDCONTACT_RELATIONSHIP
	(
		RELATEDCONTACT_RELATIONSHIP_ID 				INT IDENTITY(1,1)	NOT NULL,
		IV_SYSID									VARCHAR(12) 		NOT NULL,  --concatenation of Netik clientId and Investor System generated Id(Investier)
		IP_SYSID									VARCHAR(12) 		NOT NULL,  /*concatenation of Netik clientId and Intrested Party system generated Id(Investier); 
																				     fk to the RELATEDCONTACT table*/
		IV_ID										VARCHAR(50) 		NOT NULL,  --Investor Id business users created	
		CREATED_USR_ID								VARCHAR(20)			NOT NULL,	   --Created user id
		CREATED_TMS									DATETIME			NOT NULL,	   --Created date and time		
		LST_CHG_USR_ID								VARCHAR(20) 		NOT NULL,  --Last updated userid
		LST_CHG_TMS									DATETIME    		NOT NULL,  --Last updated date and time
	) ON [PRIMARY]

	PRINT 'Adding constraints to TABLE dbo.RELATEDCONTACT_RELATIONSHIP'
	ALTER TABLE dbo.RELATEDCONTACT_RELATIONSHIP ADD
		constraint	PK_RELATEDCONTACT_RELATIONSHIP_ID PRIMARY KEY NONCLUSTERED(RELATEDCONTACT_RELATIONSHIP_ID) ON [Primary],
		constraint	UQ_RELATEDCONTACT_RELATIONSHIP__IV_SYSID_IP_SYSID UNIQUE CLUSTERED(IV_SYSID,IP_SYSID),
		constraint	DF__RELATEDCONTACT_RELATIONSHIP__CREATED_USR_ID default SYSTEM_USER for CREATED_USR_ID,
		constraint	DF__RELATEDCONTACT_RELATIONSHIP__CREATED_TMS default GETDATE() for CREATED_TMS,	
		constraint	DF__RELATEDCONTACT_RELATIONSHIP__LST_CHG_USR_ID default SYSTEM_USER for LST_CHG_USR_ID,
		constraint	DF__RELATEDCONTACT_RELATIONSHIP__LST_CHG_TMS default GETDATE() for LST_CHG_TMS,
		constraint	FK_RELATEDCONTACT_RELATIONSHIP__RELATEDCONTACT  FOREIGN KEY (IP_SYSID) REFERENCES RELATEDCONTACT(IP_SYSID);
	
	-- Validate if the table has been created.
	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'RELATEDCONTACT_RELATIONSHIP'  
		)
		BEGIN
			PRINT 'Table dbo.RELATEDCONTACT_RELATIONSHIP has been created.'
		END
	ELSE
		BEGIN
			PRINT 'Table dbo.RELATEDCONTACT_RELATIONSHIP has not been created.'
		END

END TRY
BEGIN CATCH
	SELECT	ERROR_NUMBER()		as ErrorNumber,
			ERROR_MESSAGE()		as ErrorMEssage,
			ERROR_LINE()		as ErrorLine,
			ERROR_STATE()		as ErrorState,
			ERROR_SEVERITY()	as ErrorSeverity,
			ERROR_PROCEDURE()	as ErrorProcedure;
END CATCH;
PRINT '';
PRINT 'End of TABLE script for RELATEDCONTACT_RELATIONSHIP';
PRINT '----------------------------------------';


