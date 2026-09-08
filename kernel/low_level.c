#include <stdint.h>
#include <stddef.h>

// قراءة عداد الأداء المادي للمعالج (Virtual Timer Counter) مباشرة من سجلات عتاد ARM64 بدقة دورات الساعة
__attribute__((always_inline)) static inline uint64_t read_hardware_counter(void) {
    uint64_t val;
    __asm__ volatile("mrs %0, cntvct_el0" : "=r" (val));
    return val;
}

// تنفيذ استدعاء نظام خامي (Raw Syscall) عبر مقاطعة النظام (SVC #0) لعزل بيئة التشغيل عن أي مكتبات قياسية
__attribute__((always_inline)) static inline long raw_sys_write(int fd, const void *buf, size_t count) {
    register long x8 __asm__("x8") = 64; // رقم استدعاء النظام write في معمارية AArch64
    register long x0 __asm__("x0") = fd;
    register long x1 __asm__("x1") = (long)buf;
    register long x2 __asm__("x2") = (long)count;

    __asm__ volatile(
        "svc #0"
        : "+r" (x0)
        : "r" (x8), "r" (x1), "r" (x2)
        : "memory", "cc"
    );
    return x0;
}

// نقطة التقاط القياس الأولي المدمجة لبيئة الـ Freestanding
void low_level_kernel_entry(void) {
    uint64_t start_cycles = read_hardware_counter();
    
    const char *msg = "[Sovereign-NEON-Engine]: Direct Hardware Access & Raw Syscall Active\n";
    raw_sys_write(1, msg, 70);

    uint64_t end_cycles = read_hardware_counter();
    (void)(end_cycles - start_cycles);
}
