# RUN: llvm-mc %s -triple=riscv64 -mattr=+d -mattr=+xtheadc -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc -filetype=obj -triple=riscv64 -mattr=+d -mattr=+xtheadc < %s \
# RUN:     | llvm-objdump --mattr=+d --mattr=+xtheadc -M no-aliases -d -r - \
# RUN:     | FileCheck --check-prefix=CHECK-ASM-AND-OBJ %s

# CHECK-ASM-AND-OBJ: dcache.call
# CHECK-ASM: encoding: [0x0b,0x00,0x10,0x00]
dcache.call

# CHECK-ASM-AND-OBJ: dcache.ciall
# CHECK-ASM: encoding: [0x0b,0x00,0x30,0x00]
dcache.ciall

# CHECK-ASM-AND-OBJ: dcache.cipa t0
# CHECK-ASM: encoding: [0x0b,0x80,0xb2,0x02]
dcache.cipa t0

# CHECK-ASM-AND-OBJ: dcache.cisw t0
# CHECK-ASM: encoding: [0x0b,0x80,0x32,0x02]
dcache.cisw t0

# CHECK-ASM-AND-OBJ: dcache.civa t0
# CHECK-ASM: encoding: [0x0b,0x80,0x72,0x02]
dcache.civa t0

# CHECK-ASM-AND-OBJ: dcache.cpa t0
# CHECK-ASM: encoding: [0x0b,0x80,0x92,0x02]
dcache.cpa t0

# CHECK-ASM-AND-OBJ: dcache.cpal1 t0
# CHECK-ASM: encoding: [0x0b,0x80,0x82,0x02]
dcache.cpal1 t0

# CHECK-ASM-AND-OBJ: dcache.cva t0
# CHECK-ASM: encoding: [0x0b,0x80,0x52,0x02]
dcache.cva t0

# CHECK-ASM-AND-OBJ: dcache.cval1 t0
# CHECK-ASM: encoding: [0x0b,0x80,0x42,0x02]
dcache.cval1 t0

# CHECK-ASM-AND-OBJ: dcache.ipa t0
# CHECK-ASM: encoding: [0x0b,0x80,0xa2,0x02]
dcache.ipa t0

# CHECK-ASM-AND-OBJ: dcache.isw t0
# CHECK-ASM: encoding: [0x0b,0x80,0x22,0x02]
dcache.isw t0

# CHECK-ASM-AND-OBJ: dcache.iva t0
# CHECK-ASM: encoding: [0x0b,0x80,0x62,0x02]
dcache.iva t0

# CHECK-ASM-AND-OBJ: dcache.csw t0
# CHECK-ASM: encoding: [0x0b,0x80,0x12,0x02]
dcache.csw t0

# CHECK-ASM-AND-OBJ: dcache.iall
# CHECK-ASM: encoding: [0x0b,0x00,0x20,0x00]
dcache.iall

# CHECK-ASM-AND-OBJ: icache.iall
# CHECK-ASM: encoding: [0x0b,0x00,0x00,0x01]
icache.iall

# CHECK-ASM-AND-OBJ: icache.ialls
# CHECK-ASM: encoding: [0x0b,0x00,0x10,0x01]
icache.ialls

# CHECK-ASM-AND-OBJ: icache.ipa t0
# CHECK-ASM: encoding: [0x0b,0x80,0x82,0x03]
icache.ipa t0

# CHECK-ASM-AND-OBJ: icache.iva t0
# CHECK-ASM: encoding: [0x0b,0x80,0x02,0x03]
icache.iva t0

# CHECK-ASM-AND-OBJ: l2cache.call
# CHECK-ASM: encoding: [0x0b,0x00,0x50,0x01]
l2cache.call

# CHECK-ASM-AND-OBJ: l2cache.ciall
# CHECK-ASM: encoding: [0x0b,0x00,0x70,0x01]
l2cache.ciall

# CHECK-ASM-AND-OBJ: l2cache.iall
# CHECK-ASM: encoding: [0x0b,0x00,0x60,0x01]
l2cache.iall

