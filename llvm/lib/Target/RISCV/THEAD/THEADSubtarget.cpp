
#include "llvm/CodeGen/MachineScheduler.h"

void RISCVSubtarget::overrideSchedPolicy(MachineSchedPolicy &Policy,
                                         unsigned NumRegionInstrs) const {
  if (!isTHEADProc())
    return;

  // The GenericScheduler that we use defaults to scheduling bottom up only.
  // We want to schedule from both the top and the bottom and so we set
  // OnlyBottomUp to false.
  // We want to do bi-directional scheduling since it provides a more balanced
  // schedule leading to better performance.
  Policy.OnlyBottomUp = false;
  Policy.OnlyTopDown = false;

  Policy.ShouldTrackPressure = true;
}

// This overrides the PostRAScheduler bit in the SchedModel for each CPU.
bool RISCVSubtarget::enablePostRAScheduler() const {
  if (!isTHEADProc())
    return TargetSubtargetInfo::enablePostRAScheduler();

  return true;
}
