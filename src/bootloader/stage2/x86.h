#pragma once

#include "defs.h"
#include <stdint.h>
#include <stdbool.h>

void ASMCALL x86_Video_WriteCharTTY(char c, uint8_t page);

bool ASMCALL x86_Disk_GetDriveParameters(uint8_t drive,
                                         uint8_t* driveTypeOut,
                                         uint16_t* cylindersOut,
                                         uint16_t* sectorsOut,
                                         uint16_t* headsOut);

bool x86_Disk_Read(uint8_t drive,
                   uint16_t cylinder,
                   uint16_t sector,
                   uint16_t head,
                   uint8_t count,
                   void far* dataOut);

bool ASMCALL x86_Disk_Reset(uint8_t drive);