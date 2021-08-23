//==- THEADSchedC906.td - T-HEAD C906 Scheduling Definitions -*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// ===---------------------------------------------------------------------===//
// The following definitions describe the simpler per-operand machine model.
// This works with MachineScheduler. See MCSchedule.h for details.

// C906 machine model for scheduling and other instruction cost heuristics.
def THEADC906Model : SchedMachineModel {
  let MicroOpBufferSize = 0; // C906 is in-order.
  let IssueWidth = 1;        // 1 micro-op is dispatched per cycle.
  let LoadLatency = 2;
  let MispredictPenalty = 2;
  let UnsupportedFeatures = [HasStdExtV, HasStdExtZvamo, HasStdExtZvlsseg];
}

//===----------------------------------------------------------------------===//
// Define each kind of processor resource and number available.

// Modeling each pipeline as a ProcResource using the BufferSize = 1 since
// C906 is in-order.

let BufferSize = 1 in {
def C906UnitALU        : ProcResource<1>;  // Int ALU
def C906UnitBJU        : ProcResource<1>;  // Branch
def C906UnitMUL        : ProcResource<1>;  // Int Multiply
def C906UnitDIV        : ProcResource<1>;  // Int Div
def C906UnitLSU        : ProcResource<1>;  // Load/Store
def C906UnitVFPU       : ProcResource<1>;  // FP/Vector ALU
def C906UnitCP0        : ProcResource<1>;  // CSR
}

//===----------------------------------------------------------------------===//

