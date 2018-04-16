USE NetikIP
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***
================================================================================
 Name        : [fn_ntk_SQLSanitizer] 
 Author      : Prasanth [PPremkumar] - 02/23/2012
 Description : User Defined Function used for Checking SQL Injection
===============================================================================
 Parameters   :
 Name                      |I/O|  Description
 @filter					I     Filter statement from the Application
--------------------------------------------------------------------------------
 Returns      :
 Name                      Type (length)     Description
 @FLAG						Bit				 Checks the Item present in
											 SEI_NTK_SQL_SANITIZER_CHAR table
--------------------------------------------------------------------------------
Checks the Item present in SEI_NTK_SQL_SANITIZER_CHAR Table
If record set is returned give brief description of the fields being returned
 Return Value:  @FLAG
     Success :  True
	 Failure :  False
 Revisions    :
--------------------------------------------------------------------------------
 Ini	|   Date		|	 Description
 PJ			04/03/2012		 Initial Version
--------------------------------------------------------------------------------
================================================================================
***/

CREATE FUNCTION dbo.fn_ntk_SQLSanitizer
     (@filter      varchar(8000) = NULL)  
   RETURNS bit AS   

BEGIN  
	DECLARE @FLAG BIT
	IF LEN(ISNULL(RTRIM(@filter),''))=0 
		SET @FLAG = 'FALSE'

	IF EXISTS( SELECT TOP 1 * FROM SEI_NTK_SQL_SANITIZER_CHAR WHERE CHARINDEX(RTRIM(INJCHAR) + ' ',@filter) > 0)
		  SET @FLAG = 'TRUE'
	ELSE
		  SET @FLAG =  'FALSE'
  
RETURN @FLAG
END  


GO


