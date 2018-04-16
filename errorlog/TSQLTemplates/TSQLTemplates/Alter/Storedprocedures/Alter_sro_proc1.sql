USE NetikDP
GO


-- Drop stored procedure if it already exists
IF EXISTS (	SELECT 1 
		    FROM 
				INFORMATION_SCHEMA.ROUTINES 
			WHERE 
				SPECIFIC_SCHEMA = N'dbo'
		    AND 
				SPECIFIC_NAME = N'p_netik_ssrs_DriftAllPF' 
)
BEGIN
     DROP PROCEDURE dbo.p_netik_ssrs_DriftAllPF;
     PRINT 'PROCEDURE dbo.p_netik_ssrs_DriftAllPF has been dropped.';
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*                
==================================================================================================                
Name  : [p_netik_ssrs_DriftAllPF]                
Author  : Sumit Mehrotra   -  07/08/2013               
Description : Process fetches the account details based on the client access;     
     This procedure to populate dropdrown in the application    
                   
                       
===================================================================================================                
Parameters :                 
 Name                 |I/O|      Description    
 @pi_UserId				I			User Id              
 @pi_Date				I			As of date    
 @pi_Status				I			Status              
----------------------------------------------------------------                
Returns  : Return multiple tables/result sets;         
    
Result set1:    
Name                        Type (length)			Description    
ACCT_ID						varchar(50)				account id    
ACCT_NME					varchar(500)			account name    
ipcInvestmentStrategy		varchar(500)      Investment Strategy name    
          
Result set2:    
Name                        Type (length)           Description    
ipcInvestmentStrategy		varchar(500)      Investment Strategy name    
    
Return Value: @@ErrorNumber    
Success : 0    
Failure : @ErrorNumber    
          Error numeric and Description    
                      
------------------------------------------------------------------------------------    
TEST SCRIPT:      
 EXEC [p_netik_ssrs_DriftAllPF] 'ndev01','2012-10-09 00:00:00.000','1'    
----------------------------------------------------------------------------------    
    
Revisions    :    
--------------------------------------------------------------------------------    
Ini    |   Date  | Description    
--------------------------------------------------------------------------------    
Sumit M   | 07/08/2013 | Initial            
venu Perala     | 07/08/2013 | Modified as per coding standards    
Sumit M   | 07/15/2013 | Modified logic   Mark with -SM07152013      
Sumit M   | 07/19/2013 | Modified logic   Mark with -SM07192013  
========================================================================================================                
*/             
CREATE PROCEDURE dbo.p_netik_ssrs_DriftAllPF                                              
(                                              
 @pi_UserId  VARCHAR(8),                          
 @pi_Date    DATETIME,                
 @pi_Status  INT                
                     
)                                 
AS         
        
SET NOCOUNT ON        
SET FMTONLY OFF         
                                                       
BEGIN /*----Procedure Begin*/              
        
 DECLARE @error_number INT        
 DECLARE @error_message VARCHAR(400);        
 DECLARE @error_severity INT;        
        
           
 SET @error_number = 0                 
         
 BEGIN TRY/* Try Start*/                                                
                       
  IF @pi_Status=0                
  BEGIN              
             
   SELECT         
    DISTINCT          
    RTRIM(LTRIM(A.ACCT_ID)) AS ACCT_ID,      
    RTRIM(LTRIM(A.ACCT_ID)) + ' '+ RTRIM(LTRIM(A.ACCT_NME)) AS 'ACCT_NME',        
    C.ipcInvestmentStrategy                           
   FROM dbo.DW_IVW_ACCT A                
   INNER JOIN dbo.DW_PERMISSION P        
    ON         
     P.ACCT_ID = A.ACCT_ID        
    INNER JOIN   dbo.DW_IVW_USER U            
    ON        
     P.USER_CLS_ID = U.USER_CLS_ID                           
   INNER JOIN NETIKIP.dbo.IPCClientAccountSleeve C                            
    ON C.IPCSleeveSEIAccountNo=A.ACCT_ID          
   WHERE         
    (C.IPCTerminationDate <=@pi_Date OR A.acct_cls_dte <=@pi_Date) AND --SM07152013      
    A.ACCT_GRP_TYP<>'G'    AND        
    U.USER_ID = @pi_UserId           
             
               
  END         
  ELSE IF @pi_Status=1                
  BEGIN                          
   SELECT DISTINCT          
    RTRIM(LTRIM(A.ACCT_ID)) AS ACCT_ID,      
    RTRIM(LTRIM(A.ACCT_ID)) +' '+ RTRIM(LTRIM(A.ACCT_NME)) AS 'ACCT_NME',        
    C.ipcInvestmentStrategy                            
   FROM dbo.DW_IVW_ACCT A                             
   INNER JOIN dbo.DW_PERMISSION P        
    ON         
     P.ACCT_ID = A.ACCT_ID      
    INNER JOIN   dbo.DW_IVW_USER U            
    ON        
     P.USER_CLS_ID = U.USER_CLS_ID                
   INNER JOIN NETIKIP.dbo.IPCClientAccountSleeve C                            
    ON C.IPCSleeveSEIAccountNo=A.ACCT_ID AND         
     ( (A.acct_cls_dte > @pi_Date OR A.acct_cls_dte IS NULL)   --SM07152013      
      AND (C.IPCTerminationDate IS NULL OR C.IPCTerminationDate > @pi_Date) ---SM07192013     
         
     )                    
   WHERE  A.ACCT_GRP_TYP<>'G'         
    AND        
     U.USER_ID = @pi_UserId             
  END                
              
                 
  SELECT DISTINCT         
   ipcInvestmentStrategy         
  FROM NETIKIP.dbo.IPCClientAccountSleeve   --SM07152013               
                
                                                 
 END TRY /* Try End*/     
 BEGIN CATCH /* Catch Start*/    
     
    SET @error_number = ERROR_NUMBER();     SET @error_message = ERROR_MESSAGE();     SET @error_severity = ERROR_SEVERITY();    
    
  RAISERROR(@error_message,@error_severity,1);    
      
 END CATCH /* Catch End*/    
     
     
 RETURN @error_number     
END;/*----Procedure End*/ 

GO

-- Validate if procedure has been created.
IF EXISTS (	SELECT 1 
		    FROM 
				INFORMATION_SCHEMA.ROUTINES 
			WHERE 
				SPECIFIC_SCHEMA = N'dbo'
		    AND 
				SPECIFIC_NAME = N'p_netik_ssrs_DriftAllPF' 
)
BEGIN
     PRINT 'PROCEDURE dbo.p_netik_ssrs_DriftAllPF has been created.'
END
ELSE
BEGIN
    PRINT 'PROCEDURE dbo.p_netik_ssrs_DriftAllPF has NOT been created.'
END
GO

GRANT EXECUTE ON dbo.p_netik_ssrs_DriftAllPF TO netikapp_user
GO          

  