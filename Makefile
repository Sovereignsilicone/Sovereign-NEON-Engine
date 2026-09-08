CC = clang
LD = ld.lld
OBJCOPY = llvm-objcopy
OBJDUMP = llvm-objdump

ARCH_FLAGS = --target=aarch64-none-elf -march=armv8.2-a+fp16+simd
CFLAGS = $(ARCH_FLAGS) -ffreestanding -nostdlib -O3 -Wall -Wextra -ffunction-sections -fdata-sections
LDFLAGS = -T linker.ld -nostdlib -Wl,--gc-sections -Wl,--build-id=none

BUILD_DIR = build
TARGET = sovereign_kernel

OBJS = $(BUILD_DIR)/startup.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/sovereign_neon_kernel.o $(BUILD_DIR)/timer.o

all: directories $(BUILD_DIR)/$(TARGET).bin

directories:
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/startup.o: startup.s
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.o: kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/sovereign_neon_kernel.o: sovereign_neon_kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/timer.o: timer.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJS) linker.ld
	$(CC) $(LDFLAGS) $(OBJS) -o $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

run: all
	qemu-system-aarch64 -M virt -cpu cortex-a57 -kernel $(BUILD_DIR)/$(TARGET).bin -nographic

dump: $(BUILD_DIR)/$(TARGET).elf
	$(OBJDUMP) -d $< > $(BUILD_DIR)/$(TARGET).asm

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all directories run dump clean