# CHECK-ASM-AND-OBJ: sync
# CHECK-ASM: encoding: [0x0b,0x00,0x80,0x01]
sync

# CHECK-ASM-AND-OBJ: sync.i
# CHECK-ASM: encoding: [0x0b,0x00,0xa0,0x01]
sync.i

# CHECK-ASM-AND-OBJ: sync.is
# CHECK-ASM: encoding: [0x0b,0x00,0xb0,0x01]
sync.is

# CHECK-ASM-AND-OBJ: sync.s
# CHECK-ASM: encoding: [0x0b,0x00,0x90,0x01]
sync.s

# CHECK-ASM-AND-OBJ: addsl t0, t1, t2, 3
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x06]
addsl t0, t1, t2, 3

# CHECK-ASM-AND-OBJ: mula t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x20]
mula t0, t1, t2

# CHECK-ASM-AND-OBJ: mulah t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x28]
mulah t0, t1, t2

# CHECK-ASM-AND-OBJ: mulaw t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x24]
mulaw t0, t1, t2

# CHECK-ASM-AND-OBJ: muls t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x22]
muls t0, t1, t2

# CHECK-ASM-AND-OBJ: mulsh t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x2a]
mulsh t0, t1, t2

# CHECK-ASM-AND-OBJ: mulsw t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x26]
mulsw t0, t1, t2

# CHECK-ASM-AND-OBJ: mveqz t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x40]
mveqz t0, t1, t2

# CHECK-ASM-AND-OBJ: mvnez t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x12,0x73,0x42]
mvnez t0, t1, t2

# CHECK-ASM-AND-OBJ: srri t0, t1, 6
# CHECK-ASM: encoding: [0x8b,0x12,0x63,0x10]
srri t0, t1, 6

# CHECK-ASM-AND-OBJ: srriw t0, t1, 6
# CHECK-ASM: encoding: [0x8b,0x12,0x63,0x14]
srriw t0, t1, 6

# CHECK-ASM-AND-OBJ: ext t0, t1, 6, 5
# CHECK-ASM: encoding: [0x8b,0x22,0x53,0x18]
ext t0, t1, 6, 5

# CHECK-ASM-AND-OBJ: extu t0, t1, 6, 5
# CHECK-ASM: encoding: [0x8b,0x32,0x53,0x18]
extu t0, t1, 6, 5

# CHECK-ASM-AND-OBJ: ff0 t0, t1
# CHECK-ASM: encoding: [0x8b,0x12,0x03,0x84]
ff0 t0, t1

# CHECK-ASM-AND-OBJ: ff1 t0, t1
# CHECK-ASM: encoding: [0x8b,0x12,0x03,0x86]
ff1 t0, t1

# CHECK-ASM-AND-OBJ: rev t0, t1
# CHECK-ASM: encoding: [0x8b,0x12,0x03,0x82]
rev t0, t1

# CHECK-ASM-AND-OBJ: revw t0, t1
# CHECK-ASM: encoding: [0x8b,0x12,0x03,0x90]
revw t0, t1

# CHECK-ASM-AND-OBJ: tst t0, t1, 6
# CHECK-ASM: encoding: [0x8b,0x12,0x63,0x88]
tst t0, t1, 6

# CHECK-ASM-AND-OBJ: tstnbz t0, t1
# CHECK-ASM: encoding: [0x8b,0x12,0x03,0x80]
tstnbz t0, t1

# CHECK-ASM-AND-OBJ: flrw ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x60,0x73,0x44]
flrw ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: flurw ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x60,0x73,0x54]
flurw ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: fsrw ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x70,0x73,0x44]
fsrw ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: fsurw ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x70,0x73,0x54]
fsurw ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: flrd ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x60,0x73,0x64]
flrd ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: flurd ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x60,0x73,0x74]
flurd ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: fsrd ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x70,0x73,0x64]
fsrd ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: fsurd ft1, t1, t2, 2
# CHECK-ASM: encoding: [0x8b,0x70,0x73,0x74]
fsurd ft1, t1, t2, 2

