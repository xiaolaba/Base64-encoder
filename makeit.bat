@echo off

echo complie resource
if not exist rsrc.rc goto over1
D:\masm32\bin\RC.EXE /v rsrc.rc
D:\masm32\bin\CVTRES.EXE /machine:ix86 rsrc.res
:over1

if exist %1.obj del Base64en.obj
if exist %1.exe del Base64en.exe

echo complie ASM
D:\masm32\bin\ML.EXE /c /coff Base64en.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

echo LINK
D:\masm32\bin\LINK.EXE /SUBSYSTEM:WINDOWS Base64en.obj rsrc.obj
if errorlevel 1 goto errlink

dir Base64en.*
goto TheEnd

:nores
D:\masm32\bin\LINK.EXE /SUBSYSTEM:WINDOWS Base64en.obj
if errorlevel 1 goto errlink
dir %1
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd

del Base64en.obj
rem del *.res

base64en.exe
pause

