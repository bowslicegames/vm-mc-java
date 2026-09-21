#include "libfakegpu.h"
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <string.h>
#include <stdio.h>

#define FG_IOC_MAGIC 'F'
#define FG_IOC_SUBMIT _IOW(FG_IOC_MAGIC, 1, uint32_t)
#define FG_IOC_WAIT   _IOR(FG_IOC_MAGIC, 2, uint32_t)

struct fg_handle *fg_open(const char *path)
{
    int fd = open(path, O_RDWR | O_CREAT, 0600);
    if (fd < 0) return NULL;

    size_t map_size = 4096 + (16 * 4096);
    if (ftruncate(fd, map_size) != 0) {
        close(fd);
        return NULL;
    }
    void *map = mmap(NULL, map_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (map == MAP_FAILED) {
        close(fd);
        return NULL;
    }

    struct fg_handle *h = calloc(1, sizeof(*h));
    h->fd = fd;
    h->hdr = (struct fg_header *)map;
    h->ring = (void *)((char *)map + 4096);
    h->ring_size = 16 * 4096;
    h->hdr->size = h->ring_size;
    return h;
}

void fg_close(struct fg_handle *h)
{
    if (!h) return;
    size_t map_size = 4096 + h->ring_size;
    munmap(h->hdr, map_size);
    close(h->fd);
    free(h);
}

int fg_submit(struct fg_handle *h, uint32_t bytes)
{
    // For local testing, just advance head
    h->hdr->head += bytes;
    return 0;
}

int fg_wait_consumed(struct fg_handle *h, uint32_t want)
{
    // Busy wait (for testing)
    while (h->hdr->tail < want) {
        usleep(1000);
    }
    return 0;
}
