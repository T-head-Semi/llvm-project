//===-- THEADHazardRecognizers.cpp - T-HEAD Hazard Recognizer Impls -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements hazard recognizers for scheduling on T-HEAD processors.
//
//===----------------------------------------------------------------------===//

#include "THEADHazardRecognizers.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "thead-hazard-rec"

using namespace llvm;

bool THEADHazardRecognizerC910::isLoadAfterStore(SUnit *SU) {

  const MCInstrDesc *MCID = DAG->getInstrDesc(SU);
  if (!MCID)
    return false;

  if (!MCID->mayLoad())
    return false;

  // SU is a load; for any predecessors in this dispatch group, that are stores,
  // and with which we have an ordering dependency, return true.
  for (unsigned i = 0, ie = (unsigned)SU->Preds.size(); i != ie; ++i) {
    const MCInstrDesc *PredMCID = DAG->getInstrDesc(SU->Preds[i].getSUnit());
    if (!PredMCID || !PredMCID->mayStore())
      continue;

    if (!SU->Preds[i].isNormalMemory() && !SU->Preds[i].isBarrier())
      continue;

    for (unsigned j = 0, je = CurGroup.size(); j != je; ++j)
      if (SU->Preds[i].getSUnit() == CurGroup[j])
        return true;
  }

  return false;
}

static bool isMulFamily(const MCInstrDesc *MCID) {
  switch (MCID->getOpcode()) {
  default:
    return false;
  case RISCV::MUL:
  case RISCV::MULH:
  case RISCV::MULHSU:
  case RISCV::MULHU:
    return true;
  }
}

static bool isDivFamily(const MCInstrDesc *MCID) {
  switch (MCID->getOpcode()) {
  default:
    return false;
  case RISCV::DIV:
  case RISCV::DIVU:
    return true;
  }
}

ScheduleHazardRecognizer::HazardType
THEADHazardRecognizerC910::getHazardType(SUnit *SU, int Stalls) {
  assert(Stalls == 0 && "THEAD hazards don't support scoreboard lookahead");

  const MCInstrDesc *MCID = DAG->getInstrDesc(SU);
  if (MCID) {
    if (MCID->isBranch() && CurBranch >= 2)
      return NoopHazard;
    if ((MCID->mayLoad() || MCID->mayStore()) && CurLDST >= 2)
      return NoopHazard;
    if (isMulFamily(MCID) && CurMul >= 2)
      return NoopHazard;
    if (isDivFamily(MCID) && CurDiv >= 2)
      return NoopHazard;
    // FIXME: Add more type hazard such as float point algorithem.
    //        Can judge from instruction flag defined in td file.
  }

  if (isLoadAfterStore(SU))
    return NoopHazard;

  return ScoreboardHazardRecognizer::getHazardType(SU, Stalls);
}

void THEADHazardRecognizerC910::reInit() {
  CurGroup.clear();
  CurSlots = 0;
  CurBranch = 0;
  CurLDST = 0;
  CurMul = 0;
  CurDiv = 0;
}

void THEADHazardRecognizerC910::EmitInstruction(SUnit *SU) {
  const MCInstrDesc *MCID = DAG->getInstrDesc(SU);

  if (MCID) {
    LLVM_DEBUG(dbgs() << "**** Adding to dispatch group: ");
    LLVM_DEBUG(DAG->dumpNode(*SU));

    CurGroup.push_back(SU);

    CurSlots++;

    if (MCID->isBranch())
      ++CurBranch;
    else if (MCID->mayLoad() || MCID->mayStore())
      ++CurLDST;
    else if (isMulFamily(MCID))
      ++CurMul;
    else if (isDivFamily(MCID))
      ++CurDiv;
  }

  ScoreboardHazardRecognizer::EmitInstruction(SU);
}

void THEADHazardRecognizerC910::AdvanceCycle() {
  reInit();
  ScoreboardHazardRecognizer::AdvanceCycle();
}

void THEADHazardRecognizerC910::RecedeCycle() {
  reInit();
  ScoreboardHazardRecognizer::RecedeCycle();
}

bool THEADHazardRecognizerC910::atIssueLimit() const {
  if (SlotsWidth == 0)
    return false;

  return CurSlots == SlotsWidth;
}

void THEADHazardRecognizerC910::Reset() {
  reInit();
  ScoreboardHazardRecognizer::Reset();
}

void THEADHazardRecognizerC910::EmitNoop() {
  ++CurSlots;
  ScoreboardHazardRecognizer::EmitNoop();
}