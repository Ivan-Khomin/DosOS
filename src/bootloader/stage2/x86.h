#pragma once

#include "defs.h"
#include <stdint.h>
#include <stdbool.h>

void ASMCALL x86_Video_WriteCharTTY(char c, uint8_t page);

bool ASMCALL x86_Disk_GetDriveParameters(uint8_t drive,
                                         uint8_t* driveType,
                                         uint16_t* cylinders,
                                         uint16_t* sectors,
                                         uint16_t* heads);

bool x86_Disk_Read(uint8_t drive,
                   uint16_t cylinder,
                   uint16_t sector,
                   uint16_t head,
                   uint8_t count,
                   void far* data);

bool ASMCALL x86_Disk_Reset(uint8_t drive);