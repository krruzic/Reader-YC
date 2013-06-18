'''Wrappers for libimage routines'''

import ctypes
from ctypes import (c_bool, c_ubyte, c_ushort, c_float, c_double, c_int, c_char_p, c_void_p, c_uint, c_longlong, c_ulonglong,
    POINTER, Structure, Union, CFUNCTYPE)

from ._wrap import _func, _register_funcs

# from img/img_errno.h
IMG_ERR_OK			= 0
IMG_ERR_TRUNC		= 1	# premature EOF
IMG_ERR_CORRUPT		= 2	# unrecoverable error in data stream
IMG_ERR_FORMAT		= 3	# file format not recognized
IMG_ERR_NODATA		= 4	# no data present
IMG_ERR_NOSUPPORT	= 5	# request value/format/conversion not supported
IMG_ERR_MEM			= 6	# memory allocation error
IMG_ERR_CFG			= 7	# bad or missing config file
IMG_ERR_DLL			= 8	# error accessing dll or entrypoint
IMG_ERR_FILE		= 9	# file access error
IMG_ERR_INTR		= 10# operation interrupted by application
IMG_ERR_PARM		= 11# invalid parameter
IMG_ERR_NOTIMPL		= 12# operation not implemented


IMG_FMT_MASK_BPP	= 0x0000007f
IMG_FMT_PKLE		= 0x00000100
IMG_FMT_PKBE		= 0x00000200
IMG_FMT_PACK		= IMG_FMT_PKLE | IMG_FMT_PKBE
IMG_FMT_ALPHA		= 0x00000400
IMG_FMT_PALETTE		= 0x00000800
IMG_FMT_RGB			= 0x00001000
IMG_FMT_YUV			= 0x00002000
IMG_FMT_RGB_ORDER	= 0x01000000
IMG_FMT_G6			= 0x01000000

def IMG_FMT_BPP(_fmt): return _fmt & IMG_FMT_MASK_BPP
def IMG_FMT_BPL(_fmt,_w): return (IMG_FMT_BPP(_fmt) * (_w) + 7) >> 3

img_lib_t = c_void_p
img_codec_t = c_void_p

IMG_FMT_INVALID = 0
IMG_FMT_MONO = 1
IMG_FMT_G8 = 8
IMG_FMT_A8 = 8 | IMG_FMT_ALPHA
IMG_FMT_PAL1 = 1 | IMG_FMT_PALETTE
IMG_FMT_PAL4 = 4 | IMG_FMT_PALETTE
IMG_FMT_PAL8 = 8 | IMG_FMT_PALETTE
IMG_FMT_PKLE_RGB565 = 16 | IMG_FMT_PKLE | IMG_FMT_RGB | IMG_FMT_G6
IMG_FMT_PKBE_RGB565 = 16 | IMG_FMT_PKBE | IMG_FMT_RGB | IMG_FMT_G6
IMG_FMT_PKLE_ARGB1555 = 16 | IMG_FMT_PKLE | IMG_FMT_ALPHA | IMG_FMT_RGB
IMG_FMT_PKBE_ARGB1555 = 16 | IMG_FMT_PKBE | IMG_FMT_ALPHA | IMG_FMT_RGB
IMG_FMT_PKLE_XRGB1555 = 16 | IMG_FMT_PKLE | IMG_FMT_RGB
IMG_FMT_PKBE_XRGB1555 = 16 | IMG_FMT_PKBE | IMG_FMT_RGB
IMG_FMT_BGR888 = 24 | IMG_FMT_RGB
IMG_FMT_RGB888 = 24 | IMG_FMT_RGB | IMG_FMT_RGB_ORDER
IMG_FMT_PKLE_ABGR8888 = 32 | IMG_FMT_PKLE | IMG_FMT_ALPHA | IMG_FMT_RGB | IMG_FMT_RGB_ORDER
IMG_FMT_PKBE_ABGR8888 = 32 | IMG_FMT_PKBE | IMG_FMT_ALPHA | IMG_FMT_RGB | IMG_FMT_RGB_ORDER
IMG_FMT_PKLE_XBGR8888 = 32 | IMG_FMT_PKLE | IMG_FMT_RGB | IMG_FMT_RGB_ORDER
IMG_FMT_PKBE_XBGR8888 = 32 | IMG_FMT_PKBE | IMG_FMT_RGB | IMG_FMT_RGB_ORDER
IMG_FMT_PKLE_ARGB8888 = 32 | IMG_FMT_PKLE | IMG_FMT_ALPHA | IMG_FMT_RGB
IMG_FMT_PKBE_ARGB8888 = 32 | IMG_FMT_PKBE | IMG_FMT_ALPHA | IMG_FMT_RGB
IMG_FMT_PKLE_XRGB8888 = 32 | IMG_FMT_PKLE | IMG_FMT_RGB
IMG_FMT_PKBE_XRGB8888 = 32 | IMG_FMT_PKBE | IMG_FMT_RGB
IMG_FMT_YUV888 = 24 | IMG_FMT_YUV
img_format_t = c_int

