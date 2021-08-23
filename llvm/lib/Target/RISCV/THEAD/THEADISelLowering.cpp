bool RISCVTargetLowering::getPreIndexedAddressParts(SDNode *N, SDValue &Base,
                                                    SDValue &Offset,
                                                    ISD::MemIndexedMode &AM,
                                                    SelectionDAG &DAG) const {
  EVT VT;
  SDValue Ptr;
  if (LoadSDNode *LD = dyn_cast<LoadSDNode>(N)) {
    VT = LD->getMemoryVT();
    Ptr = LD->getBasePtr();
  } else if (StoreSDNode *ST = dyn_cast<StoreSDNode>(N)) {
    VT = ST->getMemoryVT();
    Ptr = ST->getBasePtr();
  } else
    return false;

  if (!getIndexedAddressParts(Ptr.getNode(), Base, Offset, AM, DAG))
    return false;

  AM = ISD::PRE_INC;

  return true;
}

bool RISCVTargetLowering::getPostIndexedAddressParts(SDNode *N, SDNode *Op,
                                                     SDValue &Base,
                                                     SDValue &Offset,
                                                     ISD::MemIndexedMode &AM,
                                                     SelectionDAG &DAG) const {
  EVT VT;
  SDValue Ptr;
  if (LoadSDNode *LD = dyn_cast<LoadSDNode>(N)) {
    VT = LD->getMemoryVT();
    Ptr = LD->getBasePtr();
  } else if (StoreSDNode *ST = dyn_cast<StoreSDNode>(N)) {
    VT = ST->getMemoryVT();
    Ptr = ST->getBasePtr();
  } else
    return false;

  if (!getIndexedAddressParts(Op, Base, Offset, AM, DAG))
    return false;
  // Post-indexing updates the base, so it's not a valid transform
  // if that's not the same as the load's pointer.
  if (Ptr != Base)
    return false;

  AM = ISD::POST_INC;

  return true;
}

static bool isLegalImmRange(int64_t V, unsigned shiftRange, int64_t simm) {

  for (unsigned i = 0; i < shiftRange; i++) {
    int64_t Scale = 1LL << i;

    if (isIntN(simm, (V >> i)) && ((V % Scale) == 0))
      return true;
  }

  return false;
}

bool RISCVTargetLowering::getIndexedAddressParts(SDNode *Op, SDValue &Base,
                                                 SDValue &Offset,
                                                 ISD::MemIndexedMode &AM,
                                                 SelectionDAG &DAG) const {
  if (Op->getOpcode() != ISD::ADD && Op->getOpcode() != ISD::SUB)
    return false;

  Base = Op->getOperand(0);
  // All of the indexed addressing mode instructions take a
  // 5 bit signed scaled constant and a scale constant
  if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(Op->getOperand(1))) {
    int64_t RHSC = RHS->getSExtValue();
    if (Op->getOpcode() == ISD::SUB)
      RHSC = -RHSC;

    if (!isLegalImmRange(RHSC, 4, 5))
      return false;

    Offset = DAG.getConstant(RHSC, SDLoc(Op), Op->getOperand(1).getValueType());

    return true;
  }
  return false;
}

bool RISCVTargetLowering::THEADReplaceNodeResults(
    SDNode *N, SmallVectorImpl<SDValue> &Results, SelectionDAG &DAG) const {
  SDLoc DL(N);
  switch (N->getOpcode()) {
  default:
    return false;
  case ISD::LOAD: {
    assert(SDValue(N, 0).getValueType() == MVT::i128 &&
           "unexpected load's value type");
    LoadSDNode *LoadNode = cast<LoadSDNode>(N);

    SDValue Result = DAG.getMemIntrinsicNode(
        RISCVISD::LDD, SDLoc(N),
        DAG.getVTList({MVT::i64, MVT::i64, MVT::Other}),
        {LoadNode->getChain(), LoadNode->getBasePtr()}, LoadNode->getMemoryVT(),
        LoadNode->getMemOperand());

    SDValue Pair = DAG.getNode(ISD::BUILD_PAIR, SDLoc(N), MVT::i128,
                               Result.getValue(0), Result.getValue(1));
    Results.append({Pair, Result.getValue(2) /* Chain */});
    return true;
  }
  }
}

