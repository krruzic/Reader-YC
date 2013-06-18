// logging via slog2

#include <stdio.h>
#include <slog2.h>

#include "debug.h"

#if defined(DEBUG) && (DEBUG != 0)

slog2_buffer_t  slog;
slog2_buffer_set_config_t cfg = {
    1,              // num_buffers
    "ca.microcode.ThisApp",       // buffer_set_name
    SLOG2_DEBUG2,   // verbosity_level
    {
        {"chart",   // buffer_name
        2}           // num_pages
    }
};

//-----------------------------------------------
// Initialize logging via slog2. This routine is idempotent
// so it can be called repeatedly without problems.
//
void setup_logging() {
    int rc;

    if (!slog) {
        rc = slog2_register(&cfg, &slog, 0);
        if (rc < 0)
            fprintf(stderr, "slog2_register: %d\n", rc);
        // slog2c(slog, 0, SLOG2_INFO, "configured log");
    }
}

#else


#endif
