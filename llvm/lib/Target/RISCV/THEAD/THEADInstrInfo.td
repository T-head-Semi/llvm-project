//===-- THEADInstrInfo.td - Target Description for THEAD ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the T-HEAD instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// T-HEAD specific DAG Nodes.
//===----------------------------------------------------------------------===//


def SDT_TDBLD : SDTypeProfile<2, 2,
  [SDTCisVT<0, i64>, SDTCisSameAs<0, 1>, SDTCisPtrTy<2>, SDTCisVT<3, i64>]>;
def SDT_TDBST : SDTypeProfile<0, 4,
  [SDTCisVT<0, i64>, SDTCisSameAs<0, 1>, SDTCisPtrTy<2>, SDTCisVT<3, i64>]>;

def TLWUD : SDNode<"RISCVISD::LWUD", SDT_TDBLD,
  [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def TLWD : SDNode<"RISCVISD::LWD", SDT_TDBLD,
  [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def TLDD : SDNode<"RISCVISD::LDD", SDT_TDBLD,
  [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def TSWD : SDNode<"RISCVISD::SWD", SDT_TDBST,
  [SDNPHasChain, SDNPMayStore, SDNPMemOperand]>;
def TSDD : SDNode<"RISCVISD::SDD", SDT_TDBST,
  [SDNPHasChain, SDNPMayStore, SDNPMemOperand]>;

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

def uimm2 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isUInt<2>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<2>;
  let DecoderMethod = "decodeUImmOperand<2>";
  let OperandType = "OPERAND_UIMM2";
  let OperandNamespace = "RISCVOp";
}

class ConstantAsmOperand<int suffix> : AsmOperandClass {
  let Name = "Constant_" # suffix;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def constant_3 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return Imm == 3;}]> {
  let ParserMatchClass = ConstantAsmOperand<3>;
  let OperandType = "OPERAND_CONST3";
  let OperandNamespace = "RISCVOp";
  let PrintMethod = "printConstant_3";
}

def constant_4 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return Imm == 4;}]> {
  let ParserMatchClass = ConstantAsmOperand<4>;
  let OperandType = "OPERAND_CONST4";
  let OperandNamespace = "RISCVOp";
  let PrintMethod = "printConstant_4";
}

def simm5_1_XFORM : SDNodeXForm<imm, [{
  const RISCVTargetLowering &TLI =
    static_cast<const RISCVTargetLowering &>(CurDAG->getTargetLoweringInfo());
  return CurDAG->getTargetConstant(((N->getSExtValue()) >> 1) & 0x1f,
  SDLoc(N), TLI.getSubtarget().getXLenVT());}]>;

def simm5_2_XFORM : SDNodeXForm<imm, [{
  const RISCVTargetLowering &TLI =
    static_cast<const RISCVTargetLowering &>(CurDAG->getTargetLoweringInfo());
  return CurDAG->getTargetConstant(((N->getSExtValue()) >> 2) & 0x1f,
  SDLoc(N), TLI.getSubtarget().getXLenVT());}]>;

def simm5_3_XFORM : SDNodeXForm<imm, [{
  const RISCVTargetLowering &TLI =
    static_cast<const RISCVTargetLowering &>(CurDAG->getTargetLoweringInfo());
  return CurDAG->getTargetConstant(((N->getSExtValue()) >> 3) & 0x1f,
  SDLoc(N), TLI.getSubtarget().getXLenVT());}]>;

def simm5_1 : Operand<XLenVT>, ImmLeaf<XLenVT,
  [{return isShiftedInt<5, 1>(Imm);}], simm5_1_XFORM> {
}

def simm5_2 : Operand<XLenVT>, ImmLeaf<XLenVT,
  [{return isShiftedInt<5, 2>(Imm);}], simm5_2_XFORM> {
}

def simm5_3 : Operand<XLenVT>, ImmLeaf<XLenVT,
  [{return isShiftedInt<5, 3>(Imm);}], simm5_3_XFORM> {
}

def uimm2_3_XFORM : SDNodeXForm<imm, [{
  const RISCVTargetLowering &TLI =
    static_cast<const RISCVTargetLowering &>(CurDAG->getTargetLoweringInfo());
  return CurDAG->getTargetConstant(((N->getZExtValue()) >> 3) & 0x3,
  SDLoc(N), TLI.getSubtarget().getXLenVT());}]>;