# CHECK-ASM-AND-OBJ: lbia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x1c]
lbia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lbib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x0c]
lbib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lhia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x3c]
lhia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lhib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x2c]
lhib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lwia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x5c]
lwia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lwib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x4c]
lwib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: ldia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x7c]
ldia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: ldib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x6c]
ldib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lbuia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x9c]
lbuia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lbuib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0x8c]
lbuib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lhuia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0xbc]
lhuia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lhuib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0xac]
lhuib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lwuia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0xdc]
lwuia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lwuib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x42,0x53,0xcc]
lwuib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: sbia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x1c]
sbia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: sbib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x0c]
sbib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: shia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x3c]
shia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: shib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x2c]
shib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: swia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x5c]
swia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: swib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x4c]
swib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: sdia t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x7c]
sdia t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: sdib t0, (t1), 5, 2
# CHECK-ASM: encoding: [0x8b,0x52,0x53,0x6c]
sdib t0, (t1), 5, 2

# CHECK-ASM-AND-OBJ: lrb t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x05]
lrb t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lrh t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x25]
lrh t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lrw t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x45]
lrw t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lrd t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x65]
lrd t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lrbu t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x85]
lrbu t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lrhu t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0xa5]
lrhu t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lrwu t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0xc5]
lrwu t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurb t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x15]
lurb t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurh t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x35]
lurh t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurw t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x55]
lurw t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurd t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x75]
lurd t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurbu t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0x95]
lurbu t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurhu t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0xb5]
lurhu t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lurwu t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xc3,0xc3,0xd5]
lurwu t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: srb t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x05]
srb t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: srh t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x25]
srh t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: srw t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x45]
srw t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: srd t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x65]
srd t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: surb t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x15]
surb t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: surh t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x35]
surh t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: surw t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x55]
surw t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: surd t1, t2, t3, 2
# CHECK-ASM: encoding: [0x0b,0xd3,0xc3,0x75]
surd t1, t2, t3, 2

# CHECK-ASM-AND-OBJ: lwd t1, t2, (t3), 2, 3
# CHECK-ASM: encoding: [0x0b,0x43,0x7e,0xe4]
lwd t1, t2, (t3), 2, 3

# CHECK-ASM-AND-OBJ: lwud t1, t2, (t3), 2, 3
# CHECK-ASM: encoding: [0x0b,0x43,0x7e,0xf4]
lwud t1, t2, (t3), 2, 3

# CHECK-ASM-AND-OBJ: ldd t1, t2, (t3), 2, 4
# CHECK-ASM: encoding: [0x0b,0x43,0x7e,0xfc]
ldd t1, t2, (t3), 2, 4

# CHECK-ASM-AND-OBJ: swd t1, t2, (t3), 2, 3
# CHECK-ASM: encoding: [0x0b,0x53,0x7e,0xe4]
swd t1, t2, (t3), 2, 3

# CHECK-ASM-AND-OBJ: sdd t1, t2, (t3), 2, 4
# CHECK-ASM: encoding: [0x0b,0x53,0x7e,0xfc]
sdd t1, t2, (t3), 2, 4


# RUN: not llvm-mc -triple=riscv64 -mattr=+d -mattr=+xtheadc -riscv-no-aliases -show-encoding \
# RUN:      --defsym=ERR=1 < %s 2>&1 | FileCheck %s

.ifdef ERR
lwd t1, t2, (t3), 2, 4  # CHECK: :[[#@LINE]]:22: error: operand must be constant 3
lwud t1, t2, (t3), 2, 4 # CHECK: :[[#@LINE]]:23: error: operand must be constant 3
ldd t1, t2, (t3), 2, 3  # CHECK: :[[#@LINE]]:22: error: operand must be constant 4
swd t1, t2, (t3), 2, 4  # CHECK: :[[#@LINE]]:22: error: operand must be constant 3
sdd t1, t2, (t3), 2, 3  # CHECK: :[[#@LINE]]:22: error: operand must be constant 4
.endif