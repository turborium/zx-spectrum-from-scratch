@echo off

rem Params
set name=attr_sin

echo ---------           Compile           ---------
rem Compile main file
..\..\sjasm\sjasmplus %name%.asm --syntax=F

echo ---------           Running           ---------
rem Copy labels to emulator
copy "user.l" "..\..\us\"
del user.l

rem Run emulator
..\..\us\unreal %name%.sna