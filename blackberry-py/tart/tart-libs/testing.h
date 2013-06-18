// Support for PC-based automated tests
//
#ifndef TESTING_H
#define TESTING_H

// functions that we want exported in the test DLL should be labelled DLL_EXPORT
// so that ctypes can find them
#if defined(WIN32) || defined(__TINYC__)
#   include "windows.h"
#   define DLL_EXPORT __declspec(dllexport)
#   define TEST_SUPPORT 1

#else
#   define DLL_EXPORT
#   undef TEST_SUPPORT
#endif


#endif
// EOF
