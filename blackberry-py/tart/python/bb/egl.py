import ctypes
from ctypes import (c_bool, c_float, c_double, c_int, c_char_p, c_void_p,
    c_int8, c_int32, c_uint32,
    c_uint, POINTER, Structure, CFUNCTYPE)

from ._wrap import _func, _register_funcs


# /* EGL Types */
KHRONOS_FALSE = 0
KHRONOS_TRUE  = 1
khronos_int32_t = c_int32
khronos_uint32_t = c_uint32

EGLNativeDisplayType = c_int
EGLNativePixmapType = c_void_p
EGLNativeWindowType = c_void_p

# /* EGLint is defined in eglplatform.h */
EGLint = khronos_int32_t

EGLBoolean = c_uint
EGLenum = c_uint

EGLConfig = c_void_p
EGLContext = c_void_p
EGLDisplay = c_void_p
EGLSurface = c_void_p
EGLClientBuffer = c_void_p

EGL_VERSION_1_4         = 1

# /* EGL Enumerants. Bitmasks and other exceptional cases aside, most
#  * enums are assigned unique values starting at 0x3000.

# /* EGL aliases */
EGL_FALSE           = 0
EGL_TRUE            = 1

# /* Out-of-band handle values */
EGL_DEFAULT_DISPLAY = 0 # (EGLNativeDisplayType)
EGL_NO_CONTEXT = EGLContext(0)
EGL_NO_DISPLAY = EGLDisplay(0)
EGL_NO_SURFACE = EGLSurface(0)

# /* Out-of-band attribute value */
EGL_DONT_CARE = -1 # (EGLint)

# /* Errors / GetError return values */
EGL_SUCCESS = 0x3000
EGL_NOT_INITIALIZED = 0x3001
EGL_BAD_ACCESS = 0x3002
EGL_BAD_ALLOC = 0x3003
EGL_BAD_ATTRIBUTE = 0x3004
EGL_BAD_CONFIG = 0x3005
EGL_BAD_CONTEXT = 0x3006
EGL_BAD_CURRENT_SURFACE = 0x3007
EGL_BAD_DISPLAY = 0x3008
EGL_BAD_MATCH = 0x3009
EGL_BAD_NATIVE_PIXMAP = 0x300A
EGL_BAD_NATIVE_WINDOW = 0x300B
EGL_BAD_PARAMETER = 0x300C
EGL_BAD_SURFACE = 0x300D
EGL_CONTEXT_LOST = 0x300E  # /* EGL 1.1 - IMG_power_management */

# /* Reserved 0x300F-0x301F for additional errors */

# /* Config attributes */
EGL_BUFFER_SIZE = 0x3020
EGL_ALPHA_SIZE = 0x3021
EGL_BLUE_SIZE = 0x3022
EGL_GREEN_SIZE = 0x3023
EGL_RED_SIZE = 0x3024
EGL_DEPTH_SIZE = 0x3025
EGL_STENCIL_SIZE = 0x3026
EGL_CONFIG_CAVEAT = 0x3027
EGL_CONFIG_ID = 0x3028
EGL_LEVEL = 0x3029
EGL_MAX_PBUFFER_HEIGHT = 0x302A
EGL_MAX_PBUFFER_PIXELS = 0x302B
EGL_MAX_PBUFFER_WIDTH = 0x302C
EGL_NATIVE_RENDERABLE = 0x302D
EGL_NATIVE_VISUAL_ID = 0x302E
EGL_NATIVE_VISUAL_TYPE = 0x302F
EGL_PRESERVED_RESOURCES = 0x3030
EGL_SAMPLES = 0x3031
EGL_SAMPLE_BUFFERS = 0x3032
EGL_SURFACE_TYPE = 0x3033
EGL_TRANSPARENT_TYPE = 0x3034
EGL_TRANSPARENT_BLUE_VALUE = 0x3035
EGL_TRANSPARENT_GREEN_VALUE = 0x3036
EGL_TRANSPARENT_RED_VALUE = 0x3037
EGL_NONE = 0x3038  # /* Attrib list terminator */
EGL_BIND_TO_TEXTURE_RGB = 0x3039
EGL_BIND_TO_TEXTURE_RGBA = 0x303A
EGL_MIN_SWAP_INTERVAL = 0x303B
EGL_MAX_SWAP_INTERVAL = 0x303C
EGL_LUMINANCE_SIZE = 0x303D
EGL_ALPHA_MASK_SIZE = 0x303E
EGL_COLOR_BUFFER_TYPE = 0x303F
EGL_RENDERABLE_TYPE = 0x3040
EGL_MATCH_NATIVE_PIXMAP = 0x3041  # /* Pseudo-attribute (not queryable) */
EGL_CONFORMANT = 0x3042

# /* Reserved 0x3041-0x304F for additional config attributes */

# /* Config attribute values */
EGL_SLOW_CONFIG = 0x3050  # /* EGL_CONFIG_CAVEAT value */
EGL_NON_CONFORMANT_CONFIG = 0x3051  # /* EGL_CONFIG_CAVEAT value */
EGL_TRANSPARENT_RGB = 0x3052  # /* EGL_TRANSPARENT_TYPE value */
EGL_RGB_BUFFER = 0x308E  # /* EGL_COLOR_BUFFER_TYPE value */
EGL_LUMINANCE_BUFFER = 0x308F  # /* EGL_COLOR_BUFFER_TYPE value */

