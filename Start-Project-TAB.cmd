@echo off
setlocal
title Project TAB - Test a Breach

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-Project-TAB.ps1" %*
set "TAB_EXIT_CODE=%ERRORLEVEL%"

if not "%TAB_EXIT_CODE%"=="0" (
  echo.
  echo Project TAB stopped with an error. Review the message above.
  pause
)

exit /b %TAB_EXIT_CODE%
