#include "defs.h"
#include <stdint.h>
#include "stdio.h"
#include "disk.h"

void far* data = (void far*)0x50000000;

void ASMCALL start(uint16_t bootDrive)
{
    Disk disk;
    if (!Disk_Initialize(&disk, bootDrive))
    {
        printf("Cannot initialize disk!\n");
        goto end;
    }

    if (!Disk_ReadSectors(&disk, 19, 1, data))
    {
        printf("Cannot read data!\n");
        goto end;
    }

end:
    for (;;);
}