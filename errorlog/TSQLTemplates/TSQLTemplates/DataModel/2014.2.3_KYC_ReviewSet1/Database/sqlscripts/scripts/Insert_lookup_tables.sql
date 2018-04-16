USE NetikIP
GO

/***
================================================================================
 Name        : Insert_lookup_tables.sql 
 Author      : VBANDI - 02/24/2014
 Description : Insert Onbase lookup tables
===============================================================================
 Revisions    :
--------------------------------------------------------------------------------
 Ini			|   Date		|	 Description
 VBANDI			  02/24/2014		 Initial Version
--------------------------------------------------------------------------------
================================================================================
***/

DECLARE @Error INTEGER;

BEGIN TRY


	BEGIN TRANSACTION


INSERT [dbo].[Transaction_Status] ([Transaction_Status_Cd], [Transaction_Status_Name]) VALUES (4, N'AML/Enhance Review Complete - Pending SEI Peer Review')

INSERT [dbo].[Transaction_Status] ([Transaction_Status_Cd], [Transaction_Status_Name]) VALUES (5, N'Client Action Required')

INSERT [dbo].[Transaction_Status] ([Transaction_Status_Cd], [Transaction_Status_Name]) VALUES (7, N'Complete')

INSERT [dbo].[Transaction_Status] ([Transaction_Status_Cd], [Transaction_Status_Name]) VALUES (2, N'Initial Review Complete')

INSERT [dbo].[Transaction_Status] ([Transaction_Status_Cd], [Transaction_Status_Name]) VALUES (1, N'Pending SEI Review')

INSERT [dbo].[Transaction_Status] ([Transaction_Status_Cd], [Transaction_Status_Name]) VALUES (3, N'Ready for Money Movement')




INSERT INTO dbo.Corporation_Type(Corporation_Type_ID,Corporation_Type_Name) VALUES (1, 'Partnership/Membership Agreement (US/NonUS)')
INSERT INTO dbo.Corporation_Type(Corporation_Type_ID,Corporation_Type_Name) VALUES (2, 'Non-documentary (US)')
INSERT INTO dbo.Corporation_Type(Corporation_Type_ID,Corporation_Type_Name) VALUES (3, 'Three Years of Financial Statements (NonUS)')
INSERT INTO dbo.Corporation_Type(Corporation_Type_ID,Corporation_Type_Name) VALUES (4, 'Certificate of Good Standing (NonUS)')
INSERT INTO dbo.Corporation_Type(Corporation_Type_ID,Corporation_Type_Name) VALUES (5, 'Banking Reference (NonUS)')

INSERT INTO dbo.Verification_Type(Verification_Type_ID,Verification_Type_Name) VALUES (1, 'Driver''s License')
INSERT INTO dbo.Verification_Type(Verification_Type_ID,Verification_Type_Name) VALUES (2, 'Passport')
INSERT INTO dbo.Verification_Type(Verification_Type_ID,Verification_Type_Name) VALUES (3, 'Government ID')
INSERT INTO dbo.Verification_Type(Verification_Type_ID,Verification_Type_Name) VALUES (4, 'Birth Certificate')
INSERT INTO dbo.Verification_Type(Verification_Type_ID,Verification_Type_Name) VALUES (5, 'Verified PA Compliance')
INSERT INTO dbo.Verification_Type(Verification_Type_ID,Verification_Type_Name) VALUES (6, 'Other')

IF @@trancount > 0
BEGIN
	COMMIT TRANSACTION;

	PRINT 'Insert Completed';
END
	END TRY

BEGIN CATCH
	SET @Error = error_number();

	IF @@trancount <> 0
		ROLLBACK TRANSACTION;

	RAISERROR (
			'Error during Insertion'
			,16
			,1
			);

	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage;
END CATCH
GO