static SDValue combineDoubleLS(SelectionDAG &DAG, LSBaseSDNode *BaseNode,
                               LSBaseSDNode *LDSTNode, uint64_t Imm) {
  MachineFunction &MF = DAG.getMachineFunction();
  auto MemVT = BaseNode->getMemoryVT();
  auto *MMO = BaseNode->getMemOperand();
  auto *NewMMO = MF.getMachineMemOperand(MMO, MMO->getPointerInfo(),
                                         MemVT == MVT::i32 ? 8 : 16);
  unsigned OpNum = BaseNode->getOpcode() == ISD::LOAD ? 1 : 2;

  if (BaseNode->getOpcode() == ISD::LOAD) {
    auto Ext = cast<LoadSDNode>(BaseNode)->getExtensionType();
    unsigned Opcode =
        (MemVT == MVT::i32)
            ? Ext == ISD::ZEXTLOAD ? RISCVISD::LWUD : RISCVISD::LWD
            : RISCVISD::LDD;

    auto BasePtr = Imm ? BaseNode->getOperand(OpNum)->getOperand(0)
                       : BaseNode->getOperand(OpNum);

    SDValue Result = DAG.getMemIntrinsicNode(
        Opcode, SDLoc(BaseNode),
        DAG.getVTList({MVT::i64, MVT::i64, MVT::Other}),
        {BaseNode->getChain(), BasePtr,
         DAG.getConstant(Imm, SDLoc(BaseNode), MVT::i64)},
        MemVT == MVT::i32 ? MVT::i64 : MVT::i128, NewMMO);

    SDValue Result0 = Result.getValue(0);
    SDValue Result1 = Result.getValue(1);
    SDValue Result2 = Result.getValue(2);

    SDValue Node1 = DAG.getMergeValues({Result0, Result2}, SDLoc(BaseNode));
    SDValue Node2 = DAG.getMergeValues({Result1, Result2}, SDLoc(LDSTNode));

    DAG.ReplaceAllUsesWith(LDSTNode, Node2.getNode());
    return Node1;
  } else {
    unsigned Opcode = (MemVT == MVT::i32) ? RISCVISD::SWD : RISCVISD::SDD;

    auto BasePtr = Imm ? BaseNode->getOperand(OpNum)->getOperand(0)
                       : BaseNode->getOperand(OpNum);

    SDValue Result = DAG.getMemIntrinsicNode(
        Opcode, SDLoc(BaseNode), DAG.getVTList(MVT::Other),
        {BaseNode->getChain(), BaseNode->getOperand(1), LDSTNode->getOperand(1),
         BasePtr, DAG.getConstant(Imm, SDLoc(BaseNode), MVT::i64)},
        MemVT == MVT::i32 ? MVT::i64 : MVT::i128, NewMMO);

    DAG.ReplaceAllUsesWith(LDSTNode, Result.getNode());
    return Result;
  }
}

SDValue RISCVTargetLowering::PerformTHEADCombineLS(SDNode *N,
                                                   DAGCombinerInfo &DCI) const {
  SelectionDAG &DAG = DCI.DAG;
  LSBaseSDNode *BaseNode = cast<LSBaseSDNode>(N);
  auto MemVT = BaseNode->getMemoryVT();
  unsigned OpNum = BaseNode->getOpcode() == ISD::LOAD ? 1 : 2;

  if (BaseNode->isVolatile() || !BaseNode->isSimple() || BaseNode->isIndexed())
    return SDValue();

  auto Chain = N->getOperand(0);

  for (SDNode::use_iterator UI = Chain->use_begin(), UE = Chain->use_end();
       UI != UE; ++UI) {
    SDUse &Use = UI.getUse();
    if (Use.getUser() != N && Use.getResNo() == 0 &&
        Use.getUser()->getOpcode() == N->getOpcode()) {

      LSBaseSDNode *LDSTNode = cast<LSBaseSDNode>(Use.getUser());

      if (LDSTNode->isVolatile() || !LDSTNode->isSimple() ||
          LDSTNode->isIndexed())
        continue;

      if (BaseNode->getOpcode() == ISD::LOAD)
        if (cast<LoadSDNode>(LDSTNode)->getExtensionType() !=
            cast<LoadSDNode>(BaseNode)->getExtensionType())
          continue;

      if (BaseNode->getMemoryVT() != LDSTNode->getMemoryVT())
        continue;

      if (BaseNode->hasPredecessor(LDSTNode) ||
          LDSTNode->hasPredecessor(BaseNode))
        continue;

      auto BaseOpcode = BaseNode->getOperand(OpNum)->getOpcode();
      auto LDSTOpcode = LDSTNode->getOperand(OpNum)->getOpcode();

      if (BaseOpcode == ISD::ADD && LDSTOpcode == ISD::ADD &&
          LDSTNode->getOperand(OpNum)->getOperand(0) ==
              BaseNode->getOperand(OpNum)->getOperand(0)) {
        auto *C1 = dyn_cast<ConstantSDNode>(
            BaseNode->getOperand(OpNum)->getOperand(1));
        auto *C2 = dyn_cast<ConstantSDNode>(
            LDSTNode->getOperand(OpNum)->getOperand(1));

        if (!C1 || !C2)
          continue;

        if (MemVT == MVT::i32 &&
            ((C1->getZExtValue() + 4) == C2->getZExtValue()) &&
            isShiftedUInt<2, 3>(C1->getZExtValue()))
          return combineDoubleLS(DAG, BaseNode, LDSTNode, C1->getZExtValue());
        else if (MemVT == MVT::i64 &&
                 ((C1->getZExtValue() + 8) == C2->getZExtValue()) &&
                 isShiftedUInt<2, 4>(C1->getZExtValue()))
          return combineDoubleLS(DAG, BaseNode, LDSTNode, C1->getZExtValue());
        else
          continue;
      } else if (LDSTOpcode == ISD::ADD &&
                 LDSTNode->getOperand(OpNum)->getOperand(0) ==
                     BaseNode->getOperand(OpNum)) {
        auto *C2 = dyn_cast<ConstantSDNode>(
            LDSTNode->getOperand(OpNum)->getOperand(1));
        if (!C2)
          continue;

        if (MemVT == MVT::i32 && C2->getZExtValue() == 4)
          return combineDoubleLS(DAG, BaseNode, LDSTNode, 0);
        else if (MemVT == MVT::i64 && C2->getZExtValue() == 8)
          return combineDoubleLS(DAG, BaseNode, LDSTNode, 0);
        else
          continue;
      } else {
        continue;
      }
    }
  }

  return SDValue();
}

SDValue
RISCVTargetLowering::PerformTHEADDAGCombine(SDNode *N,
                                            DAGCombinerInfo &DCI) const {
  switch (N->getOpcode()) {
  default:
    break;
  case ISD::LOAD:
  case ISD::STORE: {
    if (!DCI.isAfterLegalizeDAG())
      return SDValue();

    return PerformTHEADCombineLS(N, DCI);
  }
  }

  return SDValue();
}
