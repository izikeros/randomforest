import random
import sequtils
import data_types

# Split samples based on given feature and threshold value
proc test_split*(index: int, value: float, dataset: DataSet): (DataSet, DataSet) =
    var 
        left: DataSet
        right: DataSet

    # TODO: split to separate features and labels variables can be replaced with some unzip/zip?
    let features = dataset[0]
    let labels = dataset[1]

    # decide each sample (row) if it's feature of interest if below or above the threshold 
    for labeled_sample in zip(features, labels):
        let row: seq[float] = labeled_sample[0]
        let l: char = labeled_sample[1]
        if row[index] < value:
            left[0].add(row)
            left[1].add(l)
        else:
            right[0].add(row)
            right[1].add(l)
    result = (left, right)

proc group_weighted_gini*(group: DataSet, classes: seq[char], n_samples: int): float {.noSideEffect.}  =
    let 
        size = group[1].len    
        group_gini: float = 0.0

    var 
        p: float = 0.0
        score: float = 0.0
        gini: float = 0.0

    if size > 0:
        # score the group based on the score for each class
        # TODO: consider using CounterSet from tables
        for class_val in classes:
            p = float(count(group[1], class_val)) / size.float
            score += p * p
        # weight the group score by its relative size
        gini += (1.0 - score) * (size / n_samples)
    result = gini


proc gini_index*(groups: (DataSet, DataSet), classes: seq[char]): float =
# Calculate the Gini index for a split dataset    
    # count all samples at split point
    var n_samples: int
    n_samples = groups[0][1].len
    n_samples += groups[1][1].len
    var cl: seq[char] = @['A','B']  # FIXME
    # sum weighted Gini index for each group
    result = group_weighted_gini(groups[0], classes=cl, n_samples)
    result += group_weighted_gini(groups[1], classes=cl, n_samples)

# proc get_split(dataset: seq[seq[float]], n_rf_features: int, labels: seq[string]): tuple =
#     # make list of feature indices that we will make split on
    
#     const MAX_IDX = 999
#     const MAX_VAL = 999
#     const MAX_SCORE = 999

#     var 
#         b_index = 999
#         b_value = 999
#         b_score = 999
#         b_groups = @[]
#         i_feature: int
    
#     let n_features = 100

#     let feature_matrix = dataset[0]
    
#     # shuffle order of features
#     let feature_idx = toSeq(1 .. n_features)
    
#     # limit number of features taken as split points
#     feature_idx = feature_idx[1:n_rf_features]
#     for f_idx in feature_idx:
#         for row in feature_matrix:
#             var groups = test_split(index, row[index], dataset)


# def get_split(dataset, n_features):
# class_values = list(set(row[-1] for row in dataset))
# b_index, b_value, b_score, b_groups = 999, 999, 999, None
# features = list()
# while len(features) < n_features:
# 	index = randrange(len(dataset[0])-1)
# 	if index not in features:
# 		features.append(index)
# for index in features:
# 	for row in dataset:
# 		groups = test_split(index, row[index], dataset)
# 		gini = gini_index(groups, class_values)
# 		if gini < b_score:
# 			b_index, b_value, b_score, b_groups = index, row[index], gini, groups
# return {'index':b_index, 'value':b_value, 'groups':b_groups}