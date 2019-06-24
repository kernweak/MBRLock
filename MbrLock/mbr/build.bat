set path=%PATH%;L:\Workcode\SysCode\trunk\bootkit_src\MbrLock\mbr
pushd l:
cd L:\Workcode\SysCode\trunk\bootkit_src\MbrLock\mbr
del mbrlock.bin
jwasm.exe mbrlock.asm
doslnk mbrlock.obj /tiny
ren mbrlock.com mbrlock.bin
popd
