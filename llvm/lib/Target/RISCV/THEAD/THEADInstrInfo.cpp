#include "THEADHazardRecognizers.h"
#include "llvm/CodeGen/MachineScheduler.h"
#include "llvm/CodeGen/ScheduleDAG.h"

static cl::opt<bool>
    EnableTHEADHazardRec("enable-thead-hazard-rec",
                         cl::desc("Enable T-HEAD hazard recognization or not"),
                         cl::init(true), cl::Hidden);

/// CreateTargetPostRAHazardRecognizer - Return the postRA hazard recognizer
/// to use for this target when scheduling the DAG.
ScheduleHazardRecognizer *RISCVInstrInfo::CreateTargetPostRAHazardRecognizer(
    const InstrItineraryData *II, const ScheduleDAG *DAG) const {
  RISCVSubtarget::THEAD THEADCPU =
      DAG->MF.getSubtarget<RISCVSubtarget>().getTHEADProc();

  if (THEADCPU == RISCVSubtarget::THEAD::C910 && EnableTHEADHazardRec)
    return new THEADHazardRecognizerC910(II, DAG);

  return TargetInstrInfo::CreateTargetPostRAHazardRecognizer(II, DAG);
}

ScheduleHazardRecognizer *
RISCVInstrInfo::CreateTargetMIHazardRecognizer(const InstrItineraryData *II,
                                               const ScheduleDAGMI *DAG) const {
  RISCVSubtarget::THEAD THEADCPU =
      DAG->MF.getSubtarget<RISCVSubtarget>().getTHEADProc();

  if (THEADCPU == RISCVSubtarget::THEAD::C910 && EnableTHEADHazardRec)
    return new THEADHazardRecognizerC910(II, DAG);

  return TargetInstrInfo::CreateTargetMIHazardRecognizer(II, DAG);
}

void RISCVInstrInfo::insertNoop(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MI) const {
  const auto MF = MBB.getParent();
  const RISCVSubtarget &ST = MF->getSubtarget<RISCVSubtarget>();
  DebugLoc DL;

  if (ST.hasStdExtC())
    BuildMI(MBB, MI, DL, get(RISCV::C_NOP));
  else
    BuildMI(MBB, MI, DL, get(RISCV::ADDI), RISCV::X0)
        .addReg(RISCV::X0)
        .addImm(0);
}

#include "THEADHazardRecognizers.cpp"