@echo off
setlocal
set TART=../../tart
call blackberry-nativepackager -package HelloWorld.bar ^
    -configuration Device-Release ^
    -target bar ^
    -env PYTHONPATH=app/native ^
    -env PYTHONDONTWRITEBYTECODE=1 ^
    -arg -qml -arg app/native/assets/main.qml ^
    -arg app/native/blackberry_tart.py ^
    bar-descriptor.xml ^
    icon.png ^
    app/ ^
    assets/ ^
    -C %TART%/entry %TART%/entry/TartStart.so ^
    -C %TART%/js %TART%/js/*.js ^
    -C %TART%/python %TART%/python ^
    -debugToken ../../debugtoken.bar
endlocal
