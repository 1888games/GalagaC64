@echo off
rem builds the release: releases\galaga.prg, galaga.d64 and galaga.tap, beside Scripts
rem
rem   make          build them all and copy them to releases
rem   make prg      ... then autostart the crunched prg in VICE
rem   make disk     ... then autostart the disk
rem   make tape     ... then autostart the tape
rem
rem The game is crunched first (bin\galaga.prg): the unpacked bin\main.prg runs from $0801
rem to $FEFF, over the i/o at $D000, so only the crunched one can be LOADed.
rem
rem   PRG   bin\galaga.prg, the exomized game on its own
rem   DISK  bin\galaga.d64 with the crunched game on it as GALAGA. The high scores are
rem         saved beside it as GALSCORES
rem   TAPE  bin\galaga.tap and .wav: a KERNAL file carrying a turbo loader, then the loading
rem         picture (..\Assets\loader.kla, a Koala file: left out if there's none) and the
rem         game about 6 times faster (tape\turbo_loader.asm and tape\maketap.js, as in
rem         Robotron 2064 - needs node). Loaded from tape the high scores stay in memory

set dir=%~dp0
set kickass=C:\C64\Tools\KickAssembler\KickAss.jar
set vice=C:\C64\Tools\Vice
set name=galaga
set releases=%dir%..\releases

cd /d "%dir%"

java -jar "%kickass%" main.asm -odir bin -vicesymbols
if errorlevel 1 goto failed

rem the decruncher's exit puts the screen on (-f): the tape's loader leaves it off while the
rem game unpacks over the loading picture, and the game doesn't turn it on itself
"%dir%exomizer.exe" sfx sys -t 64 -x1 -f"lda #$1b sta $d011" -o bin\%name%.prg bin\main.prg
if errorlevel 1 goto failed

if exist bin\%name%.d64 del bin\%name%.d64
"%vice%\c1541.exe" -format "galaga,ga" d64 bin\%name%.d64 -write bin\%name%.prg "galaga"
if errorlevel 1 goto failed

java -jar "%kickass%" tape\turbo_loader.asm -odir ..\bin\tape
if errorlevel 1 goto failed

set picture=
if exist ..\Assets\loader.kla set picture=..\Assets\loader.kla
if "%picture%"=="" echo No ..\Assets\loader.kla, so the tape has no loading picture

node tape\maketap.js bin\tape bin\%name%.prg bin\%name%.tap bin\%name%.wav %picture%
if errorlevel 1 goto failed

rem Sublime empties bin before every build
if not exist "%releases%" mkdir "%releases%"
copy /y bin\%name%.prg "%releases%" >nul
if errorlevel 1 goto failed
copy /y bin\%name%.d64 "%releases%" >nul
if errorlevel 1 goto failed
copy /y bin\%name%.tap "%releases%" >nul
if errorlevel 1 goto failed

echo Built %name%.prg, %name%.d64 and %name%.tap and copied them to releases

set image=
if /i "%1"=="prg" set image=bin\%name%.prg
if /i "%1"=="disk" set image=bin\%name%.d64
if /i "%1"=="tape" set image=bin\%name%.tap
if "%image%"=="" goto :eof

taskkill /im "x64sc.exe" >nul 2>&1
start "" "%vice%\x64sc.exe" -autostart %image%
goto :eof

:failed
echo The release build failed
exit /b 1
