#include <stdint.h>

/*
 * هندسة المؤقت المعماري العام لمعمارية ARMv8-A (ARMv8 Generic Timer)
 * يتم التحكم بالمؤقت مباشرة عبر مسجلات النظام (System Registers) بدون الحاجة لعناوين MMIO خارجية في نواة الـ virt.
 */

// تهيئة المؤقت المادي وتحديد الفاصل الزمني للنبضات (Interval Ticks)
void sovereign_timer_init(uint32_t interval_ticks) {
    // تعيين القيمة التنازلية للعداد في سجل cntp_tval_el0
    __asm__ __volatile__("msr cntp_tval_el0, %0" : : "r"((uint64_t)interval_ticks));
    
    // تفعيل المؤقت وإلغاء حظر المقاطعات عبر سجل التحكم cntp_ctl_el0 (بت التفعيل = 1، بت الحظر = 0)
    uint64_t ctl_enable = 1;
    __asm__ __volatile__("msr cntp_ctl_el0, %0" : : "r"(ctl_enable));
    
    // مزامنة خطوط الأنابيب السيليكونية لضمان سريان التعليمات فوراً
    __asm__ __volatile__("isb" : : : "memory");
}

// قراءة العداد الفيزيائي العام مباشرة بدقة نانوية مطلقة (Physical Count Register)
uint64_t sovereign_get_system_cycles(void) {
    uint64_t cycles;
    __asm__ __volatile__("mrs %0, cntpct_el0" : "=r"(cycles));
    return cycles;
}

// إعادة تدوير وضبط المؤقت عند خدمة المقاطعة (ISR Refresh) لاستمرار النبضات الدورية
void sovereign_timer_reload(uint32_t interval_ticks) {
    __asm__ __volatile__("msr cntp_tval_el0, %0" : : "r"((uint64_t)interval_ticks));
    __asm__ __volatile__("isb" : : : "memory");
}
