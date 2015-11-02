@ECHO OFF

SET SCRIPTNAME=%~d0%~p0%~n0.ps1
PowerShell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Unrestricted -Command "& { $ErrorActionPreference = 'Stop'; & '%SCRIPTNAME%' @args; EXIT $LASTEXITCODE }"

SET RESULT=%ERRORLEVEL% 
ECHO ERRORLEVEL=%RESULT%
EXIT /B %RESULT%