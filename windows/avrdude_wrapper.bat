:: Wrapper for avrdude performing automatic reset to bootloader
:: in arduino usb devices like leonardo and lilypad usb
::
:: Version: 1.0
:: Date: 3.9.2018
:: Author: Javanaut
::
:: Based on arduino-leonardo-uploader from p1ne found here:
:: https://github.com/p1ne/arduino-leonardo-uploader
::
:: Todo:
:: Add device identifiers of remaining usb arduinos

@echo off
setlocal

set /A paramPointer=0

for %%p in (%*) do (
  call :parseParameter "%%p"
)

if not "%programmer%"=="avr109" (
    goto :flash
)

for /L %%G in (0,1,%paramPointer%) do (
  call :appendToAdditionalParamsString %%additionalParameters[%%G]%%
)

:: add further devices here
for /f "tokens=1* delims==" %%I in ('wmic path win32_pnpentity get caption  /format:list ^| 
  findstr 
    /C:"Arduino Leonardo (" 
    /C:"Arduino LilyPad USB ("
    /C:"Arduino Yun ("
') do (

  call :resetPort "%%~J"
)

:: add further devices here
for /f "tokens=1* delims==" %%I in ('wmic path win32_pnpentity get caption  /format:list ^| 
  findstr 
    /C:"Arduino Leonardo bootloader" 
    /C:"Arduino LilyPad USB bootloader"
    /C:"Arduino Yun bootloader"
') do (

    call :setPort "%%~J"
    exit
)

echo No device found on port %port%

goto :eof

:parseParameter

  set "param=%~1"
  
  if "%param:~0,2%"=="-c" (  
    set programmer=%param:~2%
    goto :eof
  )
    
  if "%param:~0,2%"=="-P" (
    set port=%param:~2%
    goto :eof
  )
  
  set additionalParameters[%paramPointer%]=%param%
  set /A paramPointer+=1

goto :eof

:appendToAdditionalParamsString

  set "param=%~1"
  
  IF NOT  "%param%"=="" (
    set additionalParamsString=%additionalParamsString% %param%
  )
 
goto :eof

:resetPort

  setlocal
  set "identifier=%~1"
  set "id=%identifier:*(COM=%"
  set "id=%id:)=%"
  set avr_port=COM%id%

  if not "%avr_port%"=="%port%" (
    goto :eof
  )
    
  echo Setting bootloader mode in device %identifier%
  
  mode %avr_port%: BAUD=1200 parity=N data=8 stop=1 > nul
  
  :: add 2 sec pause to let bootloader come up
  ping localhost -n 2 > nul

goto :eof

:setPort

  setlocal
  set "identifier=%~1"
  set "id=%identifier:*(COM=%"
  set "id=%id:)=%"
  set port=COM%id%

:flash

  echo avrdude -c%programmer% -P%port%%additionalParamsString%

goto :eof
