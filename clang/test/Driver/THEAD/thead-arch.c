// Testing THEAD specific arch and extensions.

// RUN: %clang -target riscv64-unknown-unknown -march=rv32imacxtheade -### %s \
// RUN: -fsyntax-only 2>&1 | FileCheck -check-prefix=THEADE %s

// THEADE: "-target-feature" "+m" "-target-feature" "+a" "-target-feature" "+c"
// THEADE-SAME: "-target-feature" "+xtheade"