import data_types
import utils

# Evaluate an algorithm using a cross validation split
proc evaluate_algorithm*(dataset: DataSet, n_folds: int): seq[float] =
    let folds: seq[DataSet] = cross_validation_split(dataset, n_folds)
    var scores: seq[float] = @[]
    var out_train_set: DataSet

    for test_fold_idx in 0 .. folds.len-1:
        var train_folds: seq[DataSet] = folds
        train_folds.delete(test_fold_idx)
        var r = merge_folds(train_folds)
        var test_set = folds[test_fold_idx]
        # model = RandomForest()
        # predicted = algorithm(train_set, test_set, *args)
        # 	actual = [row[-1] for row in fold]
        # 	accuracy = accuracy_metric(actual, predicted)
        # let accuracy = 0.8
        # scores.append(accuracy)
    result = scores

if isMainModule:
    let file_name: string = "temp.csv"
    let dataset = read_data_from_csv(file_name=file_name, has_header=false)
    # echo evaluate_algorithm(dataset, n_folds=2)
