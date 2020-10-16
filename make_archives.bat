@echo off
call globals.bat

set Line=--------------------------------------------------------------------------------

copy %AppExe32Compiled% %AppExe%

echo %AppFullName%  (%AppDate%) > %README%
echo %Line%>> %README%
echo LICENSE >> %README%
echo( >> %README%
%AppExe% --license >> %README%
echo %Line% >> %README%
::%AppExe% --help >> %README%

if exist %PortableFileZip32% del %PortableFileZip32%
%CreatePortableZip32%



copy %AppExe64Compiled% %AppExe%

echo %AppFullName%  (%AppDate%) > %README%
echo %Line%>> %README%
echo LICENSE >> %README%
echo( >> %README%
%AppExe% --license >> %README%
echo %Line% >> %README%
::%AppExe% --help >> %README%

if exist %PortableFileZip64% del %PortableFileZip64%
%CreatePortableZip64%



copy %AppExe32Compiled% %AppExe%

