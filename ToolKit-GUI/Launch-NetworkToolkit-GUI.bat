@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
cscript.exe //nologo "%SCRIPT_DIR%Launch-NetworkToolkit-GUI.vbs"
endlocal
