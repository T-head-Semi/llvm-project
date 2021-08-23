//===-- THEAD.td - Describe the THEAD Target Machine -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// T-HEAD subtarget features and instruction predicates.
//===----------------------------------------------------------------------===//

def FeatureTHEADC
    : SubtargetFeature<"xtheadc", "HasTHeadC", "true",
                       "'xtheadc' (T-HEAD C Series Extended Instructions)">;
def HasTHeadC : Predicate<"Subtarget->hasTHeadC()">,
                          AssemblerPredicate<(all_of FeatureTHEADC),
                          "'xtheadc' (T-HEAD C Series Extended Instructions)">;

def FeatureTHEADE
    : SubtargetFeature<"xtheade", "HasTHeadE", "true",
                       "'xtheade' (T-HEAD E Series Extended Instructions)">;
def HasTHeadE : Predicate<"Subtarget->hasTHeadE()">,
                          AssemblerPredicate<(all_of FeatureTHEADE),
                          "'xtheade' (T-HEAD E Series Extended Instructions)">;

def FeatureTHEADSE
    : SubtargetFeature<"xtheadse", "HasTHeadSE", "true",
                       "'xtheadse' (T-HEAD SE Series Extended Instructions)">;
def HasTHeadSE : Predicate<"Subtarget->hasTHeadSE()">,
                          AssemblerPredicate<(all_of FeatureTHEADSE),
                          "'xtheadse' (T-HEAD SE Series Extended Instructions)">;

def HasTHeadEorC : Predicate<"Subtarget->hasTHeadEorC()">,
                          AssemblerPredicate<(any_of FeatureTHEADC, FeatureTHEADE),
                          "'xtheade or xtheadc' (T-HEAD E or C Series Extended Instructions)">;

def ProcC906 :
  SubtargetFeature<"", "THEADProcFamily",
                   "THEAD::C906", "T-HEAD C906 series processors">;
def ProcC910 :
  SubtargetFeature<"", "THEADProcFamily",
                   "THEAD::C910", "T-HEAD C910 series processors">;
//===----------------------------------------------------------------------===//
// Registers, calling conventions, instruction descriptions.
//===----------------------------------------------------------------------===//

include "THEAD/THEADSchedule.td"
include "THEAD/THEADInstrInfo.td"
include "THEAD/THEADSchedC906.td"
include "THEAD/THEADSchedC910.td"

//===----------------------------------------------------------------------===//
// T-HEAD processors supported.
//===----------------------------------------------------------------------===//

def : ProcessorModel<"c906", THEADC906Model,
  [ProcC906, Feature64Bit, FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureTHEADC]>;

def : ProcessorModel<"c906fd", THEADC906Model,
  [ProcC906, Feature64Bit, FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureStdExtF, FeatureStdExtD, FeatureTHEADC]>;

def : ProcessorModel<"c906fdv", THEADC906Model,
  [ProcC906, Feature64Bit,FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureStdExtF, FeatureStdExtD, FeatureStdExtV, FeatureTHEADC]>;

def : ProcessorModel<"c910", THEADC910Model,
  [ProcC910, Feature64Bit, FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureStdExtF, FeatureStdExtD, FeatureTHEADC]>;

def : ProcessorModel<"c920", THEADC910Model,
  [ProcC910, Feature64Bit, FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureStdExtF, FeatureStdExtD, FeatureStdExtV, FeatureTHEADC]>;

def : ProcessorModel<"r910", THEADC910Model,
  [ProcC910, Feature64Bit, FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureStdExtF, FeatureStdExtD, FeatureTHEADC]>;

def : ProcessorModel<"r920", THEADC910Model,
  [ProcC910, Feature64Bit, FeatureStdExtM, FeatureStdExtA, FeatureStdExtC,
   FeatureStdExtF, FeatureStdExtD, FeatureStdExtV, FeatureTHEADC]>;