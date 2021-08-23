ADD_CUSTOM_TARGET(THEADCodeGen DEPENDS
  THEADImm.def
  THEADISDMemOp.def
  THEADISelLowering.def
  THEADOp.def
  THEADPassConfig.def
  THEADInstrInfo.def
  THEADISDOp.def
  THEADNodeName.def
  THEADOperand.def
  THEADSubtargetInfo.def
)

ADD_DEPENDENCIES(RISCV THEADCodeGen)
