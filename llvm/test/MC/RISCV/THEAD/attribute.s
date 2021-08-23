## Arch string without version.

# RUN: llvm-mc %s -triple=riscv32 -filetype=asm | FileCheck %s
# RUN: llvm-mc %s -triple=riscv64 -filetype=asm | FileCheck %s

.attribute arch, "rv64imafdcxtheadc"
# CHECK: attribute      5, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0_xtheadc1p0"
