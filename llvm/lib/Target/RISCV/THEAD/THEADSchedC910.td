//==- THEADSchedC910.td - T-HEAD C910 Scheduling Definitions -*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// ===---------------------------------------------------------------------===//
// The following definitions describe the simpler per-operand machine model.
// This works with MachineScheduler. See MCSchedule.h for details.

// C910 machine model for scheduling and other instruction cost heuristics.
def THEADC910Model : SchedMachineModel {
  let IssueWidth = 3;        // 3 micro-op is dispatched per cycle.
  let LoadLatency = 3;
  let MispredictPenalty = 7;
  let UnsupportedFeatures = [HasStdExtV, HasStdExtZvamo, HasStdExtZvlsseg];
}

//===----------------------------------------------------------------------===//
// Define each kind of processor resource and number available.

// The C910 microarchitecure has 8 pipelines: Pipe0 - Pipe7.

let BufferSize = 8 in {
def C910Pipe0       : ProcResource<1>;
def C910Pipe1       : ProcResource<1>;
def C910Pipe2       : ProcResource<1>;
def C910Pipe5       : ProcResource<1>;
def C910Pipe6       : ProcResource<1>;
def C910Pipe7       : ProcResource<1>;
}

let BufferSize = 12 in {
def C910Pipe3       : ProcResource<1>;
def C910Pipe4       : ProcResource<1>;
}

let SchedModel = THEADC910Model in {
def C910Pipe0_1 : ProcResGroup<[C910Pipe0, C910Pipe1]>;
def C910Pipe6_7 : ProcResGroup<[C910Pipe6, C910Pipe7]>;
}

let BufferSize = 1 in {
def C910UnitALU        : ProcResource<1>;  // Int ALU
def C910UnitBJU        : ProcResource<1>;  // Branch
def C910UnitMUL        : ProcResource<1>;  // Int Multiply
def C910UnitDIV        : ProcResource<1>;  // Int Div
def C910UnitLSU        : ProcResource<1>;  // Load/Store
def C910UnitVFPU       : ProcResource<1>;  // FP/Vector ALU
def C910UnitCP0        : ProcResource<1>;  // CSR
def C910UnitSPECIAL    : ProcResource<1>;  // Auipc
}

//===----------------------------------------------------------------------===//

