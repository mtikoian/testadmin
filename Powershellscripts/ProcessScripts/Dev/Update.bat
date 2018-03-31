@echo off
cd %~dp0

REM This file should change as little as possible so it can consistently be run.
REM Anything that could change should go into Update_Mutable.ps1.

REM Increasing the command prompt line numbers
powershell -command "&{$rawUi=$Host.ui.rawui;$bufferSizeTypeName=$rawUi.BufferSize.GetType().FullName;$rawUi.BufferSize=(New-Object $bufferSizeTypeName (160,32766))}"

echo Process Script Update: STARTING---------------------------------------
REM Using the full path here because it may not be added to the system paths yet.
"C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\TF.exe" get $/CSES/_ProcessScripts /recursive
echo Process Script Update: COMPLETE---------------------------------------
echo.

powershell -File Update_Mutable.ps1

echo.
pause