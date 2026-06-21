@echo off
setlocal

set "TOOLKIT_ROOT=%~dp0"
set "TOOLKIT_APP_ROOT=%TOOLKIT_ROOT%App"
set "TOOLKIT_SCRIPT=%TOOLKIT_APP_ROOT%\NetworkToolkit.ps1"

if not exist "%TOOLKIT_SCRIPT%" (
    echo NetworkToolkit.ps1 was not found.
    echo Expected: "%TOOLKIT_SCRIPT%"
    pause
    exit /b 1
)

set "NT_WINDOW_ARG=-WindowStyle Hidden"

for %%A in (%*) do (
    if /I "%%~A"=="-CLI" set "NT_WINDOW_ARG="
)

set "NT_LAUNCH_ARGS=-NoProfile %NT_WINDOW_ARG% -ExecutionPolicy Bypass -STA -File ""%TOOLKIT_SCRIPT%"" %*"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $env:NT_LAUNCH_ARGS"

endlocal
exit /b 0
