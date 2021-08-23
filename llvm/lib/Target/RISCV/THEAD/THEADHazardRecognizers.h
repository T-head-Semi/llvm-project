//===-- THEADHazardRecognizers.h - T-HEAD Hazard Recognizers ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines hazard recognizers for scheduling on T-HEAD processors.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_THEAD_THEADHAZARDRECOGNIZERS_H
#define LLVM_LIB_TARGET_THEAD_THEADHAZARDRECOGNIZERS_H

#include "RISCVInstrInfo.h"
#include "llvm/CodeGen/ScheduleHazardRecognizer.h"
#include "llvm/CodeGen/ScoreboardHazardRecognizer.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"

namespace llvm {

/// THEADHazardRecognizerC910 - This class implements a
/// scoreboard-based hazard recognizer for THEAD ooo processors with
/// dispatch-group hazards.
class THEADHazardRecognizerC910 : public ScoreboardHazardRecognizer {
  const ScheduleDAG *DAG;

  SmallVector<SUnit *, 7> CurGroup;
  unsigned CurSlots = 0;
  unsigned CurBranch = 0;
  unsigned CurLDST = 0;
  unsigned CurMul = 0;
  unsigned CurDiv = 0;
  unsigned SlotsWidth = 0;

  bool isLoadAfterStore(SUnit *SU);
  void reInit();

public:
  THEADHazardRecognizerC910(const InstrItineraryData *ItinData,
                            const ScheduleDAG *DAG_)
      : ScoreboardHazardRecognizer(ItinData, DAG_), DAG(DAG_) {
    SlotsWidth = 3;
    MaxLookAhead = 1;
  }

  HazardType getHazardType(SUnit *SU, int Stalls) override;
  void EmitInstruction(SUnit *SU) override;
  void AdvanceCycle() override;
  void RecedeCycle() override;
  bool atIssueLimit() const override;
  void Reset() override;
  void EmitNoop() override;
};

} // end namespace llvm

#endif
