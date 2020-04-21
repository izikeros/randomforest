import helpers
# from streams import newFileStream
# import parsecsv
# from os import paramStr
# import math
# from strutils import parseFloat, strip
from random import randomize, shuffle, initRand
from sequtils import concat


type
    DataRow = seq[float]
    DataCol = seq[float]
    DataLol = seq[DataRow]
    DataLoc = seq[DataCol]
    DataSet = (seq[DataRow], seq[char])



# Evaluate an algorithm using a cross validation split
# proc evaluate_algorithm*(dataset: DataSet, algorithm: procCall, n_folds: int):
proc evaluate_algorithm*(dataset: DataSet, n_folds: int): seq[float] =
    let folds: seq[DataSet] = cross_validation_split(dataset, n_folds)
    var scores: seq[float] = @[]
    var out_train_set: DataSet

    for test_fold_idx in 0 .. folds.len-1:
        var train_set: seq[DataSet] = folds
        echo "--"
        echo train_set
        train_set.delete(test_fold_idx)
        echo train_set
        var r = merge_folds(folds)
        # for train_fold in train_set:
        #      train_set = concat(out_train_set, train_fold)
        # test_set = fold
    # 	predicted = algorithm(train_set, test_set, *args)
    # 	actual = [row[-1] for row in fold]
    # 	accuracy = accuracy_metric(actual, predicted)
        # let accuracy = 0.8
        # scores.append(accuracy)
    result = scores

# proc get_split(dataset: seq[seq[float]], n_rf_features: int, labels: seq[string]): tuple =
#     # make list of feature indices that we will make split on
#     const MAX_IDX = 999
#     const MAX_VAL = 999
#     const MAX_SCORE = 999

#     var 
#         features: seq[int]
#         b_index = 999
#         b_value = 999
#         b_score = 999
#         b_groups = @[]
#         i_feature: int
    
#     # while len(features) < n_rf_features:
#     # # shuffle order of features
#     #     i_feature = rand(len(dataset[0])-1)
#     #     if i_feature not in features:
#     #         features.append(i_feature)
#     return true


if isMainModule:
    let file_name: string = "temp.csv"
    let dataset = read_data_from_csv(file_name=file_name, has_header=false)
    echo evaluate_algorithm(dataset, n_folds=2)