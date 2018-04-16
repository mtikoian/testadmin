USE NetikDP;
GO

/***
================================================================================
 Name	   : Create_Synonym_xn_sequence.sql
 Author      : SMehrotra
 Description : Creates Synonym for xn_sequence in NETIKIC database

===============================================================================

Revisions    :
--------------------------------------------------------------------------------
 Initial	|   Date	| Description
--------------------------------------------------------------------------------
Mehrotra		06052014	Initial Version	
================================================================================
***/
-- Synonym creation
IF NOT EXISTS (
		SELECT 1
		FROM sys.synonyms ss
		JOIN sys.schemas sch ON ss.schema_id = sch.schema_id
		WHERE ss.NAME = 'xn_sequence'
			AND sch.NAME = 'dbo'
		)
BEGIN
	CREATE SYNONYM dbo.xn_sequence
	FOR netikic.dbo.xn_sequence;

	PRINT 'Synonym for dbo.xn_sequence created.';
END;
ELSE
	PRINT 'Synonym for dbo.xn_sequence already exists.';
	