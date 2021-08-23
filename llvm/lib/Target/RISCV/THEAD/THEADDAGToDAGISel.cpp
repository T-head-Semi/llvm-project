bool RISCVDAGToDAGISel::tryTHEADSelect(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  MVT XLenVT = Subtarget->getXLenVT();
  SDLoc DL(Node);
  MVT VT = Node->getSimpleValueType(0);

  switch (Opcode) {
  default:
    return false;
  case ISD::LOAD:
    if (tryTHEADIndexedLoad(Node))
      return true;
    return false;
  }
}

static bool isScaledConstantInRange(int64_t C, int64_t simm, int64_t shift,
                                    int64_t &ScaledConstant) {
  int64_t Scale = 1LL << shift;

  if (isIntN(simm, (C >> shift)) && ((C % Scale) == 0)) {
    ScaledConstant = (C >> shift);
    return true;
  }

  return false;
}

bool RISCVDAGToDAGISel::tryTHEADIndexedLoad(SDNode *Node) {
  LoadSDNode *LD = cast<LoadSDNode>(Node);
  ISD::MemIndexedMode AM = LD->getAddressingMode();
  if (AM == ISD::UNINDEXED || AM == ISD::PRE_DEC || AM == ISD::POST_DEC)
    return false;

  const ConstantSDNode *C = dyn_cast<ConstantSDNode>(LD->getOffset());
  if (!C)
    return false;

  EVT LoadedVT = LD->getMemoryVT();


  int64_t ScaledConstant = 0;
  int64_t Shift = 0;
  int64_t Value = C->getSExtValue();

  if (isScaledConstantInRange(Value, 5, 0, ScaledConstant))
    Shift = 0;
  else if (isScaledConstantInRange(Value, 5, 1, ScaledConstant))
    Shift = 1;
  else if (isScaledConstantInRange(Value, 5, 2, ScaledConstant))
    Shift = 2;
  else if (isScaledConstantInRange(Value, 5, 3, ScaledConstant))
    Shift = 3;
  else
    return false;

  auto Ext = LD->getExtensionType();

  unsigned Opcode = 0;
  if (LoadedVT == MVT::i8 && AM == ISD::PRE_INC)
    Opcode = (Ext == ISD::ZEXTLOAD) ? RISCV::LBUIB : RISCV::LBIB;
  else if (LoadedVT == MVT::i8 && AM == ISD::POST_INC)
    Opcode = (Ext == ISD::ZEXTLOAD) ? RISCV::LBUIA : RISCV::LBIA;
  else if (LoadedVT == MVT::i16 && AM == ISD::PRE_INC)
    Opcode = (Ext == ISD::ZEXTLOAD) ? RISCV::LHUIB : RISCV::LHIB;
  else if (LoadedVT == MVT::i16 && AM == ISD::POST_INC)
    Opcode = (Ext == ISD::ZEXTLOAD) ? RISCV::LHUIA : RISCV::LHIA;
  else if (LoadedVT == MVT::i32 && AM == ISD::PRE_INC)
    Opcode = (Ext == ISD::ZEXTLOAD) ? RISCV::LWUIB : RISCV::LWIB;
  else if (LoadedVT == MVT::i32 && AM == ISD::POST_INC)
    Opcode = (Ext == ISD::ZEXTLOAD) ? RISCV::LWUIA : RISCV::LWIA;
  else if (LoadedVT == MVT::i64 && AM == ISD::PRE_INC)
    Opcode = RISCV::LDIB;
  else if (LoadedVT == MVT::i64 && AM == ISD::POST_INC)
    Opcode = RISCV::LDIA;
  else
    return false;

  SDValue Chain = LD->getChain();
  SDValue Base = LD->getBasePtr();
  auto Ty = LD->getOffset().getValueType();
  SDValue Ops[] = {Base,
                   CurDAG->getTargetConstant(ScaledConstant, SDLoc(Node), Ty),
                   CurDAG->getTargetConstant(Shift, SDLoc(Node), Ty), Chain};
  SDNode *New = CurDAG->getMachineNode(Opcode, SDLoc(Node), LD->getValueType(0),
                                       LD->getValueType(1), MVT::Other, Ops);

  MachineMemOperand *MemOp = cast<MemSDNode>(Node)->getMemOperand();
  CurDAG->setNodeMemRefs(cast<MachineSDNode>(New), {MemOp});

  ReplaceNode(Node, New);

  return true;
}
