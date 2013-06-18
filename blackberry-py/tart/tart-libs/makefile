#############################################################################
# Makefile for building: _font.so
#

PYLIBS		= ../../libs/arm
PYINC		= ../../Python-3.2.2/Include
CC      	= qcc -Vgcc_ntoarmv7le
LINK    	= qcc -Vgcc_ntoarmv7le
DEFINES 	= -DUSING_GL20
CFLAGS  	= -fPIC -fstack-protector-strong -Wno-psabi -O2 -Wno-psabi \
	-Wall -W -D_REENTRANT $(DEFINES)
INCPATH 	= -I$(PYINC) -I$(QNX_TARGET)/usr/include \
	-I$(QNX_TARGET)/usr/include/freetype2 \
	-I.
LFLAGS  	= -shared -lang-c \
	-Wl,-rpath-link,$(QNX_TARGET)/armle-v7/lib \
	-Wl,-rpath-link,$(QNX_TARGET)/armle-v7/usr/lib \
	-Wl,-O1

SUBLIBS		  = -L$(PYLIBS) -lpython3.2m
LIBS          = $(SUBLIBS) \
	-L$(QNX_TARGET)/armle-v7/lib \
	-L$(QNX_TARGET)/armle-v7/usr/lib -lm \
	-lbps -lscreen -lEGL -lGLESv2 -lfreetype # -lpng

TAR           = tar -cf
COMPRESS      = gzip -9f
COPY          = cp -f
SED           = sed
COPY_FILE     = $(COPY)
COPY_DIR      = $(COPY) -r
STRIP         = ntoarmv7-strip
INSTALL_FILE  = $(COPY_FILE)
INSTALL_DIR   = $(COPY_DIR)
INSTALL_PROGRAM = $(COPY_FILE)
DEL_FILE      = rm -f
SYMLINK       = ln -f -s
DEL_DIR       = rmdir
MOVE          = mv -f
CHK_DIR_EXISTS= test -d
MKDIR         = mkdir -p

SOURCES       = fonts.c logging.c
OBJECTS       = fonts.o logging.o

TARGET = _opengl.so

all: makefile $(TARGET)

####### Implicit rules

.SUFFIXES: .o .c .cpp .cc .cxx

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o "$@" "$<"

.cc.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o "$@" "$<"

.cxx.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o "$@" "$<"

.c.o:
	$(CC) -c $(CFLAGS) $(INCPATH) -o "$@" "$<"

clean:
	-$(DEL_FILE) $(TARGET)
	-$(DEL_FILE) $(OBJECTS)
	-$(DEL_FILE) *~ core *.core

$(TARGET): $(OBJECTS)
	$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(LIBS)
	$(STRIP) $(TARGET)
	$(COPY_FILE) $(TARGET) ../python/lib-dynload/_opengl-arm.so

$(OBJECTS): $(SOURCES) fonts.h debug.h

