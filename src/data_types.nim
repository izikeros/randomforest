type
    DataRow* = seq[float]
    DataCol* = seq[float]
    DataLol* = seq[DataRow]
    DataLoc* = seq[DataCol]
    DataSet* = (seq[DataRow], seq[char])