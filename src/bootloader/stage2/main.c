#include "defs.h"
#include <stdint.h>
#include "stdio.h"
#include "disk.h"

void far* data = (void far*)0x20000000;

void ASMCALL start(uint16_t bootDrive)
{
    Disk disk;
    if (!DiskInitialize(&disk, bootDrive))
    {
        printf("Cannot init disk\n");
        goto end;
    }

    DiskReadSectors(&disk, 19, 1, data);

end:
    for (;;);
}