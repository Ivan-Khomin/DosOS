#include "defs.h"
#include <stdint.h>
#include "stdio.h"
#include "disk.h"

void ASMCALL start(uint16_t bootDrive)
{
    Disk disk;
    if (!Disk_Initialize(&disk, bootDrive))
    {
        printf("Cannot initialize disk!\n");
        goto end;
    }

end:
    for (;;);
}