def uimm2_3 : Operand<XLenVT>, ImmLeaf<XLenVT,
  [{return isShiftedUInt<2, 3>(Imm);}], uimm2_3_XFORM> {
}

def uimm2_4_XFORM : SDNodeXForm<imm, [{
  const RISCVTargetLowering &TLI =
    static_cast<const RISCVTargetLowering &>(CurDAG->getTargetLoweringInfo());
  return CurDAG->getTargetConstant(((N->getZExtValue()) >> 4) & 0x3,
  SDLoc(N), TLI.getSubtarget().getXLenVT());}]>;

def uimm2_4 : Operand<XLenVT>, ImmLeaf<XLenVT,
  [{return isShiftedUInt<2, 4>(Imm);}], uimm2_4_XFORM> {
}

//===----------------------------------------------------------------------===//
// Instruction Formats
//===----------------------------------------------------------------------===//

include "THEAD/THEADInstrFormats.td"

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

let hasNoSchedulingInfo = 1, hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class THEADCacheInstR<bits<7> funct7, bits<5> funct5, string opcodestr>
  :RVInstR<funct7, 0, OPC_CUSTOM1,
  (outs), (ins GPR:$rs1), opcodestr, "$rs1"> {
  let rd = 0;
  let rs2 = funct5;
}

