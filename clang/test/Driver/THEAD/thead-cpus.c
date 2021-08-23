// Check target CPUs are correctly passed.

// mcpu with default march
// RUN: %clang -target riscv64 -### -c %s 2>&1 -mcpu=c906 | FileCheck -check-prefix=MCPU-C906 %s
// MCPU-C906: "-nostdsysteminc" "-target-cpu" "c906"
// MCPU-C906: "-target-feature" "+m" "-target-feature" "+a" "-target-feature" "+c"
// MCPU-C906: "-target-feature" "+xtheadc"
// MCPU-C906: "-target-abi" "lp64"

// RUN: %clang -target riscv64 -### -c %s 2>&1 -mcpu=c906fd | FileCheck -check-prefix=MCPU-C906FD %s
// MCPU-C906FD: "-nostdsysteminc" "-target-cpu" "c906fd"
// MCPU-C906FD: "-target-feature" "+m" "-target-feature" "+a" "-target-feature" "+f" "-target-feature" "+d"
// MCPU-C906FD: "-target-feature" "+c" "-target-feature" "+xtheadc"
// MCPU-C906FD: "-target-abi" "lp64d"

// RUN: %clang -target riscv64 -### -c %s 2>&1 -mcpu=c906fd -mtune=c906 | FileCheck -check-prefix=MTUNE-C906FD-MCPU-C906 %s
// MTUNE-C906FD-MCPU-C906: "-target-cpu" "c906fd"
// MTUNE-C906FD-MCPU-C906-SAME: "-target-feature" "+m" "-target-feature" "+a"
// MTUNE-C906FD-MCPU-C906-SAME: "-target-feature" "+f" "-target-feature" "+d"
// MTUNE-C906FD-MCPU-C906-SAME: "-target-feature" "+c" "-target-feature" "+xtheadc"
// MTUNE-C906FD-MCPU-C906-SAME: "-tune-cpu" "c906"
