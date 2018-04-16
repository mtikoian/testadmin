
***********************************************************
Project  			: <ProjectName>
Developer			: <DeveloperName>
Extension			: Xnnn
Goldcode location	:  
***********************************************************

This file contains the instructions for performing a SQL build for the above listed project.

The folder in which this text file is located is the parent folder for all install scripts needed 
to perform the build.
The folder structure should look like:
<Top Folder>
	App
	CMDScripts
	Docs
	Logs
	SQLScripts
	RollbackSQLScripts
	
If you do not see the 6 folders below the one that contains this file, stop and notify the project 
team. 	

The <Top Folder> that houses these 6 folders should be copied to your local directory - where you will 
perform the build from.

	
The CMDScripts folder is the working folder and contains several important files. 
	1. DBBuild.cmd is the command script that is executed to perform the build. 
	2. DBBuild_Config.cmd that contains the variable information that needs to be edited 
	   before the DBbuild file is run.	 
	
The Docs folder holds a set of text files that drive the build. These files contain a list of the 
SQL scripts that are executed by DBBuild.cmd. There may also be a text file that contains the fully
qualified SVN name for pulling the code from Subversion.

*******************************************************************************
*******************************************************************************

Do not edit any command files other than DBBuild.Config.cmd and DBBuild_Server_List.txt

*******************************************************************************
*******************************************************************************
	
Here is what you must do:
1. Open the DBBuild_Config.cmd in a text editor
2. Find the line that begins with set ROOTDIR=
3. Edit this line, immediately after the equal (=) sign add the name of the top level build folder.
   An example would be
   set ROOTDIR=C:\A\Workspace\ECR\Database\Test\Build\20120308   
4. Save the file   
5. Open the DBBuild_Server_List.txt file in a text editor
6. Modify the existing line(s) or add new lines for each database server/database/schema. Each name
   is separated by a single space. Make the schema dbo for each line.
7. Save the file.
8. Execute the DBBuild.CMD file. 

--- Rollback
If a rollback is required execute the Rollback_DBBuild.cmd script.
