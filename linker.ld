ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 64M
}

SECTIONS
{
    . = 0x40000000;
    
    .text : {
        KEEP(*(.text.boot))
        *(.text .text.*)
    } > RAM

    .rodata : {
        *(.rodata .rodata.*)
    } > RAM

    .data : {
        *(.data .data.*)
    } > RAM

    .bss : {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    } > RAM

    . = ALIGN(64);
    .stack : {
        __stack_bottom = .;
        . += 0x80000; /* 512KB Sovereign Core Stack */
        _stack_top = .;
    } > RAM
}
