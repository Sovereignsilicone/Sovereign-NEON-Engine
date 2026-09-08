.syntax unified
.arch armv8-a
.section .text.boot
.global _start

_start:
    // Vector Table Entries (Strict 128-byte alignment for AArch64 exceptions)
    b   reset_handler
    .balign 128
    b   serror_handler
    .balign 128
    b   sync_handler
    .balign 128
    b   irq_handler

reset_handler:
    // Ensure execution context is at EL3/EL2/EL1 and secure vector allocation
    mrs x0, CurrentEL
    lsr x0, x0, #2
    
    // Initialize Sovereign Stack Pointer per core
    ldr x0, =_stack_top
    mov sp, x0

    // Ultra-fast zeroing of .bss section for strict -ffreestanding runtime
    ldr x0, =__bss_start
    ldr x1, =__bss_end
    mov x2, #0

1:
    cmp x0, x1
    b.ge 2f
    strb w2, [x0], #1
    b 1b

2:
    // Hand over control directly to the core bare-metal C entry point
    bl main
    b .

serror_handler:
sync_handler:
irq_handler:
    b .
