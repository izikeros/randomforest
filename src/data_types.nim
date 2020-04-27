type
    DataRow* = seq[float]
    DataCol* = seq[float]
    DataLol* = seq[DataRow]
    DataLoc* = seq[DataCol]
    Label*   = char
    DataSet* = (seq[DataRow], seq[Label])