#define IMG_FMT_PKHE			IMG_FMT_PKLE
#define IMG_FMT_PKHE_RGB565		IMG_FMT_PKLE_RGB565
#define IMG_FMT_PKHE_ARGB1555	IMG_FMT_PKLE_ARGB1555
#define IMG_FMT_PKHE_XRGB1555	IMG_FMT_PKLE_XRGB1555
#define IMG_FMT_PKHE_ABGR8888	IMG_FMT_PKLE_ABGR8888
#define IMG_FMT_PKHE_XBGR8888	IMG_FMT_PKLE_XBGR8888
#define IMG_FMT_PKHE_ARGB8888	IMG_FMT_PKLE_ARGB8888
#define IMG_FMT_PKHE_XRGB8888	IMG_FMT_PKLE_XRGB8888
#define IMG_FMT_PKOE			IMG_FMT_PKBE
#define IMG_FMT_PKOE_RGB565		IMG_FMT_PKBE_RGB565
#define IMG_FMT_PKOE_ARGB1555	IMG_FMT_PKBE_ARGB1555
#define IMG_FMT_PKOE_XRGB1555	IMG_FMT_PKBE_XRGB1555
#define IMG_FMT_PKOE_ABGR8888	IMG_FMT_PKBE_ABGR8888
#define IMG_FMT_PKOE_XBGR8888	IMG_FMT_PKBE_XBGR8888
#define IMG_FMT_PKOE_ARGB8888	IMG_FMT_PKBE_ARGB8888
#define IMG_FMT_PKOE_XRGB8888	IMG_FMT_PKBE_XRGB8888

#define IMG_FMT_BGRA8888		IMG_FMT_PKLE_ARGB8888
IMG_FMT_RGBA8888		= IMG_FMT_PKLE_ABGR8888

# img_color_t encoding is IMG_FMT_PKHE_ARGB8888 unless otherwise noted
img_color_t = c_uint

# data transform handle
img_dtransform_t = c_void_p

# img_fixed_t encoding is 16.16 unless otherwise noted
img_fixed_t = c_uint

'''
typedef void	(img_access_f)	(_Uintptrt data, unsigned x, unsigned y, unsigned n, _uint8 *pixels);
typedef void	(img_convert_f)	(const _uint8 *src, _uint8 *dst, unsigned n);
typedef void	(img_expand_f)	(const _uint8 *src, _uint8 *dst, unsigned n, const _uint8 *lut);
typedef void	(img_avg_f)		(const _uint8 *a, const _uint8 *b, _uint8 *dst, unsigned n);
typedef void	(img_copy_f)	(const _uint8 *src, _uint8 *dst, int stride, unsigned n);
'''

class _direct_struct(Structure):
    _fields_ = [
        ('data', POINTER(c_ubyte)),
        ('stride', c_uint),
        ]

class _indirect_struct(Structure):
    _fields_ = [
        ('access_f', c_void_p),
        ('data', POINTER(c_uint)),
        ]

class _access_union(Union):
    _fields_ = [
        ('direct', _direct_struct),
        ('indirect', _indirect_struct),
        ]

class _transparency_union(Union):
    _fields_ = [
        ('index', c_ubyte),
        ('rgb16', c_ushort),
        ('rgb32', img_color_t),
        ]

class img_t(Structure):
    _fields_ = [
        ('access', _access_union),
        ('w', c_uint),
        ('h', c_uint),
        ('format', img_format_t),
        ('npalette', c_uint),
        ('palette', POINTER(img_color_t)),
        ('flags', c_uint),
        ('transparency', _transparency_union),
        ('quality', c_uint),
        ]

img_info_t = img_t

