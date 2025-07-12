#include "defs.h"
#include <stdint.h>
#include "stdio.h"
#include "disk.h"

uint8_t far* data = (uint8_t far*)0x50000000;

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

    for (int i = 0; i < 5 * 32; i += 32)
    {
        for (int j = 0; j < 11; j++)
            putc(data[i + j]);
        putc('\n');
    }

end:
    for (;;);
}