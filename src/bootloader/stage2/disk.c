#include "disk.h"
#include "x86.h"
#include <stddef.h>

bool DiskInitialize(Disk* disk, uint8_t driveNumber)
{
    uint8_t driveType;
    uint16_t cylinders, heads, sectors;

    if (!x86_Disk_GetDriveParameters(driveNumber, &driveType, &cylinders, &heads, &sectors))
        return false;

    disk->id = driveNumber;
    disk->cylinders = cylinders + 1;
    disk->heads = heads + 1;
    disk->sectors = sectors;

    return true;
}

void DiskLbaToChs(Disk* disk, uint32_t lba, uint16_t* cylinder, uint16_t* head, uint16_t* sector)
{
    // compute cylinder
    *cylinder = lba / (disk->heads * disk->sectors);
    // comput head
    *head = (lba / disk->sectors) % disk->heads;
    // compute sector
    *sector = (lba % disk->sectors) + 1;
}

bool DiskReadSectors(Disk* disk, uint32_t lba, uint8_t sectors, void far* data)
{
    uint16_t cylinder, sector, head;
    DiskLbaToChs(disk, lba, &cylinder, &head, &sector);

    for (size_t i = 0; i < 3; i++)
    {
        if (x86_Disk_Read(disk->id, cylinder, head, sector, sectors, data))
            return true;
        
        x86_Disk_Reset(disk->id);
    }

    return false;
}