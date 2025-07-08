#pragma once

#ifdef __FAR
#define far __far
#else
#define far
#endif

#define ASMCALL __attribute__((cdecl))