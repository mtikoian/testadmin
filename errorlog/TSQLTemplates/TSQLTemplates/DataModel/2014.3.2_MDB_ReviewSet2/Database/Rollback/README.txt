**************************************************************************************************************************************************
Author Name	: Venu Perala

Contact Person	: Venu Perala, vperala@seic.com(610-676-2312)

	  


Deployment Instructions :

1. DBBuild_Config_SpecifyRoot.cmd file would need to be open and variable values should be set according to PROD server values.

2. Set the DBServer variable to the PROD database server name. This script assumes that windows authentication will be used as per DBA recommondation.

3. Execute RollbackScripts.cmd to deploy new script once appropriate parameters are set.

4. The log file outputs to a "logs" folder with timestamp (which can be checked for any errors)

5. In case of any issue please refer README.TXT from "Rollback" folder to rollback the script.



**************************************************************************************************************************************************
