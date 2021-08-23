add_llvm_component_library(LLVMRISCVDesc
  RISCVAsmBackend.cpp
  RISCVBaseInfo.cpp
  RISCVELFObjectWriter.cpp
  RISCVInstPrinter.cpp
  RISCVMCAsmInfo.cpp
  RISCVMCCodeEmitter.cpp
  RISCVMCExpr.cpp
  RISCVMCTargetDesc.cpp
  RISCVMatInt.cpp
  RISCVTargetStreamer.cpp
  RISCVELFStreamer.cpp

  LINK_COMPONENTS
  MC
  RISCVInfo
  Support
  THEADDesc

  ADD_TO_COMPONENT
  RISCV
)

add_subdirectory(THEAD)
