@echo off

rem =======================================================
rem     This script takes the parameter passed as the root node
rem     and builds the fully qualified path to that node.
rem =======================================================
    

    set findstr=%1

    for /f "tokens=* delims=\" %%a in ('cd') do (
        set parse=%%a
        set new=!parse:\= !
    )
    
    for %%g in (%new%) do (
        if .%%g==. goto done
        call set p=%%p%%\%%g
        if %%g==!findstr! goto done     
    )
:done
    set RootDir=%p:~1%
    rem echo Root is %RootDir%
        