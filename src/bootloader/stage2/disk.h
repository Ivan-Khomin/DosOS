#pragma once

#include "defs.h"
#include <stdint.h>
#include <stdbool.h>

typedef struct
{
    uint8_t drive, driveType;
    uint16_t cylinders;
    uint16_t sectors;
    uint16_t heads;
} Disk;

bool Disk_Initialize(Disk* disk, uint8_t driveNumber);
bool Disk_Read(Disk* disk, uint32_t lba, uint8_t sectors, void far* data);