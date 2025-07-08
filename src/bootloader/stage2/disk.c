#include "disk.h"
#include "x86.h"

bool Disk_Initialize(Disk* disk, uint8_t driveNumber)
{
    uint8_t driveType;
    uint16_t cylinders, sectors, heads;

    if (!x86_Disk_GetDriveParameters(driveNumber, &driveType, &cylinders, &sectors, &heads))
        return false;

    disk->drive = driveNumber;
    disk->driveType = driveType;
    disk->cylinders = cylinders + 1;
    disk->sectors = sectors;
    disk->heads = heads + 1;

    return true;
}

void Disk_LBATOCHS(Disk* disk, uint32_t lba, uint16_t* cylinderOut, uint16_t* sectorOut, uint16_t* headOut)
{
    // compute cylinder
    *cylinderOut = lba / (disk->heads * disk->sectors);
    // compute sector
    *sectorOut = (lba % disk->sectors) + 1;
    // comput head
    *headOut = (lba / disk->sectors) % disk->heads;
}

bool Disk_ReadSectors(Disk* disk, uint32_t lba, uint8_t sectors, void far* dataOut)
{
    uint16_t cylinder, sector, head;
    Disk_LBATOCHS(disk, lba, &cylinder, &sector, &head);

    for (int i = 0; i < 3; i++)
    {
        if (x86_Disk_Read(disk->drive, cylinder, sector, head, sectors, dataOut))
            return true;

        x86_Disk_Reset(disk->drive);
    }

    return false;
}