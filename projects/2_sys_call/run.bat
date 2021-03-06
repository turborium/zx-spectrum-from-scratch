@echo off

rem Params
set name=syscall

echo ---------           Compile           ---------
rem Compile main file
..\..\sjasm\sjasmplus %name%.asm --syntax=F

echo ---------     Make basic loader       ---------
rem Make basic loader from loader_tap.bas as name %name%.tap
..\..\utils\bas2tap -s%name% -a%start_line% -c loader_tap.bas %name%.tap
rem Copy bin to %name%.tap
..\..\utils\taptool +$ %name%.tap %name%.$C

echo ---------           Running           ---------
rem Copy labels to emulator
copy "user.l" "..\..\us\"
del user.l

rem Run emulator
..\..\us\unreal %name%.tap