bool THEADReplaceNodeResults(SDNode *N, SmallVectorImpl<SDValue> &Results,
                             SelectionDAG &DAG) const;

SDValue PerformTHEADCombineLS(SDNode *N, DAGCombinerInfo &DCI) const;

SDValue PerformTHEADDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const;

public:
bool getPreIndexedAddressParts(SDNode *N, SDValue &Base, SDValue &Offset,
                               ISD::MemIndexedMode &AM,
                               SelectionDAG &DAG) const override;
bool getPostIndexedAddressParts(SDNode *N, SDNode *Op, SDValue &Base,
                                SDValue &Offset, ISD::MemIndexedMode &AM,
                                SelectionDAG &DAG) const override;
bool getIndexedAddressParts(SDNode *Op, SDValue &Base, SDValue &Offset,
                            ISD::MemIndexedMode &AM, SelectionDAG &DAG) const;
