In order to set up the demos, you'll need to create the following folder structure: 

C:\DBA911
C:\DBA911\Backups
C:\DBA911\Data
C:\DBA911\Logs

Then you'll need to get the demo databases from Paul Randal's site:

http://www.sqlskills.com/blogs/paul/corruption-demo-databases-and-scripts/

Specifically, you're looking for the DemoDataPurity, DemoNCIndex databases, and the 
script that creates the DemoRestoreOrRepair database. Copy the backups to the Backups folder. 

You will also need a way to do some damage to the DemoRestoreOrRepair database.  
I suggest either a hex ecditor like frhed (http://frhed.sourceforge.net/en/), or starting here: 

http://www.sqlskills.com/blogs/paul/dbcc-writepage/

Have fun!
-David.

dmmaxwell@gmail.com