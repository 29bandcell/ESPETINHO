@echo off
setlocal

set "URL=https://espetinho-do-gordinho.netlify.app/empresa.html"
set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
set "CHROME_X86=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
set "PROFILE=%LOCALAPPDATA%\EspetinhoGordinhoChrome"

if exist "%CHROME%" (
  start "" "%CHROME%" --kiosk-printing --user-data-dir="%PROFILE%" "%URL%"
  exit /b
)

if exist "%CHROME_X86%" (
  start "" "%CHROME_X86%" --kiosk-printing --user-data-dir="%PROFILE%" "%URL%"
  exit /b
)

start "" "%URL%"
echo Google Chrome nao encontrado. Instale o Chrome para usar impressao automatica sem assistente.
pause