let SchedModel = THEADC906Model in {

// Branching
def : WriteRes<WriteJmp, [C906UnitBJU]>;
def : WriteRes<WriteJal, [C906UnitBJU]>;
def : WriteRes<WriteJalr, [C906UnitBJU]>;
def : WriteRes<WriteJmpReg, [C906UnitBJU]>;

// Integer arithmetic and logic
def : WriteRes<WriteIALU32, [C906UnitALU]>;
def : WriteRes<WriteIALU, [C906UnitALU]>;
def : WriteRes<WriteShiftImm32, [C906UnitALU]>;
def : WriteRes<WriteShiftImm, [C906UnitALU]>;
def : WriteRes<WriteShiftReg32, [C906UnitALU]>;
def : WriteRes<WriteShiftReg, [C906UnitALU]>;

// Integer multiplication
let Latency = 3 in {
def : WriteRes<WriteIMul, [C906UnitMUL]>;
def : WriteRes<WriteIMula, [C906UnitMUL]>;
def : WriteRes<WriteIMula32, [C906UnitMUL]>;
def : WriteRes<WriteIMula16, [C906UnitMUL]>;
def : WriteRes<WriteIMul32, [C906UnitMUL]>;
}

// Integer division
// Worst case latency is used.
def : WriteRes<WriteIDiv32, [C906UnitDIV]> {
  let Latency = 36;
  let ResourceCycles = [36];
}
def : WriteRes<WriteIDiv, [C906UnitDIV]> {
  let Latency = 36;
  let ResourceCycles = [36];
}

// Memory
def : WriteRes<WriteSTB, [C906UnitLSU]>;
def : WriteRes<WriteSTH, [C906UnitLSU]>;
def : WriteRes<WriteSTW, [C906UnitLSU]>;
def : WriteRes<WriteSTD, [C906UnitLSU]>;
def : WriteRes<WriteFST32, [C906UnitLSU]>;
def : WriteRes<WriteFST64, [C906UnitLSU]>;

let Latency = 2 in {
def : WriteRes<WriteLDB, [C906UnitLSU]>;
def : WriteRes<WriteLDH, [C906UnitLSU]>;
def : WriteRes<WriteLDW, [C906UnitLSU]>;
def : WriteRes<WriteLDWU, [C906UnitLSU]>;
def : WriteRes<WriteLDD, [C906UnitLSU]>;
def : WriteRes<WriteFLD32, [C906UnitLSU]>;
def : WriteRes<WriteFLD64, [C906UnitLSU]>;

// Atomic memory
def : WriteRes<WriteAtomicW, [C906UnitLSU]>;
def : WriteRes<WriteAtomicD, [C906UnitLSU]>;

def : WriteRes<WriteAtomicLDW, [C906UnitLSU]>;
def : WriteRes<WriteAtomicLDD, [C906UnitLSU]>;
}

def : WriteRes<WriteAtomicSTW, [C906UnitLSU]>;
def : WriteRes<WriteAtomicSTD, [C906UnitLSU]>;

// Single precision.
let Latency = 3 in {
def : WriteRes<WriteFALU32, [C906UnitVFPU]>;
def : WriteRes<WriteFSGNJ32, [C906UnitVFPU]>;
def : WriteRes<WriteFMinMax32, [C906UnitVFPU]>;
}

// Double precision
let Latency = 4 in {
def : WriteRes<WriteFALU64, [C906UnitVFPU]>;
def : WriteRes<WriteFSGNJ64, [C906UnitVFPU]>;
def : WriteRes<WriteFMinMax64, [C906UnitVFPU]>;
}

// Conversions
let Latency = 3 in {
def : WriteRes<WriteFCvtI32ToF32, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtI32ToF64, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtI64ToF32, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtI64ToF64, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtF32ToF64, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtF64ToF32, [C906UnitVFPU]>;

def : WriteRes<WriteFMovI32ToF32, [C906UnitVFPU]>;
def : WriteRes<WriteFMovI64ToF64, [C906UnitVFPU]>;
}

let Latency = 4 in {
def : WriteRes<WriteFCvtF32ToI32, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtF32ToI64, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtF64ToI32, [C906UnitVFPU]>;
def : WriteRes<WriteFCvtF64ToI64, [C906UnitVFPU]>;

def : WriteRes<WriteFCmp32, [C906UnitVFPU]>;
def : WriteRes<WriteFCmp64, [C906UnitVFPU]>;

def : WriteRes<WriteFMovF32ToI32, [C906UnitVFPU]>;
def : WriteRes<WriteFMovF64ToI64, [C906UnitVFPU]>;

def : WriteRes<WriteFClass32, [C906UnitVFPU]>;
def : WriteRes<WriteFClass64, [C906UnitVFPU]>;
}

// FP multiplication
let Latency = 3 in {
def : WriteRes<WriteFMul32, [C906UnitVFPU]>;
}

let Latency = 4 in {
def : WriteRes<WriteFMA32, [C906UnitVFPU]>;
}

let Latency = 4 in {
def : WriteRes<WriteFMul64, [C906UnitVFPU]>;
}

let Latency = 5 in {
def : WriteRes<WriteFMA64, [C906UnitVFPU]>;
}

// FP division/square root
// FP division and square root unit on C906 is not pipelined,
// so set resource cycles to latency.
let Latency = 18, ResourceCycles = [18] in {
def : WriteRes<WriteFDiv32, [C906UnitVFPU]>;
def : WriteRes<WriteFSqrt32, [C906UnitVFPU]>;
}

let Latency = 33, ResourceCycles = [33] in {
def : WriteRes<WriteFDiv64, [C906UnitVFPU]>;
def : WriteRes<WriteFSqrt64, [C906UnitVFPU]>;
}

// Others
let Latency = 0, ResourceCycles = [0] in {
def : WriteRes<WriteCSR, [C906UnitCP0]>;
def : WriteRes<WriteFence, [C906UnitCP0]>;
}

def : WriteRes<WriteNop, []>;


// T-HEAD Extension
def : WriteRes<WriteEXT, [C906UnitALU]>;
def : WriteRes<WriteEXTU, [C906UnitALU]>;
def : WriteRes<WriteFF0, [C906UnitALU]>;
def : WriteRes<WriteFF1, [C906UnitALU]>;
let NumMicroOps = 0 in
def : WriteRes<WriteMemBase, [C906UnitALU]>;
def : WriteRes<WriteIMOVC, [C906UnitALU]>;
def : WriteRes<WriteREVW8, [C906UnitALU]>;
def : WriteRes<WriteTST, [C906UnitALU]>;
def : WriteRes<WriteTSTNBZ, [C906UnitALU]>;


//===----------------------------------------------------------------------===//
// Instruction SchedWrite and SchedRead rewrite

def : InstRW<[WriteIALU], (instrs COPY)>;

def : InstRW<[WriteAtomicW, WriteFence, ReadAtomicWA, ReadAtomicWD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_W"))>;
def : InstRW<[WriteAtomicD, WriteFence, ReadAtomicDA, ReadAtomicDD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_D"))>;

def : InstRW<[WriteAtomicLDW, WriteFence, ReadAtomicLDW],
  (instrs LR_W_AQ)>;
def : InstRW<[WriteAtomicLDD, WriteFence, ReadAtomicLDD],
  (instrs LR_D_AQ)>;
def : InstRW<[WriteFence, WriteAtomicLDW, WriteFence, ReadAtomicLDW],
  (instrs LR_W_AQ_RL)>;
def : InstRW<[WriteFence, WriteAtomicLDD, WriteFence, ReadAtomicLDD],
  (instrs LR_D_AQ_RL)>;
def : InstRW<[WriteAtomicSTW, WriteFence, ReadAtomicSTW, ReadAtomicSTW],
  (instrs SC_W_RL)>;
def : InstRW<[WriteAtomicSTD, WriteFence, ReadAtomicSTD, ReadAtomicSTD],
  (instrs SC_D_RL)>;
def : InstRW<[WriteFence, WriteAtomicSTW,
              WriteFence, ReadAtomicSTW, ReadAtomicSTW], (instrs SC_W_AQ_RL)>;
def : InstRW<[WriteFence, WriteAtomicSTD,
              WriteFence, ReadAtomicSTD, ReadAtomicSTD], (instrs SC_D_AQ_RL)>;

//===----------------------------------------------------------------------===//
// Bypass and advance
def : ReadAdvance<ReadJmp, 0>;
def : ReadAdvance<ReadJalr, 0>;
def : ReadAdvance<ReadCSR, 0>;
def : ReadAdvance<ReadStoreData, 2,
  [WriteLDB, WriteLDH, WriteLDW, WriteLDWU, WriteLDD, WriteFLD32, WriteFLD64]>;
def : ReadAdvance<ReadMemBase, 0>;
def : ReadAdvance<ReadIALU, 0>;
def : ReadAdvance<ReadIALU32, 0>;
def : ReadAdvance<ReadShiftImm, 0>;
def : ReadAdvance<ReadShiftImm32, 0>;
def : ReadAdvance<ReadShiftReg, 0>;
def : ReadAdvance<ReadShiftReg32, 0>;
def : ReadAdvance<ReadIDiv, 0>;
def : ReadAdvance<ReadIDiv32, 0>;
def : ReadAdvance<ReadIMul, 0>;
def : ReadAdvance<ReadIMul32, 0>;
def : ReadAdvance<ReadAtomicWA, 0>;
def : ReadAdvance<ReadAtomicWD, 0>;
def : ReadAdvance<ReadAtomicDA, 0>;
def : ReadAdvance<ReadAtomicDD, 0>;
def : ReadAdvance<ReadAtomicLDW, 0>;
def : ReadAdvance<ReadAtomicLDD, 0>;
def : ReadAdvance<ReadAtomicSTW, 0>;
def : ReadAdvance<ReadAtomicSTD, 0>;
def : ReadAdvance<ReadFMemBase, 0>;
def : ReadAdvance<ReadFALU32, 0>;
def : ReadAdvance<ReadFALU64, 0>;
def : ReadAdvance<ReadFMul32, 0>;
def : ReadAdvance<ReadFMA32, 0>;
def : ReadAdvance<ReadFMul64, 0>;
def : ReadAdvance<ReadFMA64, 0>;
def : ReadAdvance<ReadFDiv32, 0>;
def : ReadAdvance<ReadFDiv64, 0>;
def : ReadAdvance<ReadFSqrt32, 0>;
def : ReadAdvance<ReadFSqrt64, 0>;
def : ReadAdvance<ReadFCmp32, 0>;
def : ReadAdvance<ReadFCmp64, 0>;
def : ReadAdvance<ReadFSGNJ32, 0>;
def : ReadAdvance<ReadFSGNJ64, 0>;
def : ReadAdvance<ReadFMinMax32, 0>;
def : ReadAdvance<ReadFMinMax64, 0>;
def : ReadAdvance<ReadFCvtF32ToI32, 0>;
def : ReadAdvance<ReadFCvtF32ToI64, 0>;
def : ReadAdvance<ReadFCvtF64ToI32, 0>;
def : ReadAdvance<ReadFCvtF64ToI64, 0>;
def : ReadAdvance<ReadFCvtI32ToF32, 0>;
def : ReadAdvance<ReadFCvtI32ToF64, 0>;
def : ReadAdvance<ReadFCvtI64ToF32, 0>;
def : ReadAdvance<ReadFCvtI64ToF64, 0>;
def : ReadAdvance<ReadFCvtF32ToF64, 0>;
def : ReadAdvance<ReadFCvtF64ToF32, 0>;
def : ReadAdvance<ReadFMovF32ToI32, 0>;
def : ReadAdvance<ReadFMovI32ToF32, 0>;
def : ReadAdvance<ReadFMovF64ToI64, 0>;
def : ReadAdvance<ReadFMovI64ToF64, 0>;
def : ReadAdvance<ReadFClass32, 0>;
def : ReadAdvance<ReadFClass64, 0>;

// T-HEAD Extension
def : ReadAdvance<ReadEXT, 0>;
def : ReadAdvance<ReadEXTU, 0>;
def : ReadAdvance<ReadFF0, 0>;
def : ReadAdvance<ReadFF1, 0>;
def : ReadAdvance<ReadIMOVC, 0>;
def : ReadAdvance<ReadREVW8, 0>;
def : ReadAdvance<ReadTST, 0>;
def : ReadAdvance<ReadTSTNBZ, 0>;
def : ReadAdvance<ReadIMula, 0>;
def : ReadAdvance<ReadIMula32, 0>;
def : ReadAdvance<ReadIMula16, 0>;

def : ReadAdvance<ReadFMemOffset, 0>;
def : ReadAdvance<ReadMemOffset, 0>;

//===----------------------------------------------------------------------===//
// Unsupported extensions
defm : UnsupportedSchedV;
defm : UnsupportedSchedZba;
defm : UnsupportedSchedZbb;
defm : UnsupportedSchedZfh;

// Include the resource requirements of extension instructions.
include "THEAD/THEADInstrResources.td"
}