img_decode_choose_format_f = CFUNCTYPE(c_uint, POINTER(c_uint), POINTER(img_t), POINTER(img_format_t), c_uint)
img_decode_setup_f = CFUNCTYPE(c_int, POINTER(c_uint), POINTER(img_t), c_uint)
img_decode_abort_f = CFUNCTYPE(None, POINTER(c_uint), POINTER(img_t))
img_decode_scanline_f = CFUNCTYPE(c_int, POINTER(c_uint), POINTER(img_t), c_uint, c_uint, c_uint)
img_decode_set_palette_f = CFUNCTYPE(c_int, POINTER(c_uint), POINTER(img_t), POINTER(c_ubyte), img_format_t)
img_decode_set_transparency_f = CFUNCTYPE(None, POINTER(c_uint), POINTER(img_t), img_color_t)
img_decode_frame_f = CFUNCTYPE(None, POINTER(c_uint), POINTER(img_t))
img_decode_set_value_f = CFUNCTYPE(c_int, POINTER(c_uint), POINTER(img_t), c_uint, POINTER(c_uint))

class img_decode_callouts_t(Structure):
    _fields_ = [
        ('choose_format_f', img_decode_choose_format_f),
        ('setup_f', img_decode_setup_f),
        ('abort_f', img_decode_abort_f),
        ('scanline_f', img_decode_scanline_f),
        ('set_palette_f', img_decode_set_palette_f),
        ('set_transparency_f', img_decode_set_transparency_f),
        ('frame_f', img_decode_frame_f),
        ('set_value_f', img_decode_set_value_f),
        ('data', POINTER(c_uint)),
        ]

'''
typedef unsigned	(img_encode_choose_format_f)	(_Uintptrt data, img_t *img, const img_format_t *formats, unsigned nformats);
typedef int			(img_encode_setup_f)			(_Uintptrt data, img_t *img, unsigned flags);
typedef void		(img_encode_abort_f)			(_Uintptrt data, img_t *img);
typedef int			(img_encode_scanline_f)			(_Uintptrt data, img_t *img, unsigned row, unsigned npass_line, unsigned npass_total);
typedef int			(img_encode_get_palette_f)		(_Uintptrt data, img_t *img, _uint8 *palette, img_format_t format);
typedef int			(img_encode_get_transparency_f)	(_Uintptrt data, img_t *img, img_color_t *color);
typedef void		(img_encode_frame_f)			(_Uintptrt data, img_t *img);

typedef struct {
    img_encode_choose_format_f		*choose_format_f;
    img_encode_setup_f				*setup_f;
    img_encode_abort_f				*abort_f;
    img_decode_scanline_f			*scanline_f;
    img_encode_get_palette_f		*get_palette_f;
    img_encode_get_transparency_f	*get_transparency_f;
    img_encode_frame_f				*frame_f;
    _Uintptrt data;
} img_encode_callouts_t;
'''

size_t = c_int
img_codec_list_byext = _func(size_t, img_lib_t, c_char_p, POINTER(img_codec_t), size_t)
img_codec_list_bymime = _func(size_t, img_lib_t, c_char_p, POINTER(img_codec_t), size_t)
img_codec_list = _func(size_t, img_lib_t, POINTER(img_codec_t), size_t, POINTER(img_codec_t), size_t)
img_codec_get_criteria = _func(None, img_codec_t, POINTER(c_char_p), POINTER(c_char_p))

img_lib_attach = _func(c_int, POINTER(img_lib_t))
img_lib_detach = _func(None, img_lib_t)
img_cfg_read = _func(c_int, img_lib_t, c_char_p)

#~ img_load = _func(c_int, img_lib_t,
    #~ POINTER(io_stream_t),
    #~ POINTER(img_decode_callouts_t),
    #~ POINTER(img_t))

img_load_file = _func(c_int, img_lib_t, c_char_p, POINTER(img_decode_callouts_t), POINTER(img_t))
img_load_resize_file = _func(c_int, img_lib_t, c_char_p, POINTER(img_decode_callouts_t), POINTER(img_t))

#~ img_load_resize = _func(c_int, img_lib_t,
    #~ POINTER(io_stream_t),
    #~ POINTER(img_decode_callouts_t),
    #~ POINTER(img_t))
#~ img_write = _func(c_int, img_lib_t,
    #~ POINTER(io_stream_t),
    #~ POINTER(img_decode_callouts_t),
    #~ POINTER(img_t), POINTER(img_codec_t))

