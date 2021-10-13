import sequtils

type
    DataRow* = seq[float]
    DataCol* = seq[float]
    DataLol* = seq[DataRow]
    DataLoc* = seq[DataCol]
    Label*   = char
    DataSet* = (seq[DataRow], seq[Label])

proc get_classes*(dataset: DataSet): seq[Label]=
    deduplicate(dataset[1])