let hasNoSchedulingInfo = 1, hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class THEADCacheInstVoid<bits<7> funct7, bits<5> funct5, string opcodestr>
  : RVInstR<funct7, 0, OPC_CUSTOM1, (outs), (ins), opcodestr, ""> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = funct5;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class THEADShift_ri<bits<5> funct5, bits<3> funct3, string opcodestr>
 : RVInstIShift<funct5, funct3, OPC_CUSTOM1, (outs GPR:$rd), (ins GPR:$rs1,
  uimmlog2xlen:$shamt), opcodestr, "$rd, $rs1, $shamt">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class THEADShiftW_ri<bits<7> funct7, bits<3> funct3, string opcodestr>
 : RVInstIShiftW<funct7, funct3, OPC_CUSTOM1, (outs GPR:$rd), (ins GPR:$rs1,
  uimm5:$shamt), opcodestr, "$rd, $rs1, $shamt">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class THEADExtend<bits<3> funct3, string opcodestr>
  : RVInstI<funct3, OPC_CUSTOM1, (outs GPR:$rd), (ins GPR:$rs1,
   uimmlog2xlen:$msb, uimmlog2xlen:$lsb), opcodestr, "$rd, $rs1, $msb, $lsb"> {
  bits<6> msb;
  bits<6> lsb;
  let Inst{31-26} = msb;
  let Inst{25-20} = lsb;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class THEADRev<bits<5> funct5, bits<2> funct2, string opcodestr>
  : RVInstR4<funct2, 0b001, OPC_CUSTOM1, (outs GPR:$rd), (ins GPR:$rs1),
   opcodestr, "$rd, $rs1"> {
  let rs3 = funct5;
  let rs2 = 0;
}

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
class THEADShiftLD<RegisterClass VT, bits<5> funct5, bits<3> funct3,
  string opcodestr> : RVInstR<!shl(funct5, 2), funct3, OPC_CUSTOM1,
  (outs VT:$rd), (ins GPR:$rs1, GPR:$rs2, uimm2:$uimm2),
  opcodestr, "$rd, $rs1, $rs2, $uimm2"> {
  bits<2> uimm2;
  let Inst{26-25} = uimm2;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class THEADShiftST<RegisterClass VT, bits<5> funct5, bits<3> funct3,
  string opcodestr> : RVInstR<!shl(funct5, 2), funct3, OPC_CUSTOM1, (outs),
  (ins VT:$rd, GPR:$rs1, GPR:$rs2, uimm2:$uimm2),
  opcodestr, "$rd, $rs1, $rs2, $uimm2"> {
  bits<2> uimm2;
  let Inst{26-25} = uimm2;
}

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
class THEADLDUpdate<bits<5> funct5, bits<3> funct3, string opcodestr>
  : RVInstI<funct3, OPC_CUSTOM1, (outs GPR:$rd, GPR:$rs1_up),
  (ins GPR:$rs1, simm5:$simm5, uimm2:$uimm2),
  opcodestr, "$rd, (${rs1}), $simm5, $uimm2"> {
  bits<5> simm5;
  bits<2> uimm2;
  let imm12{11-7} = funct5;
  let imm12{6-5} = uimm2;
  let imm12{4-0} = simm5;
  let Constraints = "@earlyclobber $rd, $rs1_up = $rs1";
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class THEADSTUpdate<bits<5> funct5, bits<3> funct3, string opcodestr>
  : RVInstI<funct3, OPC_CUSTOM1, (outs GPR:$rs1_up),
  (ins GPR:$rd, GPR:$rs1, simm5:$simm5, uimm2:$uimm2),
  opcodestr, "$rd, (${rs1}), $simm5, $uimm2"> {
  bits<5> simm5;
  bits<2> uimm2;
  let imm12{11-7} = funct5;
  let imm12{6-5} = uimm2;
  let imm12{4-0} = simm5;
  let Constraints = "$rs1_up = $rs1";
}

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
class THEADDBLD<bits<5> funct5, bits<3> funct3, string opcodestr, Operand constOp>
  : RVInstR<!shl(funct5, 2), funct3, OPC_CUSTOM1,
  (outs GPR:$rd, GPR:$rs2), (ins GPR:$rs1, uimm2:$uimm2, constOp:$imm),
  opcodestr, "$rd, $rs2, (${rs1}), $uimm2, $imm"> {
  bits<2> uimm2;
  let Inst{26-25} = uimm2;
  let Constraints = "@earlyclobber $rd,@earlyclobber $rs2";
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class THEADDBST<bits<5> funct5, bits<3> funct3, string opcodestr, Operand constOp>
  : RVInstR<!shl(funct5, 2), funct3, OPC_CUSTOM1,
  (outs), (ins GPR:$rd, GPR:$rs2, GPR:$rs1, uimm2:$uimm2, constOp:$imm),
  opcodestr, "$rd, $rs2, (${rs1}), $uimm2, $imm"> {
  bits<2> uimm2;
  let Inst{26-25} = uimm2;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class THEADShiftALU<bits<3> funct3, string opcodestr>
  :RVInstR<0, funct3, OPC_CUSTOM1, (outs GPR:$rd),
  (ins GPR:$rs1, GPR:$rs2, uimm2:$uimm2), opcodestr, "$rd, $rs1, $rs2, $uimm2"> {
  bits<2> uimm2;
  let Inst{31-27} = 0;
  let Inst{26-25} = uimm2;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class THEADArithmetic<bits<7> funct7, bits<3> funct3, string opcodestr>
  :RVInstR<funct7, funct3, OPC_CUSTOM1, (outs GPR:$rd_up),
  (ins GPR:$rd, GPR:$rs1, GPR:$rs2), opcodestr, "${rd}, $rs1, $rs2">{
    let Constraints = "$rd_up = $rd";
  }

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//
let Predicates = [HasTHeadEorC] in {
  def DCACHE_CALL   : THEADCacheInstVoid<0b0000000, 0b00001, "dcache.call">;
  def DCACHE_CIALL  : THEADCacheInstVoid<0b0000000, 0b00011, "dcache.ciall">;
  def DCACHE_CIPA   : THEADCacheInstR<0b0000001, 0b01011, "dcache.cipa">;
  def DCACHE_CSW    : THEADCacheInstR<0b0000001, 0b00001, "dcache.csw">;
  def DCACHE_CISW   : THEADCacheInstR<0b0000001, 0b00011, "dcache.cisw">;
  def DCACHE_CPA    : THEADCacheInstR<0b0000001, 0b01001, "dcache.cpa">;
  def DCACHE_IPA    : THEADCacheInstR<0b0000001, 0b01010, "dcache.ipa">;
  def DCACHE_ISW    : THEADCacheInstR<0b0000001, 0b00010, "dcache.isw">;
  def DCACHE_IALL   : THEADCacheInstVoid<0b0000000, 0b00010, "dcache.iall">;
  def ICACHE_IALL   : THEADCacheInstVoid<0b0000000, 0b10000, "icache.iall">;
  def ICACHE_IPA    : THEADCacheInstR<0b0000001, 0b11000, "icache.ipa">;

  def SYNC    : THEADCacheInstVoid<0b0000000, 0b11000, "sync">;
  def SYNC_I  : THEADCacheInstVoid<0b0000000, 0b11010, "sync.i">;

  def ADDSL  : THEADShiftALU<0b001, "addsl">;
  def MULA   : THEADArithmetic<0b0010000, 0b001, "mula">;
  def MULAH  : THEADArithmetic<0b0010100, 0b001, "mulah">;
  def MULS   : THEADArithmetic<0b0010001, 0b001, "muls">;
  def MULSH  : THEADArithmetic<0b0010101, 0b001, "mulsh">;
  def MVEQZ  : THEADArithmetic<0b0100000, 0b001, "mveqz">;
  def MVNEZ  : THEADArithmetic<0b0100001, 0b001, "mvnez">;
  def SRRI   : THEADShift_ri<0b00010, 0b001, "srri">;
  def EXT    : THEADExtend<0b010, "ext">;
  def EXTU   : THEADExtend<0b011, "extu">;
  def FF0    : THEADRev<0b10000, 0b10, "ff0">;
  def FF1    : THEADRev<0b10000, 0b11, "ff1">;
  def REV    : THEADRev<0b10000, 0b01, "rev">;
  def TST    : THEADShift_ri<0b10001, 0b001, "tst">;
  def TSTNBZ : THEADRev<0b10000, 0b00, "tstnbz">;

  def LRB : THEADShiftLD<GPR, 0b00000, 0b100, "lrb">;
  def LRH : THEADShiftLD<GPR, 0b00100, 0b100, "lrh">;
  def LRW : THEADShiftLD<GPR, 0b01000, 0b100, "lrw">;

  def LRBU : THEADShiftLD<GPR, 0b10000, 0b100, "lrbu">;
  def LRHU : THEADShiftLD<GPR, 0b10100, 0b100, "lrhu">;

  def SRB : THEADShiftST<GPR, 0b00000, 0b101, "srb">;
  def SRH : THEADShiftST<GPR, 0b00100, 0b101, "srh">;
  def SRW : THEADShiftST<GPR, 0b01000, 0b101, "srw">;

  def LBIA : THEADLDUpdate<0b00011, 0b100, "lbia">;
  def LBIB : THEADLDUpdate<0b00001, 0b100, "lbib">;
  def LHIA : THEADLDUpdate<0b00111, 0b100, "lhia">;
  def LHIB : THEADLDUpdate<0b00101, 0b100, "lhib">;
  def LWIA : THEADLDUpdate<0b01011, 0b100, "lwia">;
  def LWIB : THEADLDUpdate<0b01001, 0b100, "lwib">;

  def LBUIA : THEADLDUpdate<0b10011, 0b100, "lbuia">;
  def LBUIB : THEADLDUpdate<0b10001, 0b100, "lbuib">;
  def LHUIA : THEADLDUpdate<0b10111, 0b100, "lhuia">;
  def LHUIB : THEADLDUpdate<0b10101, 0b100, "lhuib">;

  def SBIA : THEADSTUpdate<0b00011, 0b101, "sbia">;
  def SBIB : THEADSTUpdate<0b00001, 0b101, "sbib">;
  def SHIA : THEADSTUpdate<0b00111, 0b101, "shia">;
  def SHIB : THEADSTUpdate<0b00101, 0b101, "shib">;
  def SWIA : THEADSTUpdate<0b01011, 0b101, "swia">;
  def SWIB : THEADSTUpdate<0b01001, 0b101, "swib">;
}

let Predicates = [HasTHeadC] in {
  def DCACHE_CIVA   : THEADCacheInstR<0b0000001, 0b00111, "dcache.civa">;
  def DCACHE_CPAL1  : THEADCacheInstR<0b0000001, 0b01000, "dcache.cpal1">;
  def DCACHE_CVA    : THEADCacheInstR<0b0000001, 0b00101, "dcache.cva">;
  def DCACHE_CVAL1  : THEADCacheInstR<0b0000001, 0b00100, "dcache.cval1">;
  def DCACHE_IVA    : THEADCacheInstR<0b0000001, 0b00110, "dcache.iva">;
  def ICACHE_IALLS  : THEADCacheInstVoid<0b0000000, 0b10001, "icache.ialls">;
  def ICACHE_IVA    : THEADCacheInstR<0b0000001, 0b10000, "icache.iva">;
  def L2CACHE_CALL  : THEADCacheInstVoid<0b0000000, 0b10101, "l2cache.call">;
  def L2CACHE_CIALL : THEADCacheInstVoid<0b0000000, 0b10111, "l2cache.ciall">;
  def L2CACHE_IALL  : THEADCacheInstVoid<0b0000000, 0b10110, "l2cache.iall">;

  def SYNC_IS : THEADCacheInstVoid<0b0000000, 0b11011, "sync.is">;
  def SYNC_S  : THEADCacheInstVoid<0b0000000, 0b11001, "sync.s">;

  def MULAW : THEADArithmetic<0b0010010, 0b001, "mulaw">;
  def MULSW : THEADArithmetic<0b0010011, 0b001, "mulsw">;
  def SRRIW : THEADShiftW_ri<0b0001010, 0b001, "srriw">;
  def REVW  : THEADRev<0b10010, 0b00, "revw">;

  let Predicates = [HasStdExtF] in {
    def FLRW    : THEADShiftLD<FPR32, 0b01000, 0b110, "flrw">;
    def FLURW   : THEADShiftLD<FPR32, 0b01010, 0b110, "flurw">;
    def FSRW_TH : THEADShiftST<FPR32, 0b01000, 0b111, "fsrw">;
    def FSURW   : THEADShiftST<FPR32, 0b01010, 0b111, "fsurw">;
  }

  let Predicates = [HasStdExtD] in {
    def FLRD  : THEADShiftLD<FPR64, 0b01100, 0b110, "flrd">;
    def FLURD : THEADShiftLD<FPR64, 0b01110, 0b110, "flurd">;
    def FSRD  : THEADShiftST<FPR64, 0b01100, 0b111, "fsrd">;
    def FSURD : THEADShiftST<FPR64, 0b01110, 0b111, "fsurd">;
  }

  def LRD : THEADShiftLD<GPR, 0b01100, 0b100, "lrd">;

  def LRWU : THEADShiftLD<GPR, 0b11000, 0b100, "lrwu">;

  def SRD : THEADShiftST<GPR, 0b01100, 0b101, "srd">;

  def LURB : THEADShiftLD<GPR, 0b00010, 0b100, "lurb">;
  def LURH : THEADShiftLD<GPR, 0b00110, 0b100, "lurh">;
  def LURW : THEADShiftLD<GPR, 0b01010, 0b100, "lurw">;
  def LURD : THEADShiftLD<GPR, 0b01110, 0b100, "lurd">;

  def LURBU : THEADShiftLD<GPR, 0b10010, 0b100, "lurbu">;
  def LURHU : THEADShiftLD<GPR, 0b10110, 0b100, "lurhu">;
  def LURWU : THEADShiftLD<GPR, 0b11010, 0b100, "lurwu">;

  def SURB : THEADShiftST<GPR, 0b00010, 0b101, "surb">;
  def SURH : THEADShiftST<GPR, 0b00110, 0b101, "surh">;
  def SURW : THEADShiftST<GPR, 0b01010, 0b101, "surw">;
  def SURD : THEADShiftST<GPR, 0b01110, 0b101, "surd">;

  def LDIA : THEADLDUpdate<0b01111, 0b100, "ldia">;
  def LDIB : THEADLDUpdate<0b01101, 0b100, "ldib">;

  def LWUIA : THEADLDUpdate<0b11011, 0b100, "lwuia">;
  def LWUIB : THEADLDUpdate<0b11001, 0b100, "lwuib">;

  def SDIA : THEADSTUpdate<0b01111, 0b101, "sdia">;
  def SDIB : THEADSTUpdate<0b01101, 0b101, "sdib">;

  def LWD  : THEADDBLD<0b11100, 0b100, "lwd", constant_3>;
  def LWUD : THEADDBLD<0b11110, 0b100, "lwud", constant_3>;
  def LDD  : THEADDBLD<0b11111, 0b100, "ldd", constant_4>;
  def SWD  : THEADDBST<0b11100, 0b101, "swd", constant_3>;
  def SDD  : THEADDBST<0b11111, 0b101, "sdd", constant_4>;
}

//===----------------------------------------------------------------------===//
// Patterns
//===----------------------------------------------------------------------===//

let Predicates = [HasTHeadEorC] in {
  def : PatGprImm<rotr, SRRI, uimmlog2xlen>;
  def : Pat<(add GPR:$rs1, (shl GPR:$rs2, uimm2:$uimm2)),
            (ADDSL GPR:$rs1, GPR:$rs2, uimm2:$uimm2)>;
  def : Pat<(add GPR:$rd, (mul GPR:$rs1, GPR:$rs2)),
            (MULA GPR:$rd, GPR:$rs1, GPR:$rs2)>;
  def : Pat<(sext_inreg (add GPR:$rd, (mul (sext_inreg GPR:$rs1, i16),
            (sext_inreg GPR:$rs2, i16))), i32),
            (MULAH GPR:$rd, GPR:$rs1, GPR:$rs2)>;
  def : Pat<(sub GPR:$rd, (mul GPR:$rs1, GPR:$rs2)),
            (MULS GPR:$rd, GPR:$rs1, GPR:$rs2)>;
  def : Pat<(sext_inreg (sub GPR:$rd, (mul (sext_inreg GPR:$rs1, i16),
            (sext_inreg GPR:$rs2, i16))), i32),
            (MULSH GPR:$rd, GPR:$rs1, GPR:$rs2)>;
  def : Pat<(select (XLenVT (seteq GPR:$rs2, 0)), GPR:$rs1, GPR:$rd),
            (MVEQZ GPR:$rd, GPR:$rs1, GPR:$rs2)>;
  def : Pat<(select (XLenVT (setne GPR:$rs2, 0)), GPR:$rs1, GPR:$rd),
            (MVNEZ GPR:$rd, GPR:$rs1, GPR:$rs2)>;
  def : Pat<(select GPR:$rs2, GPR:$rs1, GPR:$rd),
            (MVNEZ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

  def : Pat<(and GPR:$rs1, 1), (EXTU GPR:$rs1, 0, 0)>;
  def : Pat<(and GPR:$rs1, 0xff), (EXTU GPR:$rs1, 7, 0)>;
  def : Pat<(and GPR:$rs1, 0xffff), (EXTU GPR:$rs1, 15, 0)>;
  def : Pat<(and GPR:$rs1, 0xffffffff), (EXTU GPR:$rs1, 31, 0)>;
  def : Pat<(sext_inreg GPR:$rs1, i32), (EXT GPR:$rs1, 31, 0)>;
  def : Pat<(sext_inreg GPR:$rs1, i16), (EXT GPR:$rs1, 15, 0)>;
  def : Pat<(sext_inreg GPR:$rs1, i8),  (EXT GPR:$rs1, 7, 0)>;
  def : Pat<(sext_inreg GPR:$rs1, i1),  (EXT GPR:$rs1, 0, 0)>;
  def : Pat<(ctlz GPR:$rs1), (FF1 GPR:$rs1)>;
  def : Pat<(ctlz (xor GPR:$rs1, -1)), (FF0 GPR:$rs1)>;
  def : Pat<(bswap GPR:$rs1), (REV GPR:$rs1)>;
  def : Pat<(and (srl GPR:$rs1, uimmlog2xlen:$shamt), 1),
             (TST GPR:$rs1, uimmlog2xlen:$shamt)>;
}

let Predicates = [HasTHeadC, IsRV64] in {
  def : PatGprImm<riscv_rorw, SRRIW, uimm5>;
  def : Pat<(riscv_rorw i64:$rs1, i64:$rs2),
            (ADDIW (OR (SRL i64:$rs1, (ANDI i64:$rs2, 31)),
             (SLL i64:$rs1, (ANDI (SUB X0, i64:$rs2), 31))), 0)>;
  def : Pat<(rotr i64:$rs1, i64:$rs2),
            (OR (SRL i64:$rs1, (ANDI i64:$rs2, 63)),
              (SLL i64:$rs1, (ANDI (SUB X0, i64:$rs2), 63)))>;
  def : Pat<(sext_inreg (add i64:$rd, (mul i64:$rs1, i64:$rs2)), i32),
            (MULAW i64:$rd, i64:$rs1, i64:$rs2)>;
  def : Pat<(sext_inreg (sub i64:$rd, (mul i64:$rs1, i64:$rs2)), i32),
            (MULSW i64:$rd, i64:$rs1, i64:$rs2)>;
  def : Pat<(sra (bswap i64:$rs1), (i64 32)), (REVW i64:$rs1)>;
}

let Predicates = [HasTHeadE, IsRV32] in {
  def : Pat<(rotr i32:$rs1, i32:$rs2),
            (OR (SRL i32:$rs1, (ANDI i32:$rs2, 31)),
              (SLL i32:$rs1, (ANDI (SUB X0, i32:$rs2), 31)))>;
}

multiclass LdrPat<PatFrag LoadOp, RVInst Inst, ValueType vt = XLenVT> {
  def : Pat<(vt (LoadOp (add GPR:$rs1, (shl GPR:$rs2, uimm2:$uimm2)))),
            (Inst GPR:$rs1, GPR:$rs2, uimm2:$uimm2)>;
  def : Pat<(vt (LoadOp (add GPR:$rs1, GPR:$rs2))),
            (Inst GPR:$rs1, GPR:$rs2, 0)>;
}

multiclass LdrZextPat<PatFrag LoadOp, RVInst Inst, ValueType vt = XLenVT> {
  def : Pat<(vt (LoadOp (add GPR:$rs1,
              (shl (and GPR:$rs2, 4294967295), uimm2:$uimm2)))),
            (Inst GPR:$rs1, GPR:$rs2, uimm2:$uimm2)>;
  def : Pat<(vt (LoadOp (add GPR:$rs1, (and GPR:$rs2, 4294967295)))),
            (Inst GPR:$rs1, GPR:$rs2, 0)>;
}

multiclass StrPat<PatFrag StoreOp, RVInst Inst, RegisterClass StTy,
                 ValueType vt = XLenVT> {
  def : Pat<(StoreOp (vt StTy:$rd), (add GPR:$rs1,
              (shl GPR:$rs2, uimm2:$uimm2))),
            (Inst StTy:$rd, GPR:$rs1, GPR:$rs2, uimm2:$uimm2)>;
  def : Pat<(StoreOp (vt StTy:$rd), (add GPR:$rs1, GPR:$rs2)),
            (Inst StTy:$rd, GPR:$rs1, GPR:$rs2, 0)>;
}

multiclass StrZextPat<PatFrag StoreOp, RVInst Inst, RegisterClass StTy,
                 ValueType vt = XLenVT> {
  def : Pat<(StoreOp (vt StTy:$rd), (add GPR:$rs1,
              (shl (and GPR:$rs2, 4294967295), uimm2:$uimm2))),
            (Inst StTy:$rd, GPR:$rs1, GPR:$rs2, uimm2:$uimm2)>;
  def : Pat<(StoreOp (vt StTy:$rd),
              (add GPR:$rs1, (and GPR:$rs2, 4294967295))),
            (Inst StTy:$rd, GPR:$rs1, GPR:$rs2, 0)>;
}

let Predicates = [HasTHeadEorC] in {
  let AddedComplexity = 3 in {
    defm : LdrPat<extloadi8, LRB>;
    defm : LdrPat<sextloadi8, LRB>;
    defm : LdrPat<zextloadi8, LRBU>;
  }

  defm : LdrPat<extloadi16, LRH>;
  defm : LdrPat<sextloadi16, LRH>;
  defm : LdrPat<zextloadi16, LRHU>;

  let AddedComplexity = 3 in
  defm : StrPat<truncstorei8, SRB, GPR>;
  defm : StrPat<truncstorei16, SRH, GPR>;
}

let Predicates = [HasTHeadC, IsRV64] in {
  let Predicates = [HasStdExtF] in {
    defm : LdrPat<load, FLRW, f32>;
    defm : LdrZextPat<load, FLURW, f32>;
    defm : StrPat<store, FSRW_TH, FPR32, f32>;
    defm : StrZextPat<store, FSURW, FPR32, f32>;
  }

  let Predicates = [HasStdExtD] in {
    defm : LdrPat<load, FLRD, f64>;
    defm : LdrZextPat<load, FLURD, f64>;
    defm : StrPat<store, FSRD, FPR64, f64>;
    defm : StrZextPat<store, FSURD, FPR64, f64>;
  }

  defm : LdrPat<extloadi32, LRW, i64>;
  defm : LdrPat<sextloadi32, LRW, i64>;
  defm : LdrPat<zextloadi32, LRWU, i64>;

  defm : LdrZextPat<extloadi8, LURB, i64>;
  defm : LdrZextPat<sextloadi8, LURB, i64>;
  defm : LdrZextPat<zextloadi8, LURBU, i64>;
  defm : LdrZextPat<extloadi16, LURH, i64>;
  defm : LdrZextPat<sextloadi16, LURH, i64>;
  defm : LdrZextPat<zextloadi16, LURHU, i64>;
  defm : LdrZextPat<extloadi32, LURW, i64>;
  defm : LdrZextPat<sextloadi32, LURW, i64>;
  defm : LdrZextPat<zextloadi32, LURWU, i64>;

  defm : LdrPat<load, LRD, i64>;
  defm : LdrZextPat<load, LURD, i64>;

  defm : StrPat<truncstorei32, SRW, GPR, i64>;

  defm : StrPat<store, SRD, GPR, i64>;

  defm : StrZextPat<truncstorei8, SURB, GPR>;
  defm : StrZextPat<truncstorei16, SURH, GPR>;
  defm : StrZextPat<truncstorei32, SURW, GPR, i64>;
  defm : StrZextPat<store, SURD, GPR, i64>;
}

let Predicates = [HasTHeadE, IsRV32] in {
  defm : LdrPat<load, LRW, i32>;
  defm : StrPat<store, SRW, GPR, i32>;
}

multiclass StoreShiftUpPattern<PatFrag st, Instruction Inst,
  ValueType vt = XLenVT> {
  def : Pat<(st (vt GPR:$rd), GPR:$rs1, simm5:$off),
            (Inst GPR:$rd, GPR:$rs1, simm5:$off, 0)>;
  def : Pat<(st (vt GPR:$rd), GPR:$rs1, simm5_1:$off),
            (Inst GPR:$rd, GPR:$rs1, simm5_1:$off, 1)>;
  def : Pat<(st (vt GPR:$rd), GPR:$rs1, simm5_2:$off),
            (Inst GPR:$rd, GPR:$rs1, simm5_2:$off, 2)>;
  def : Pat<(st (vt GPR:$rd), GPR:$rs1, simm5_3:$off),
            (Inst GPR:$rd, GPR:$rs1, simm5_3:$off, 3)>;
}

let Predicates = [HasTHeadEorC] in {
  defm : StoreShiftUpPattern<post_truncsti8, SBIA>;
  defm : StoreShiftUpPattern<pre_truncsti8, SBIB>;
  defm : StoreShiftUpPattern<post_truncsti16, SHIA>;
  defm : StoreShiftUpPattern<pre_truncsti16, SHIB>;
}

let Predicates = [HasTHeadC, IsRV64] in {
  defm : StoreShiftUpPattern<post_truncsti32, SWIA, i64>;
  defm : StoreShiftUpPattern<pre_truncsti32, SWIB, i64>;
  defm : StoreShiftUpPattern<post_store, SDIA, i64>;
  defm : StoreShiftUpPattern<pre_store, SDIB, i64>;

  def : Pat<(TLWD i64:$rs1, uimm2_3:$uimm2_3), (LWD i64:$rs1, uimm2_3:$uimm2_3, 3)>;
  def : Pat<(TLWUD i64:$rs1, uimm2_3:$uimm2_3), (LWUD i64:$rs1, uimm2_3:$uimm2_3, 3)>;
  def : Pat<(TLDD i64:$rs1, uimm2_4:$uimm2_4), (LDD i64:$rs1, uimm2_4:$uimm2_4, 4)>;

  def : Pat<(TSWD i64:$rd1, i64:$rd2, i64:$rs1, uimm2_3:$uimm2_3),
            (SWD i64:$rd1, i64:$rd2, i64:$rs1, uimm2_3:$uimm2_3, 3)>;
  def : Pat<(TSDD i64:$rd1, i64:$rd2, i64:$rs1, uimm2_4:$uimm2_4),
            (SDD i64:$rd1, i64:$rd2, i64:$rs1, uimm2_4:$uimm2_4, 4)>;
}

let Predicates = [HasTHeadE, IsRV32] in {
  defm : StoreShiftUpPattern<post_store, SWIA, i32>;
  defm : StoreShiftUpPattern<pre_store, SWIB, i32>;
}