#~ img_write_file = _func(c_int, img_lib_t, c_char_p, POINTER(img_encode_callouts_t), POINTER(img_t))

#~ extern img_expand_f *img_expand_getfunc(img_format_t src, img_format_t lut);
#~ extern img_convert_f *img_convert_getfunc(img_format_t src, img_format_t dst);
#~ extern int img_convert_data(img_format_t sformat, const _uint8 *src,
    #~ img_format_t dformat, _uint8 *dst,
    #~ size_t n);
#~ extern int img_dtransform(const img_t *src, img_t *dst);
#~ extern int img_dtransform_create(const img_t *src, const img_t *dst, img_dtransform_t *xform);
#~ extern void img_dtransform_apply(img_dtransform_t xform, const _uint8 *src, _uint8 *dst, unsigned n);
#~ extern void img_dtransform_free(img_dtransform_t xform);
#~ extern img_avg_f *img_avg_getfunc(img_format_t format);
#~ extern img_copy_f *img_copy_getfunc(img_format_t format);
#~ extern int img_resize_fs(const img_t *src, img_t *dst);
#~ extern int img_rotate_ortho(const img_t *src, img_t *dst, img_fixed_t angle);
#~ extern int img_decode_validate(const img_codec_t *codecs, size_t ncodecs,
    #~ io_stream_t *input, unsigned *codec);
#~ extern int img_decode_begin(img_codec_t codec, io_stream_t *input, _Uintptrt *decode_data);
#~ extern int img_decode_frame(img_codec_t codec,
    #~ io_stream_t *input,
    #~ const img_decode_callouts_t *callouts,
    #~ img_t *img,
    #~ _Uintptrt *decode_data);
#~ extern int img_decode_finish(img_codec_t codec, io_stream_t *input, _Uintptrt *decode_data);
#~ extern int img_encode_begin(img_codec_t codec, io_stream_t *output, _Uintptrt *encode_data);
#~ extern int img_encode_frame(img_codec_t codec,
    #~ io_stream_t *output,
    #~ const img_encode_callouts_t *callouts,
    #~ img_t *img,
    #~ _Uintptrt *encode_data);
#~ extern int img_encode_finish(img_codec_t codec,
    #~ io_stream_t *output,
    #~ _Uintptrt *encode_data);

img_crop = _func(c_int, POINTER(img_t), POINTER(img_t), c_uint, c_uint)

# flag manifests for img_t
IMG_TRANSPARENCY		= 0x00000001	# 'transparency' field is valid
IMG_FORMAT				= 0x00000002	# 'format' field is valid
IMG_W					= 0x00000004	# 'w' field is valid
IMG_H					= 0x00000008	# 'h' field is valid
IMG_DIRECT				= 0x00000010	# direct access field is valid
IMG_INDIRECT			= 0x00000020	# indirect access field is valid
IMG_PALETTE				= 0x00000080	# 'palette' field is valid
IMG_QUALITY				= 0x00000100	# 'quality' field is valid
IMG_PAL8_ALPHA			= 0x00000200	# PAL8 image palette entries have alpha bits.
IMG_TRANSPARENCY_TO_ALPHA= 0x00000400	# If target format supports alpha, convert transparency into alpha.
IMG_SRC_FMT_TRANSPARENCY = 0x00000800	# The source format of this image specified transparency.

IMG_RESIZE              = 0x00001000  # 'h' and 'w' are the desired size (or zero)

# flag manifests for img_decode_setup_f
IMG_SETUP_PAL_SHARED	= 0x00000001	# palette is shared between frames
IMG_SETUP_TOP_DOWN		= 0x00000002	# scanlines will be delivered in topdown sequence
IMG_SETUP_BOTTOM_UP		= 0x00000004	# scanlines will be delivered in bottomup sequence
IMG_SETUP_MULTIPASS		= 0x00000008	# scanlines will be split across passes

IMG_ANGLE_90CW			= 0x0001921f	# 90 degrees clockwise
IMG_ANGLE_90CCW			= 0x0004b65f	# 90 degrees counterclockwise
IMG_ANGLE_180			= 0x0003243f	# 180 degrees

# types for img_decode_set_value_f
img_value_type = c_int
IMG_VALUE_TYPE_INVALID = 0
IMG_VALUE_TYPE_PROGRESSIVE = 1


#----------------------------
# apply argtypes/restype to all functions
#
_register_funcs('libimg.so', globals())

# EOF
