@echo off
drafticon -i icon.png
setlocal
set TART=../../tart
call blackberry-nativepackager -package HelloWorld.bar ^
    -configuration Device-Debug ^
    -devMode ^
    -target bar ^
    -env PYTHONDONTWRITEBYTECODE=1 ^
    -env PYTHONPATH=shared/misc/tart/python:shared/misc/HelloWorld ^
    -arg -qml -arg shared/misc/HelloWorld/assets/main.qml ^
    -arg shared/misc/tart/python/blackberry_tart.py ^
    bar-descriptor.xml ^
    -e draft_icon.png icon.png ^
    -C %TART%/entry %TART%/entry/TartStart ^
    -debugToken ../../debugtoken.bar
endlocal
