//===-- THEADSchedule.td - THEAD Scheduling Definitions ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

/// Define scheduler resources associated with def operands.
def WriteIMula      : SchedWrite;    // integer multiply-add
def WriteIMula32    : SchedWrite;    // integer low 32-bit multiply-add
def WriteIMula16    : SchedWrite;    // integer low 16-bit multiply-add
def WriteIMOVC      : SchedWrite;    // integer conditional mov
def WriteEXT        : SchedWrite;    // integer sign extend in any bits
def WriteEXTU       : SchedWrite;    // integer zero extend in any bits
def WriteFF0        : SchedWrite;    // count first zero
def WriteFF1        : SchedWrite;    // count first one
def WriteREVW8      : SchedWrite;    // 32-bit integer byte swap
def WriteTST        : SchedWrite;    // test bit zero or not
def WriteTSTNBZ     : SchedWrite;    // test byte zero or not

def WriteMemOffset  : SchedWrite;    // integer memory offset
def WriteFMemOffset : SchedWrite;    // float memory offset
def WriteMemBase    : SchedWrite;    // integer memory base

def WriteFence      : SchedWrite;    // fence
def WriteSPECIAL    : SchedWrite;


/// Define scheduler resources associated with use operands.
def ReadIMula       : SchedRead;     // integer multiply-add
def ReadIMula32     : SchedRead;     // integer low 32-bit multiply-add
def ReadIMula16     : SchedRead;     // integer low 16-bit multiply-add
def ReadIMOVC       : SchedRead;     // integer conditional mov
def ReadEXT         : SchedRead;     // integer sign extend in any bits
def ReadEXTU        : SchedRead;     // integer zero extend in any bits
def ReadFF0         : SchedRead;     // integer count first zero
def ReadFF1         : SchedRead;     // integer count first one
def ReadREVW8       : SchedRead;     // 32-bit integer byte swap
def ReadTST         : SchedRead;     // test bit zero or not
def ReadTSTNBZ      : SchedRead;     // test byte zero or not

def ReadMemOffset   : SchedRead;     // integer memory offset
def ReadFMemOffset  : SchedRead;     // float memory offset
