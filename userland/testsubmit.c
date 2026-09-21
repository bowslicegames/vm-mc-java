#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "libfakegpu.h"

int main(void) {
    struct fg_handle *h = fg_open("/tmp/fakegpu.map");
    if (!h) {
        perror("fg_open");
        return 1;
    }

    const char *cmd = "CMD_CLEAR 0.2 0.3 0.4 1.0\n";
    uint32_t len = (uint32_t)(strlen(cmd) + 1);

    uint32_t head = h->hdr->head % h->ring_size;
    memcpy((char*)h->ring + head, cmd, len);
    h->hdr->head += len;

    if (fg_submit(h, len) != 0) {
        perror("fg_submit");
        fg_close(h);
        return 1;
    }

    printf("Submitted %u bytes\n", len);

    fg_wait_consumed(h, h->hdr->head);

    fg_close(h);
    return 0;
}
