REM User Configuration
REM ==================
@echo off
set HereDir=%~d0%~p0.
if not defined OutputDir set OutputDir=%HereDir%\output
if not defined ObjDir set ObjDir=%OutputDir%\obj
if not defined CLExe set CLExe=cl.exe
if not defined LinkExe set LinkExe=link.exe
if not defined IonExe set IonExe="%OutputDir%\ion.exe"
setlocal

if not exist "%OutputDir%" mkdir "%OutputDir%"
if not exist "%ObjDir%" mkdir "%ObjDir%"
if %errorlevel% neq 0 exit /b 1

set CLCommonFlags="-I%HereDir%" -nologo -Z7 -W3 -wd4244 -wd4267 -wd4204 -wd4201 -D_CRT_SECURE_NO_WARNINGS -Fo:"%ObjDir%"\

set IonCommonFlags=
set IONHOME=%HereDir%\deps\bitwise\ion\

REM work in progress
"%IonExe%" -check ddcg_program

call :build_program_module docking_demo_program
if %errorlevel% neq 0 exit /b 1

xcopy /y /s "%HereDir%\assets" "%OutputDir%"\assets\
xcopy /y /s "%HereDir%\deps\SDL2_win32\lib\x64\SDL2.dll" "%OutputDir%"
exit /b 0

:build_program_module
set Os=win32
set Arch=x64
set ProgramModuleName=%1
set ProgramModuleCFile="%ObjDir%\out_%ProgramModuleName%.c"
pushd %HereDir%
"%IonExe%" %IonCommonFlags% -os %Os% -arch %Arch% -o "%ProgramModuleCFile%" %ProgramModuleName%
if %errorlevel% neq 0 exit /b 1
popd

set O=%OutputDir%\%ProgramModuleName%.exe
"%CLExe%" -Fe:"%O%" -Fo:"%ObjDir%\\" -I"%ObjDir%" "%ProgramModuleCFile%" ^
  -I"%HereDir%"\deps\SDL2_%Os%\include\ ^
  %CLCommonFlags% ^
  -link -SUBSYSTEM:CONSOLE
if %errorlevel% neq 0 exit /b 1
echo PROGRAM    %O%
exit /b 0



