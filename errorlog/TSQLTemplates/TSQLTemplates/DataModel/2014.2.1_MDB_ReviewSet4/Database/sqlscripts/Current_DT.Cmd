@echo off
rem ------------------------------------------------------------------------------
rem Current_DT.Cmd
rem
rem Construct the environment variable CURRENT_DT in the format of CCYYMMDD_HHMMSS
rem where the time is in 24hr format
rem ------------------------------------------------------------------------------

rem This sets the Current_Dt variable 
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
for /f "tokens=1-3 delims=/:." %%a in ("%TIME%") do (set mytime=%%a%%b%%c)

rem if the time < 10:00:00, prepend a 0 and strip out the space 
set mytime=0%mytime: =%
set mytime=%mytime:~-6%
set CURRENT_DT=%mydate%_%mytime%



