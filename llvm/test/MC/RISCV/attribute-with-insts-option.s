## Test -mattr= option effects.
## We do not provide '.attribute arch'.

# RUN: llvm-mc -triple riscv32 -filetype=obj -mattr=+m -mattr=+a -mattr=+d -mattr=+c %s \
# RUN:   | llvm-objdump --triple=riscv32 -d -M no-aliases - \
# RUN:   | FileCheck -check-prefix=CHECK-INST %s

# RUN: llvm-mc -triple riscv64 -filetype=obj -mattr=+m -mattr=+a -mattr=+d -mattr=+c %s \
# RUN:   | llvm-objdump --triple=riscv64 -d -M no-aliases - \
# RUN:   | FileCheck -check-prefix=CHECK-INST %s

# CHECK-INST: lr.w t0, (t1)
lr.w t0, (t1)

# CHECK-INST: c.addi a3, -32
c.addi a3, -32

# CHECK-INST: fmadd.d fa0, fa1, fa2, fa3, dyn
fmadd.d f10, f11, f12, f13, dyn

# CHECK-INST: fmadd.s fa0, fa1, fa2, fa3, dyn
fmadd.s f10, f11, f12, f13, dyn

# CHECK-INST: addi ra, sp, 2
addi ra, sp, 2

# CHECK-INST: mul a4, ra, s0
mul a4, ra, s0
