@echo off
setlocal
title Espetinho do Gordinho - Impressao automatica

set "URL=https://espetinho-do-gordinho.netlify.app/empresa.html"
set "PROFILE=%LOCALAPPDATA%\EspetinhoGordinhoChrome"
set "CHROME_PATH="

echo.
echo Espetinho do Gordinho
echo Abrindo area da empresa com impressao automatica...
echo.
echo IMPORTANTE:
echo 1. Feche todas as janelas do Chrome antes de usar este arquivo.
echo 2. Deixe a EPSON T20X como impressora padrao do Windows.
echo.

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
  set "CHROME_PATH=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
)

if not defined CHROME_PATH if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
  set "CHROME_PATH=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
)

if not defined CHROME_PATH (
  for /f "delims=" %%C in ('where chrome 2^>nul') do (
    if not defined CHROME_PATH set "CHROME_PATH=%%C"
  )
)

if not defined CHROME_PATH (
  echo Google Chrome nao foi encontrado.
  echo Instale o Google Chrome para usar impressao automatica sem assistente.
  echo.
  pause
  exit /b 1
)

echo Chrome encontrado:
echo %CHROME_PATH%
echo.

start "" "%CHROME_PATH%" --kiosk-printing --new-window --user-data-dir="%PROFILE%" "%URL%"

echo Se a pagina da empresa abriu, pode deixar esta janela fechar.
echo Se a impressao ainda abrir assistente, feche TODAS as janelas do Chrome e rode este arquivo de novo.
timeout /t 8 /nobreak >nul
