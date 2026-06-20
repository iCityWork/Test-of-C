#include <stdio.h>
#include <conio.h>
#include <atari.h>
#include "util.h"
#include "screen.h"

int main(void)
{
    unsigned char key;
    unsigned int  counter = 0;

    screen_init();

    cputs("  CC65 Multi-File Build\r\n");
    cputs("  =====================\r\n\r\n");

    cprintf("  Build target  : %s\r\n", util_target_name());
    cprintf("  Free RAM est. : %u bytes\r\n", util_free_ram());

    cputs("\r\n  Press any key to count, Q to quit.\r\n\r\n");

    do {
        key = cgetc();
        if (key != 'q' && key != 'Q') {
            ++counter;
            cprintf("  Count: %u\r\n", counter);
        }
    } while (key != 'q' && key != 'Q');

    cputs("\r\n  Goodbye!\r\n");
    return 0;
}