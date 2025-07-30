#pragma once

#include "defs.h"
#include <stdint.h>
#include <stdbool.h>

typedef struct
{
    uint8_t id;
    uint16_t cylinders;
    uint16_t heads;
    uint16_t sectors;
} Disk;

bool DiskInitialize(Disk* disk, uint8_t driveNumber);
bool DiskReadSectors(Disk* disk, uint32_t lba, uint8_t sectors, void far* data);