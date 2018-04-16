USE NetikIP
GO



/*                 
==================================================================================================                 
Name        : cds.v_WireAudit                   
File Name   : cds.v_WireAudit.View.sql                                                               
Author      : Sam Page (fpageiv.com)                              
Description : Know Your Client Data Services (cds) Create View Script 
              This view supports a special Wire auditing report to include
              the current Approved record version along with the latest
              pending record changes.
                     
===================================================================================================                 
----------------------------------------------------------------                 
Returns  :  Recordset                 
                 
History:                
Name             Date          Description                 
--------------  ----------     --------------------------------------------------------                 
Sam Page         20131212      Initial Version
VBANDI			 20131227      Added columns for wire audit report
========================================================================================================                 
*/

ALTER VIEW cds.v_WireAudit
AS 
	SELECT
	/* Start VBANDI 20131227 */
	FINV.FundId AS FundId
	,I.InvestorId AS InvestorId
	,I.ThirdPartyId
	,I.ReferenceKey
	,FINV.ExternalClassSeriesId
	,pending.NEW_WireId AS WireId
	/* Start VBANDI 20131227 */
	,pending.OLD_ReceivingBankId
	,pending.NEW_ReceivingBankId
	,approved.ReceivingBankId
	,pending.OLD_BeneficiaryAccountNumber
	,pending.NEW_BeneficiaryAccountNumber
	,approved.BeneficiaryAccountNumber
	,pending.OLD_BeneficiaryIBAN
	,pending.NEW_BeneficiaryIBAN
	,approved.BeneficiaryIBAN
	,pending.OLD_UltimateBeneficiaryAccountNumber
	,pending.NEW_UltimateBeneficiaryAccountNumber
	,approved.UltimateBeneficiaryAccountNumber
	,pending.OLD_UltimateBeneficiaryIBAN
	,pending.NEW_UltimateBeneficiaryIBAN
	,approved.UltimateBeneficiaryIBAN
	,pending.OLD_TemplateId
	,pending.NEW_TemplateId
	,approved.TemplateId
	,pending.OLD_BeneficiaryAccountName
	,pending.NEW_BeneficiaryAccountName
	,approved.BeneficiaryAccountName
	,pending.OLD_BeneficiarySWIFTBIC
	,pending.NEW_BeneficiarySWIFTBIC
	,approved.BeneficiarySWIFTBIC
	,pending.OLD_BeneficiarySortCode
	,pending.NEW_BeneficiarySortCode
	,approved.BeneficiarySortCode
	,pending.OLD_BeneficiaryABARoutingNumber
	,pending.NEW_BeneficiaryABARoutingNumber
	,approved.BeneficiaryABARoutingNumber
	,pending.OLD_UltimateBeneficiaryAccountName
	,pending.NEW_UltimateBeneficiaryAccountName
	,approved.UltimateBeneficiaryAccountName
	,pending.OLD_UltimateBeneficiarySWIFTBIC
	,pending.NEW_UltimateBeneficiarySWIFTBIC
	,approved.UltimateBeneficiarySWIFTBIC
	,pending.OLD_ExternalWireId
	,pending.NEW_ExternalWireId
	,approved.ExternalWireId
	,bank.ABARoutingNumber
	,bank.BankName
	,bank.SWIFTBIC
	,bank.CHIPSParticipantNumber
	,bank.SortCode
	,bank.City
	,bank.STATE
	,bank.CountryCode
	,pending.USER_ID
	,pending.AUDIT_TIMESTAMP
	,approved.LastUpdate
	,approved.UpdateUser
FROM cds.vw_WIRE_PENDING_AUDIT pending
LEFT JOIN cds.Wire approved ON pending.NEW_WireId = approved.WireId
JOIN cds.Bank bank ON approved.ReceivingBankId = bank.BankId
JOIN cds.FundInvestor FINV ON approved.WireId = FINV.WireId --VBANDI 20131227
INNER JOIN cds.Investor I ON I.Investorid = FINV.Investorid --VBANDI 20131227
GO

IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'cds.v_WireAudit'))
BEGIN
	PRINT 'Failed to create cds.v_WireAudit '
END
ELSE
BEGIN
	PRINT 'VIEW cds.v_WireAudit Altered successfully '
END
GO
