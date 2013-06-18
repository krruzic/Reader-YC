#!/bin/bash
TART=../../tart
blackberry-nativepackager -package HelloWorld.bar \
    -configuration Device-Debug \
    -devMode \
    -target bar \
    -env PYTHONPATH=shared/misc/tart/python:shared/misc/HelloWorld\
    -env PYTHONDONTWRITEBYTECODE=1 \
    -arg -qml -arg shared/misc/HelloWorld/assets/main.qml \
    -arg shared/misc/tart/python/blackberry_tart.py \
    bar-descriptor.xml \
    icon.png \
    -C $TART/entry $TART/entry/TartStart \
    -debugToken ../../debugtoken.bar
