//===- THEADInstrResources.td - T-HEAD Instr Resource Defs  -*- tablegen -*-==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the resources required by T-HEAD instructions. This is
// part of the T-HEAD processor model used for instruction scheduling. This file
// should contain all the instructions that may be used on T-HEAD series CPU.
//
//===----------------------------------------------------------------------===//


def : InstRW<[WriteIALU, ReadIALU, ReadIALU], (instrs ADDSL)>;
def : InstRW<[WriteIMula, ReadIMula, ReadIMula, ReadIMula],
  (instrs MULA, MULS)>;
def : InstRW<[WriteIMula32, ReadIMula32, ReadIMula32, ReadIMula32],
  (instrs MULAW, MULSW)>;
def : InstRW<[WriteIMula16, ReadIMula16, ReadIMula16, ReadIMula16],
  (instrs MULAH, MULSH)>;
def : InstRW<[WriteIMOVC, ReadIMOVC, ReadIMOVC, ReadIMOVC],
  (instrs MVEQZ, MVNEZ)>;
def : InstRW<[WriteRotateImm, ReadRotateImm], (instrs SRRI)>;
def : InstRW<[WriteRotateImm32, ReadRotateImm32], (instrs SRRIW)>;

def : InstRW<[WriteEXT, ReadEXT], (instrs EXT)>;
def : InstRW<[WriteEXTU, ReadEXTU], (instrs EXTU)>;
def : InstRW<[WriteFF0, ReadFF0], (instrs FF0)>;
def : InstRW<[WriteFF1, ReadFF1], (instrs FF1)>;
def : InstRW<[WriteREV8, ReadREV8], (instrs REV)>;
def : InstRW<[WriteREVW8, ReadREVW8], (instrs REVW)>;
def : InstRW<[WriteTST, ReadTST], (instrs TST)>;
def : InstRW<[WriteTSTNBZ, ReadTSTNBZ], (instrs TSTNBZ)>;

def : InstRW<[WriteFLD32, ReadFMemBase, ReadFMemOffset], (instrs FLRW, FLURW)>;
def : InstRW<[WriteFST32, ReadStoreData, ReadFMemBase, ReadFMemOffset],
  (instrs FSRW_TH, FSURW)>;
def : InstRW<[WriteFLD64, ReadFMemBase, ReadFMemOffset], (instrs FLRD, FLURD)>;
def : InstRW<[WriteFST64, ReadStoreData, ReadFMemBase, ReadFMemOffset],
  (instrs FSRD, FSURD)>;

def : InstRW<[WriteLDB, ReadMemBase, ReadMemOffset],
  (instrs LRB, LRBU, LURB, LURBU)>;
def : InstRW<[WriteLDH, ReadMemBase, ReadMemOffset],
  (instrs LRH, LRHU, LURH, LURHU)>;
def : InstRW<[WriteLDW, ReadMemBase, ReadMemOffset],
  (instrs LRW, LRWU, LURW, LURWU)>;
def : InstRW<[WriteLDD, ReadMemBase, ReadMemOffset],
  (instrs LRD, LURD)>;

def : InstRW<[WriteSTB, ReadStoreData, ReadMemBase, ReadMemOffset],
  (instrs SRB, SURB)>;
def : InstRW<[WriteSTH, ReadStoreData, ReadMemBase, ReadMemOffset],
  (instrs SRH, SURH)>;
def : InstRW<[WriteSTW, ReadStoreData, ReadMemBase, ReadMemOffset],
  (instrs SRW, SURW)>;
def : InstRW<[WriteSTD, ReadStoreData, ReadMemBase, ReadMemOffset],
  (instrs SRD, SURD)>;

def : InstRW<[WriteLDB, WriteMemBase, ReadMemBase],
  (instrs LBIA, LBIB, LBUIA, LBUIB)>;
def : InstRW<[WriteLDH, WriteMemBase, ReadMemBase],
  (instrs LHIA, LHIB, LHUIA, LHUIB)>;
def : InstRW<[WriteLDW, WriteMemBase, ReadMemBase],
  (instrs LWIA, LWIB, LWUIA, LWUIB)>;
def : InstRW<[WriteLDD, WriteMemBase, ReadMemBase],
  (instrs LDIA, LDIB)>;

def : InstRW<[WriteSTB, WriteMemBase, ReadStoreData, ReadMemBase],
  (instrs SBIA, SBIB)>;
def : InstRW<[WriteSTH, WriteMemBase, ReadStoreData, ReadMemBase],
  (instrs SHIA, SHIB)>;
def : InstRW<[WriteSTW, WriteMemBase, ReadStoreData, ReadMemBase],
  (instrs SWIA, SWIB)>;
def : InstRW<[WriteSTD, WriteMemBase, ReadStoreData, ReadMemBase],
  (instrs SDIA, SDIB)>;

def : InstRW<[WriteLDW, WriteLDW, ReadMemBase], (instrs LWD, LWUD)>;
def : InstRW<[WriteLDD, WriteLDD, ReadMemBase], (instrs LDD)>;
def : InstRW<[WriteSTW, WriteSTW, ReadStoreData, ReadMemBase], (instrs SWD)>;
def : InstRW<[WriteSTD, WriteSTD, ReadStoreData, ReadMemBase], (instrs SDD)>;

def : InstRW<[WriteFence], (instrs FENCE)>;
