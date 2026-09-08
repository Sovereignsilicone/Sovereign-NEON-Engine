.global _start
.extern main

.section .text
_start:
    // تهيئة مؤشر المكدس الأساسي (Stack Pointer) للنواة
    ldr x0, =stack_top
    mov sp, x0

    // الانتقال أو القفز إلى نواة الـ C الرئيسية
    bl main

_hang:
    wfi
    b _hang

/*
 * روتين حفظ السياق (Context Save)
 * يقوم بحفظ مسجلات المعالج العامة (X0-X30) ومؤشر المكدس وحالة التنفيذ عند وقوع المقاطعة
 */
.global sovereign_context_switch_save
sovereign_context_switch_save:
    // حجز مساحة في المكدس لتخزين مسجلات الحالة والعامة
    sub sp, sp, #272
    
    // حفظ المسجلات العامة X0 إلى X30 بشكل أزواج
    stp x0, x1, [sp, #0]
    stp x2, x3, [sp, #16]
    stp x4, x5, [sp, #32]
    stp x6, x7, [sp, #48]
    stp x8, x9, [sp, #64]
    stp x10, x11, [sp, #80]
    stp x12, x13, [sp, #96]
    stp x14, x15, [sp, #112]
    stp x16, x17, [sp, #128]
    stp x18, x19, [sp, #144]
    stp x20, x21, [sp, #160]
    stp x22, x23, [sp, #176]
    stp x24, x25, [sp, #192]
    stp x26, x27, [sp, #208]
    stp x28, x29, [sp, #224]
    
    // حفظ مسجل الارتباط (LR) ومؤشر المكدس الفعلي
    mov x0, lr
    mrs x1, spsr_el1
    stp x0, x1, [sp, #240]
    
    ret

/*
 * روتين استعادة السياق (Context Restore)
 * استرجاع كافة المسجلات وحالة التدفق للمهمة التالية بسلاسة نانوية مطلقة
 */
.global sovereign_context_switch_restore
sovereign_context_switch_restore:
    // استعادة سجل الارتباط وحالة المعالج
    ldp x0, x1, [sp, #240]
    mov lr, x0
    msr spsr_el1, x1
    
    // استعادة المسجلات العامة X0 إلى X30
    ldp x28, x29, [sp, #224]
    ldp x26, x27, [sp, #208]
    ldp x24, x25, [sp, #192]
    ldp x22, x23, [sp, #176]
    ldp x20, x21, [sp, #160]
    ldp x18, x19, [sp, #144]
    ldp x16, x17, [sp, #128]
    ldp x14, x15, [sp, #112]
    ldp x12, x13, [sp, #96]
    ldp x10, x11, [sp, #80]
    ldp x8, x9, [sp, #64]
    ldp x6, x7, [sp, #48]
    ldp x4, x5, [sp, #32]
    ldp x2, x3, [sp, #16]
    ldp x0, x1, [sp, #0]
    
    // تحرير مساحة المكدس والعودة لسياق التنفيذ
    add sp, sp, #272
    eret

/*
 * إعدادات السيليكون السيادي ومستويات الامتياز العالية (EL3 / TrustZone & MTE Initialization)
 */
.global sovereign_security_init
sovereign_security_init:
    // تهيئة بيئة التشغيل الآمنة وضبط سجل التحكم في مستوى الامتياز الأعلى SCR_EL3
    // السماح بالوصول إلى عالم Non-secure وتفعيل نظام AArch64
    mov     x0, #(1 << 10)     // RW bit (Execution state for lower level is AArch64)
    orr     x0, x0, #(1 << 0)  // NS bit (Non-secure EL0/EL1)
    msr     scr_el3, x0

    // تهيئة بيئة Hypervisor والتحكم في المحاكاة الافتراضية عبر HCR_EL2
    mov     x0, #(1 << 31)     // RW bit (EL1 is AArch64)
    msr     hcr_el2, x0

    isb
    ret

.section .bss
.align 16
stack_bottom:
.space 16384 // تخصيص 16 كيلوبايت لمكدس الإقلاع الأولي
stack_top:
