/*
 * screen.c — Basic screen setup
 */

#include <atari.h>
#include <conio.h>
#include <peekpoke.h>
#include "screen.h"

/*
 * Atari color byte format:
 *   Bits 7-4 = Hue  (0=grey/white family, 9=blue family, etc.)
 *   Bits 3-1 = Luminance (0=dark, 7=bright)
 *   Bit  0   = always 0
 *
 * Shadow registers (OS VBI copies these to hardware each frame):
 *   $02C5 = COLPF1 — text foreground color  (GR.0)
 *   $02C6 = COLPF2 — background color       (GR.0)
 *   $02C7 = COLPF3 — not used in GR.0
 *   $02C8 = COLBK  — border/background
 */

#define COLPF1_SHADOW  0x02C5   /* text foreground */
#define COLPF2_SHADOW  0x02C6   /* background      */
#define COLBK_SHADOW   0x02C8   /* border          */

void screen_init(void)
{
    clrscr();

    /* Classic Atari blue-on-white scheme                               */
    /* 0x94 = hue 9 (blue), luminance 2 → dark blue background         */
    /* 0x0E = hue 0 (grey/white family), luminance 7 → bright white    */
    POKE(COLPF2_SHADOW, 0x94);  /* background : dark blue  */
    POKE(COLPF1_SHADOW, 0x0E);  /* foreground : white      */
    POKE(COLBK_SHADOW,  0x94);  /* border same as background */
}