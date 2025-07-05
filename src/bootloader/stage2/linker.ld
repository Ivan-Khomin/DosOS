ENTRY(entry)
OUTPUT_FORMAT("binary")
addr = 0x00000500;

SECTIONS
{
    . = addr;

    .entry :
    {
        __entry_section = .; *(.entry)
    }
    .text :
    {
        __text_section = .; *(.text)
    }
    .data :
    {
        __data_section = .; *(.data)
    }
    .rodata :
    {
        __rodata_section = .; *(.rodata)
    }
    .bss :
    {
        __bss_section = .; *(.bss)
    }

    __end = .;
}