# /* More config attribute values, for EGL_TEXTURE_FORMAT */
EGL_NO_TEXTURE = 0x305C
EGL_TEXTURE_RGB = 0x305D
EGL_TEXTURE_RGBA = 0x305E
EGL_TEXTURE_2D = 0x305F

# /* Config attribute mask bits */
EGL_PBUFFER_BIT = 0x0001  # /* EGL_SURFACE_TYPE mask bits */
EGL_PIXMAP_BIT = 0x0002  # /* EGL_SURFACE_TYPE mask bits */
EGL_WINDOW_BIT = 0x0004  # /* EGL_SURFACE_TYPE mask bits */
EGL_VG_COLORSPACE_LINEAR_BIT = 0x0020  # /* EGL_SURFACE_TYPE mask bits */
EGL_VG_ALPHA_FORMAT_PRE_BIT = 0x0040  # /* EGL_SURFACE_TYPE mask bits */
EGL_MULTISAMPLE_RESOLVE_BOX_BIT = 0x0200  # /* EGL_SURFACE_TYPE mask bits */
EGL_SWAP_BEHAVIOR_PRESERVED_BIT = 0x0400  # /* EGL_SURFACE_TYPE mask bits */

EGL_OPENGL_ES_BIT = 0x0001  # /* EGL_RENDERABLE_TYPE mask bits */
EGL_OPENVG_BIT = 0x0002  # /* EGL_RENDERABLE_TYPE mask bits */
EGL_OPENGL_ES2_BIT = 0x0004  # /* EGL_RENDERABLE_TYPE mask bits */
EGL_OPENGL_BIT = 0x0008  # /* EGL_RENDERABLE_TYPE mask bits */

# /* QueryString targets */
EGL_VENDOR = 0x3053
EGL_VERSION = 0x3054
EGL_EXTENSIONS = 0x3055
EGL_CLIENT_APIS = 0x308D

# /* QuerySurface / SurfaceAttrib / CreatePbufferSurface targets */
EGL_HEIGHT = 0x3056
EGL_WIDTH = 0x3057
EGL_LARGEST_PBUFFER = 0x3058
EGL_TEXTURE_FORMAT = 0x3080
EGL_TEXTURE_TARGET = 0x3081
EGL_MIPMAP_TEXTURE = 0x3082
EGL_MIPMAP_LEVEL = 0x3083
EGL_RENDER_BUFFER = 0x3086
EGL_VG_COLORSPACE = 0x3087
EGL_VG_ALPHA_FORMAT = 0x3088
EGL_HORIZONTAL_RESOLUTION = 0x3090
EGL_VERTICAL_RESOLUTION = 0x3091
EGL_PIXEL_ASPECT_RATIO = 0x3092
EGL_SWAP_BEHAVIOR = 0x3093
EGL_MULTISAMPLE_RESOLVE = 0x3099

# /* EGL_RENDER_BUFFER values / BindTexImage / ReleaseTexImage buffer targets */
EGL_BACK_BUFFER = 0x3084
EGL_SINGLE_BUFFER = 0x3085

# /* OpenVG color spaces */
EGL_VG_COLORSPACE_sRGB = 0x3089  # /* EGL_VG_COLORSPACE value */
EGL_VG_COLORSPACE_LINEAR = 0x308A  # /* EGL_VG_COLORSPACE value */

# /* OpenVG alpha formats */
EGL_VG_ALPHA_FORMAT_NONPRE = 0x308B  # /* EGL_ALPHA_FORMAT value */
EGL_VG_ALPHA_FORMAT_PRE = 0x308C  # /* EGL_ALPHA_FORMAT value */

# /* Constant scale factor by which fractional display resolutions &
#  * aspect ratio are scaled when queried as integer values.
#  */
EGL_DISPLAY_SCALING = 10000

# /* Unknown display resolution/aspect ratio */
EGL_UNKNOWN = -1 # (EGLint)

# /* Back buffer swap behaviors */
EGL_BUFFER_PRESERVED = 0x3094  # /* EGL_SWAP_BEHAVIOR value */
EGL_BUFFER_DESTROYED = 0x3095  # /* EGL_SWAP_BEHAVIOR value */

# /* CreatePbufferFromClientBuffer buffer types */
EGL_OPENVG_IMAGE = 0x3096

# /* QueryContext targets */
EGL_CONTEXT_CLIENT_TYPE = 0x3097

# /* CreateContext attributes */
EGL_CONTEXT_CLIENT_VERSION = 0x3098

# /* Multisample resolution behaviors */
EGL_MULTISAMPLE_RESOLVE_DEFAULT = 0x309A  # /* EGL_MULTISAMPLE_RESOLVE value */
EGL_MULTISAMPLE_RESOLVE_BOX = 0x309B  # /* EGL_MULTISAMPLE_RESOLVE value */

