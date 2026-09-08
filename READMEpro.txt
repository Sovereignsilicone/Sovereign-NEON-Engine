Sovereign-NEON-Engine
=====================

Bare-metal ARMv8-A framework for zero-copy NEON vectorization and hardware-level inference optimization.

Project Structure
-----------------
- startup.s              : Boot vector table and exception handling
- linker.ld              : Physical memory mapping and layout
- sovereign_memory.c     : Static heap and cache-line alignment utilities
- sovereign_neon_kernel.c: NEON-accelerated FP16 math and vector engine
- kernel.c               : Sovereign microkernel core entry
- Makefile               : Automated build and QEMU simulation pipeline

Developer Quickstart (Termux / Linux)
-------------------------------------
1. Clone the repository:
   git clone https://github.com/Sovereignsilicone/Sovereign-NEON-Engine.git
   cd Sovereign-NEON-Engine

2. Install toolchain and prerequisites (Clang, LLD, LLVM, QEMU):
   pkg update && pkg install clang lld llvm qemu-system-aarch64 git -y

3. Build the kernel binary:
   make

4. Run the kernel in the sovereign QEMU simulation environment:
   make run

5. Inspect assembly instructions and hardware code:
   make dump
