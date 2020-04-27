import random
import sequtils
import data_types
import tables
import utils

const
    MAX_IDX = 999
    MAX_VAL = 999.0
    MAX_SCORE = 999.0

type
    Split* = ref object of RootObj
        feature_idx*: int
        value*: float
        groups*: (DataSet, DataSet)
        left*: DataSet
        right*: DataSet

proc to_terminal*(group: DataSet): Label = 
    ## Create a terminal node value
    let labels = group[1]
    
    # count labels of the same type
    var labelFrequencies = labels.toCountTable
    # sort 
    labelFrequencies.sort
    # take most frequent
    let pair = toSeq(labelFrequencies.pairs)[0]
    # return label name as result
    result = pair[0]

# Create child splits for a node or make terminal
proc split*(node: Split, max_depth: int, min_size: int, n_features: int, depth: int) =
    let 
        left = node.groups[0]
        right = node.groups[1]
    echo left
    echo right

    # node.groups = (@[], @[]) # TODO: KS: 2020-04-23: clear groups
    # check for a no split (the other group is empty)
    if (left[1].len == 0) or (right[1].len == 0):
        let f: DataSet = merge_folds(@[left, left])
        node.left = to_terminal(f) # FIXME: KS: 2020-04-24: Need to solve type clarity
        #node.right = node.left
        return
    # # check for max depth
    # if depth >= max_depth:
    #     node.left = to_terminal(left)
    #     node.right = to_terminal(right)
    #     return
    # # process left child
    # if len(left) <= min_size:
    #     node['left'] = to_terminal(left)
    # else:
    #     node['left'] = get_split(left, n_features)
    #     split(node['left'], max_depth, min_size, n_features, depth+1)
#     # process right child
#     if len(right) <= min_size:
#         node['right'] = to_terminal(right)
#     else:
#         node['right'] = get_split(right, n_features)
#         split(node['right'], max_depth, min_size, n_features, depth+1)



# Split samples based on given feature and threshold value
proc test_split*(index: int, value: float, dataset: DataSet): (DataSet, DataSet) =
    var 
        left: DataSet
        right: DataSet

    # TODO: KS: 2020-04-23:  split to separate features and labels variables can be replaced with some unzip/zip?
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
        # TODO: KS: 2020-04-22:  consider using CounterSet from tables
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
    # sum weighted Gini index for each group
    result = group_weighted_gini(groups[0], classes=classes, n_samples)
    result += group_weighted_gini(groups[1], classes=classes, n_samples)


proc get_split*(dataset: DataSet, n_rf_features: int): Split =
    # make list of feature indices that we will make split on

    var 
        b_index = MAX_IDX
        b_value = MAX_VAL
        b_score = MAX_SCORE
        b_groups: (DataSet, DataSet)
        i_feature: int
        gini: float

    let 
        feature_matrix = dataset[0]
        n_features = feature_matrix[0].len
        classes = deduplicate(dataset[1])
        # shuffle order of features
        feature_idx = toSeq(0 .. n_features-1)
    
    # limit number of features taken as split points
    let feature_lim_idx = feature_idx[0 .. n_rf_features-1]
    for f_idx in feature_lim_idx:
        for row in feature_matrix:
            var groups = test_split(f_idx, row[f_idx], dataset)
            gini = gini_index(groups, classes)
            if gini < b_score:
                b_index = f_idx
                b_value = row[f_idx]
                b_score = gini
                b_groups = groups
    result = Split(
        feature_idx: b_index,
        value: b_value,
        groups: b_groups)