# /* BindAPI/QueryAPI targets */
EGL_OPENGL_ES_API = 0x30A0
EGL_OPENVG_API = 0x30A1
EGL_OPENGL_API = 0x30A2

# /* GetCurrentSurface targets */
EGL_DRAW = 0x3059
EGL_READ = 0x305A

# /* WaitNative engines */
EGL_CORE_NATIVE_ENGINE = 0x305B

# /* EGL 1.2 tokens renamed for consistency in EGL 1.3 */
EGL_COLORSPACE = EGL_VG_COLORSPACE
EGL_ALPHA_FORMAT = EGL_VG_ALPHA_FORMAT
EGL_COLORSPACE_sRGB = EGL_VG_COLORSPACE_sRGB
EGL_COLORSPACE_LINEAR = EGL_VG_COLORSPACE_LINEAR
EGL_ALPHA_FORMAT_NONPRE = EGL_VG_ALPHA_FORMAT_NONPRE
EGL_ALPHA_FORMAT_PRE = EGL_VG_ALPHA_FORMAT_PRE

# /* EGL extensions must request enum blocks from the Khronos
#  * API Registrar, who maintains the enumerant registry. Submit
#  * a bug in Khronos Bugzilla against task "Registry".
#  */

# /* EGL Functions */

eglGetError = _func(EGLint)

eglGetDisplay = _func(EGLDisplay, EGLNativeDisplayType)
eglInitialize = _func(EGLBoolean, EGLDisplay, POINTER(EGLint), POINTER(EGLint))
eglTerminate = _func(EGLBoolean, EGLDisplay)
eglQueryString = _func(c_char_p, EGLDisplay, EGLint)
eglGetConfigs = _func(EGLBoolean, EGLDisplay, POINTER(EGLConfig),
                EGLint, POINTER(EGLint))
eglChooseConfig = _func(EGLBoolean, EGLDisplay, POINTER(EGLint),
                POINTER(EGLConfig), EGLint, POINTER(EGLint))
eglGetConfigAttrib = _func(EGLBoolean, EGLDisplay, EGLConfig,
                EGLint, POINTER(EGLint))
eglCreateWindowSurface = _func(EGLSurface, EGLDisplay, EGLConfig,
                EGLNativeWindowType, POINTER(EGLint))
eglCreatePbufferSurface = _func(EGLSurface, EGLDisplay, EGLConfig,
                POINTER(EGLint))
eglCreatePixmapSurface = _func(EGLSurface, EGLDisplay, EGLConfig,
                EGLNativePixmapType, POINTER(EGLint))
eglDestroySurface = _func(EGLBoolean, EGLDisplay, EGLSurface)
eglQuerySurface = _func(EGLBoolean, EGLDisplay, EGLSurface,
                EGLint, POINTER(EGLint))
eglBindAPI = _func(EGLBoolean, EGLenum)
eglQueryAPI = _func(EGLenum)
eglWaitClient = _func(EGLBoolean)
eglReleaseThread = _func(EGLBoolean)
eglCreatePbufferFromClientBuffer = _func(EGLSurface, EGLDisplay, EGLenum,
                EGLClientBuffer, EGLConfig, POINTER(EGLint))
eglSurfaceAttrib = _func(EGLBoolean, EGLDisplay, EGLSurface, EGLint, EGLint)
eglBindTexImage = _func(EGLBoolean, EGLDisplay, EGLSurface, EGLint)
eglReleaseTexImage = _func(EGLBoolean, EGLDisplay, EGLSurface, EGLint)
eglSwapInterval = _func(EGLBoolean, EGLDisplay, EGLint)
eglCreateContext = _func(EGLContext, EGLDisplay, EGLConfig,
                EGLContext, POINTER(EGLint))
eglDestroyContext = _func(EGLBoolean, EGLDisplay, EGLContext)
eglMakeCurrent = _func(EGLBoolean, EGLDisplay, EGLSurface, EGLSurface,
                EGLContext)
eglGetCurrentContext = _func(EGLContext)
eglGetCurrentSurface = _func(EGLSurface, EGLint)
eglGetCurrentDisplay = _func(EGLDisplay)
eglQueryContext = _func(EGLBoolean, EGLDisplay, EGLContext,
                EGLint, POINTER(EGLint))
eglWaitGL = _func(EGLBoolean)
eglWaitNative = _func(EGLBoolean, EGLint)
eglSwapBuffers = _func(EGLBoolean, EGLDisplay, EGLSurface)
eglCopyBuffers = _func(EGLBoolean, EGLDisplay, EGLSurface,
                EGLNativePixmapType)

# /* This is a generic function pointer type, whose name indicates it must
#  * be cast to the proper type *and calling convention* before use.
#  */
# typedef void (*__eglMustCastToProperFunctionPointerType)(void)

# /* Now, define eglGetProcAddress using the generic function ptr. type */
# __eglMustCastToProperFunctionPointerType EGLAPIENTRY
#        eglGetProcAddress(const char *procname)

#----------------------------
# apply argtypes/restype to all functions
#
_register_funcs('libEGL.so', globals())

# EOF
