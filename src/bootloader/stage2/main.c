#include "defs.h"
#include <stdint.h>
#include "stdio.h"

void ASMCALL start(uint16_t bootDrive)
{
    printf("Hello world!\n");
    for (;;);
}