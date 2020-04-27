import parsecsv
from strutils import parseFloat, strip
from random import randomize, shuffle, initRand
from sequtils import toSeq
import sequtils2
import data_types

# TODO: KS: 2020-04-23: rename to merge_datasets
proc merge_folds*(folds: seq[DataSet]): DataSet =
    var new_data: DataLol
    var new_label: seq[Label]
    for f in folds:
        var samples = f[0]
        for sample in samples:
            new_data.add(sample)
        
        var labels = f[1]
        for label in labels:
            new_label.add(label)
    result = (new_data, new_label)

proc read_data_from_csv*(file_name: string, has_header: bool = false): DataSet =    
    var 
        rows: seq[seq[float]]
        labels: seq[Label]

    var p: CsvParser
    p.open(file_name)
    if has_header:
        p.readHeaderRow()

# TODO: KS: 2020-04-21: for future: handle empty rows
    while readRow(p):
        var row: seq[float] = @[]
        for val in items(p.row):
            try:
                row.add(val.strip.parseFloat)
            except:
                labels.add(val)        
        rows.add(row)
    close(p)
    result = (rows, labels)

proc calculate_fold_size*(n_samples: int, n_folds: int): int =
    if n_folds > n_samples: n_samples
    else: int(n_samples / n_folds)


proc cross_validation_split*(dataset: DataSet, n_folds: int, seed: int = 1): seq[DataSet] = 
    var dataset_split: seq[DataSet]
    let n_samples = dataset[0].len
    var fold_size = calculate_fold_size(n_samples, n_folds)
    var data_new: DataLol
    var labels_new: seq[Label]

    var idx:seq[int] = toSeq(0 .. n_samples-1)
    randomize(seed)
    shuffle(idx)

    var cnt: int = 0
    for f in 0 .. n_folds-1:
        var offset = f*fold_size
        while cnt < fold_size:      
            var i_sample = idx[offset + cnt]
            # add features to the fold
            data_new.add(dataset[0][i_sample])
            # add label(s) to the fold
            labels_new.add(dataset[1][i_sample])
            inc(cnt)
        # add completed fold to collection of folds
        dataset_split.add((data_new, labels_new))
        # prepare for creating new fold
        data_new = @[]
        labels_new = @[]
        cnt = 0
    result = dataset_split