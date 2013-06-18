#ifndef DEBUG_H
#define DEBUG_H

#include <slog2.h>

// this block allows you to disable debug stuff on a per-module basis
// by doing #define DEBUG 0

// the commented out one would let you disable debug stuff globally
// #undef DEBUG
#define DEBUG 0

// unless it's off above or defined (maybe off) per-module, do this
#ifndef DEBUG
#   define DEBUG 0
#endif

#if defined(DEBUG) && (DEBUG != 0)

// in logging.c
#include <slog2.h>
extern slog2_buffer_t  slog;
void setup_logging();

#   define log_debug(...)   slog2f(slog, 0, SLOG2_DEBUG1, __VA_ARGS__)
#   define log_info(...)    slog2f(slog, 0, SLOG2_INFO, __VA_ARGS__)

#else
#   define log_debug(...)
#   define log_info(...)
#   define setup_logging()

#endif // defined(DEBUG)

#   define log_error(...)   slog2f(slog, 0, SLOG2_ERROR, __VA_ARGS__)
#   define log_warning(...) slog2f(slog, 0, SLOG2_WARNING, __VA_ARGS__)

#endif