let SchedModel = THEADC910Model in {

// Branching
def : WriteRes<WriteJmp, [C910Pipe2, C910UnitBJU]>;
def : WriteRes<WriteJal, [C910Pipe2, C910UnitBJU]>;
def : WriteRes<WriteJalr, [C910Pipe2, C910UnitBJU]>;
def : WriteRes<WriteJmpReg, [C910Pipe2, C910UnitBJU]>;

// Integer arithmetic and logic
def : WriteRes<WriteIALU32, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteIALU, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteShiftImm32, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteShiftImm, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteShiftReg32, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteShiftReg, [C910Pipe0_1, C910UnitALU]>;

// Integer multiplication
let Latency = 4 in {
def : WriteRes<WriteIMul, [C910Pipe1, C910UnitMUL]>;
def : WriteRes<WriteIMula, [C910Pipe1, C910UnitMUL]>;
def : WriteRes<WriteIMula32, [C910Pipe1, C910UnitMUL]>;
def : WriteRes<WriteIMula16, [C910Pipe1, C910UnitMUL]>;
def : WriteRes<WriteIMul32, [C910Pipe1, C910UnitMUL]>;
}

// Integer division
// Worst case latency is used.
let Latency = 20 in {
def : WriteRes<WriteIDiv32, [C910Pipe0, C910UnitDIV]>;
def : WriteRes<WriteIDiv, [C910Pipe0, C910UnitDIV]>;
}

// Memory
def : WriteRes<WriteSTB, [C910Pipe4, C910Pipe5, C910UnitLSU]>;
def : WriteRes<WriteSTH, [C910Pipe4, C910Pipe5, C910UnitLSU]>;
def : WriteRes<WriteSTW, [C910Pipe4, C910Pipe5, C910UnitLSU]>;
def : WriteRes<WriteSTD, [C910Pipe4, C910Pipe5, C910UnitLSU]>;
def : WriteRes<WriteFST32, [C910Pipe4, C910Pipe5, C910UnitLSU]>;
def : WriteRes<WriteFST64, [C910Pipe4, C910Pipe5, C910UnitLSU]>;

let Latency = 3 in {
def : WriteRes<WriteLDB, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteLDH, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteLDW, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteLDWU, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteLDD, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteFLD32, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteFLD64, [C910Pipe3, C910UnitLSU]>;

// Atomic memory
def : WriteRes<WriteAtomicLDW, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteAtomicLDD, [C910Pipe3, C910UnitLSU]>;
}

// FIXME: AMO operation is treated as load?
let Latency = 3 in {
def : WriteRes<WriteAtomicW, [C910Pipe3, C910UnitLSU]>;
def : WriteRes<WriteAtomicD, [C910Pipe3, C910UnitLSU]>;
}

def : WriteRes<WriteAtomicSTW, [C910Pipe4, C910Pipe5, C910UnitLSU]>;
def : WriteRes<WriteAtomicSTD, [C910Pipe4, C910Pipe5, C910UnitLSU]>;

// Single precision.
let Latency = 3 in {
def : WriteRes<WriteFALU32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFSGNJ32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMinMax32, [C910Pipe6_7, C910UnitVFPU]>;

// Double precision
def : WriteRes<WriteFALU64, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFSGNJ64, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMinMax64, [C910Pipe6_7, C910UnitVFPU]>;
}

// Conversions
let Latency = 2 in {
def : WriteRes<WriteFCvtI32ToF32, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtI32ToF64, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtI64ToF32, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtI64ToF64, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtF32ToF64, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtF64ToF32, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtF32ToI32, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtF32ToI64, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtF64ToI32, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFCvtF64ToI64, [C910Pipe7, C910UnitVFPU]>;

def : WriteRes<WriteFMovI32ToF32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMovI64ToF64, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMovF32ToI32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMovF64ToI64, [C910Pipe6_7, C910UnitVFPU]>;

def : WriteRes<WriteFClass32, [C910Pipe7, C910UnitVFPU]>;
def : WriteRes<WriteFClass64, [C910Pipe7, C910UnitVFPU]>;

def : WriteRes<WriteFCmp32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFCmp64, [C910Pipe6_7, C910UnitVFPU]>;
}

// FP multiplication
let Latency = 4 in {
def : WriteRes<WriteFMul32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMul64, [C910Pipe6_7, C910UnitVFPU]>;
}

let Latency = 5 in {
def : WriteRes<WriteFMA32, [C910Pipe6_7, C910UnitVFPU]>;
def : WriteRes<WriteFMA64, [C910Pipe6_7, C910UnitVFPU]>;
}

// FP division/square root
let Latency = 10 in {
def : WriteRes<WriteFDiv32, [C910Pipe6, C910UnitVFPU]>;
def : WriteRes<WriteFSqrt32, [C910Pipe6, C910UnitVFPU]>;
}

let Latency = 17 in {
def : WriteRes<WriteFDiv64, [C910Pipe6, C910UnitVFPU]>;
def : WriteRes<WriteFSqrt64, [C910Pipe6, C910UnitVFPU]>;
}

// Others
let Latency = 0, ResourceCycles = [1, 0] in {
def : WriteRes<WriteCSR, [C910Pipe0, C910UnitCP0]>;
def : WriteRes<WriteFence, [C910Pipe4, C910UnitLSU]>;
}

def : WriteRes<WriteNop, []>;

// T-HEAD Extension
def : WriteRes<WriteEXT, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteEXTU, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteFF0, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteFF1, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteMemBase, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteIMOVC, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteREVW8, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteTST, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteTSTNBZ, [C910Pipe0_1, C910UnitALU]>;
def : WriteRes<WriteSPECIAL, [C910Pipe0, C910UnitSPECIAL]>;


//===----------------------------------------------------------------------===//
// Instruction SchedWrite and SchedRead rewrite

def : InstRW<[WriteIALU], (instrs COPY)>;

def : InstRW<[WriteSPECIAL, WriteJal], (instrs JAL)>;
def : InstRW<[WriteSPECIAL, WriteJalr, ReadJalr], (instrs JALR, C_JALR)>;
def : InstRW<[WriteSPECIAL], (instrs AUIPC)>;

def : InstRW<[WriteAtomicLDW, WriteIALU, WriteSTW, ReadAtomicWA, ReadAtomicWD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_W$"))>;
def : InstRW<[WriteAtomicLDD, WriteIALU, WriteSTD, ReadAtomicDA, ReadAtomicDD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_D$"))>;
def : InstRW<
  [WriteAtomicLDW, WriteIALU, WriteSTW, WriteFence, ReadAtomicWA, ReadAtomicWD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_W_AQ$"))>;
def : InstRW<
  [WriteAtomicLDD, WriteIALU, WriteSTD, WriteFence, ReadAtomicDA, ReadAtomicDD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_D_AQ$"))>;
def : InstRW<
  [WriteFence, WriteAtomicLDW, WriteIALU, WriteSTW, ReadAtomicWA, ReadAtomicWD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_W_RL$"))>;
def : InstRW<
  [WriteFence, WriteAtomicLDD, WriteIALU, WriteSTD, ReadAtomicDA, ReadAtomicDD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_D_RL$"))>;
def : InstRW<
  [WriteFence, WriteAtomicLDW, WriteIALU,
  WriteSTW, WriteFence, ReadAtomicWA, ReadAtomicWD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_W_AQ_RL$"))>;
def : InstRW<
  [WriteFence, WriteAtomicLDD, WriteIALU,
  WriteSTD, WriteFence, ReadAtomicDA, ReadAtomicDD],
  (instrs (instregex "AMO(ADD|AND|MAX|MAXU|MIN|MINU|OR|SWAP|XOR)_D_AQ_RL$"))>;

def : InstRW<[WriteAtomicLDW, WriteFence, ReadAtomicLDW],
  (instrs LR_W_AQ)>;
def : InstRW<[WriteAtomicLDD, WriteFence, ReadAtomicLDD],
  (instrs LR_D_AQ)>;
def : InstRW<[WriteFence, WriteAtomicLDW, WriteFence, ReadAtomicLDW],
  (instrs LR_W_AQ_RL)>;
def : InstRW<[WriteFence, WriteAtomicLDD, WriteFence, ReadAtomicLDD],
  (instrs LR_D_AQ_RL)>;
def : InstRW<[WriteFence, WriteAtomicSTW, ReadAtomicSTW, ReadAtomicSTW],
  (instrs SC_W_RL)>;
def : InstRW<[WriteFence, WriteAtomicSTD, ReadAtomicSTD, ReadAtomicSTD],
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
def : ReadAdvance<ReadStoreData, 0>;
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
def : ReadAdvance<ReadIMula, 3, [WriteIMula]>;
def : ReadAdvance<ReadIMula32, 3, [WriteIMula32]>;
def : ReadAdvance<ReadIMula16, 3, [WriteIMula16]>;

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
