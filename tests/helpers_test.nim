import unittest
import ../src/helpers

type
  DataRow = seq[float64]
  DataLol = seq[DataRow]
  DataSet = (DataLol, seq[char])

let r1: DataRow = @[1.0, 1.1]
let r2: DataRow = @[2.0, 2.1]
let r3: DataRow = @[3.0, 3.1]
let r4: DataRow = @[4.0, 4.1]
let r5: DataRow = @[3.0, 3.1]
let r6: DataRow = @[4.0, 4.1]
let l4: seq[char] = @['A','B','C','D']
let l6: seq[char] = @['A','B','C','D','E','F']

suite "merge folds":
  test "2 folds": 
    let f1 =  (@[r1,r2], @['A','B'])
    let f2 =  (@[r3,r4], @['C','D'])
    check merge_folds(@[f1,f2]) == (@[r1,r2,r3,r4], l4)
  test "3 folds": 
    let f1 =  (@[r1,r2], @['A','B'])
    let f2 =  (@[r3,r4], @['C','D'])
    let f3 =  (@[r5,r6], @['E','F'])
    check merge_folds(@[f1,f2,f3]) == (@[r1,r2,r3,r4,r5,r6], l6)

suite "cross-validation split":
  test "2 folds":    
    var data_set: DataSet = (@[r1,r2,r3,r4], l4)
    var folds = cross_validation_split(data_set, n_folds=2, seed=1)
    # for f in folds: echo f
    check folds[0] == (@[@[4.0, 4.1], @[1.0, 1.1]], @['D', 'A'])
    check folds[1] == (@[@[3.0, 3.1], @[2.0, 2.1]], @['C', 'B'])

  test "4 folds":
    var data_set: DataSet = (@[r1,r2,r3,r4], l4)
    var folds = cross_validation_split(data_set, n_folds=4, seed=1)
    # for f in folds: echo f
    check folds[0] == (@[@[4.0, 4.1]], @['D'])
    check folds[1] == (@[@[1.0, 1.1]], @['A'])
    check folds[2] == (@[@[3.0, 3.1]], @['C'])
    check folds[3] == (@[@[2.0, 2.1]], @['B'])

  test "4 folds - different seed":
    var data_set: DataSet = (@[r1,r2,r3,r4], l4)
    var folds = cross_validation_split(data_set, n_folds=4, seed=200)
    # for f in folds: echo f
    check folds[0] == (@[@[3.0, 3.1]], @['C'])
    check folds[1] == (@[@[4.0, 4.1]], @['D'])
    check folds[2] == (@[@[2.0, 2.1]], @['B'])
    check folds[3] == (@[@[1.0, 1.1]], @['A'])

suite "calculate fold size":
  test "basic 10 samples, 5 folds":
    check calculate_fold_size(10,5) == 2
  test "Not even division":
    check calculate_fold_size(10,6) == 1
  test "More folds than samples - return n_folds equal to n_samples":
    check calculate_fold_size(10,20) == 10

suite "read csv data":
  setup:
    # Prepare a file
    const tmp_file: string = "/tmp/rf_temp.csv"  
    const 
      content = """1,2,3,4,F
      10,20,30,40,M
      100,200,300,400,F
"""
      n_samples = 3
      n_features = 4
    writeFile(tmp_file, content)

  test "number of samples ok":
    let r = read_data_from_csv(tmp_file)
    let data = r[0]
    check data.len == n_samples

  test "number of labels ok":
    let r = read_data_from_csv(tmp_file)
    let labels = r[1]
    check labels.len == n_samples

  test "number of features ok":
    let r = read_data_from_csv(tmp_file)
    let data = r[0]
    check data[0].len == n_features