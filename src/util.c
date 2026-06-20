#include <atari.h>
#include <peekpoke.h>
#include "util.h"

const char *util_target_name(void)
{
#ifdef __ATARIXL__
    return "Atari XL/XE";
#else
    return "Atari 400/800";
#endif
}

unsigned int util_free_ram(void)
{
    unsigned int memtop = PEEKW(0x02E5);
    unsigned int memlo  = PEEKW(0x02E7);

    if (memtop > memlo)
        return memtop - memlo;
    return 0;
}