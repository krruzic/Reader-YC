#!/bin/bash
TART=tart
blackberry-nativepackager -package ReaderYC-debug.bar \
    -configuration Device-Debug \
    -devMode \
    -target bar \
    -env PYTHONPATH=app/native \
    -env PYTHONDONTWRITEBYTECODE=1 \
    -arg -qml -arg app/native/assets/main.qml \
    -arg app/native/blackberry_tart.py \
    bar-descriptor.xml \
    icon.png \
    app/ \
    assets/ \
    -C $TART/entry $TART/entry/TartStart \
    -C $TART/js $TART/js/*.js \
    -C $TART/python $TART/python \
    -debugToken debugtoken.bar
