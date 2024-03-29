import random
import sequtils
import data_types
import tables
import utils
import strformat

const
    MAX_IDX = 999
    MAX_VAL = 999.0
    MAX_SCORE = 999.0
    verbose = true
type
    SplitMetrics = enum
        gini = "gini"
        mse = "mse"
        max_enthropy = "entropy"

type
    Node* = ref object of RootObj
        # on which feature to split
        feature_idx*: int
        # what value use to split samples
        value*: float32        
        # children
        left*: Node
        right*: Node
        isLeaf*: bool    # ? will that be used?
        label*: Label
        metrics_type*: SplitMetrics      # TODO: KS: 2020-04-28: Check, what happens if we use random method at each node - we can produce more trees that vary
        metrics_val*: float32
        leaf_reason*: string

proc display*(node: Node) =
    echo "==========="
    echo fmt"feature: {node.feature_idx}"
    echo fmt"value: {node.value}"
    echo fmt"metrics_type: {node.metrics_type}"
    echo fmt"metrics_val: {node.metrics_val}"
    echo fmt"metrics_val: {node.metrics_val}"
    echo fmt"isLeaf: {node.isLeaf}"
    echo fmt"dominant label: {node.label}"
    echo fmt"leaf_reason: {node.leaf_reason}"
    echo " ............"

proc display_tree*(node: Node, parent:string = "root") =
    if not node.isLeaf:
        let child = fmt"f{node.feature_idx} v{node.value} {rand(100)}"
        if len(parent) > 0:
            echo """"{parent}"->"{child}""""
        display_tree(node.left, child)
        display_tree(node.right, child)
    else:
        let child = fmt"{node.label} {rand(100)}"
        echo fmt""""{parent}"->"{child}""""

proc `==`*(a,b: Node): bool =
    (a.feature_idx == b.feature_idx) and (a.value == b.value) and (a.isLeaf == b.isLeaf) and (a.label == b.label) and (a.metrics_type == b.metrics_type) and (a.metrics_val == b.metrics_val)

## Create a terminal node
proc to_terminal*(node: Node, dataset: DataSet, reason: string): Node = 
    let labels = dataset[1]
    # count labels of the same type
    var labelFrequencies = labels.toCountTable
    # sort
    labelFrequencies.sort
    # labels in the terminal node doesn't have to be homogenous. take most frequent
    let pair = toSeq(labelFrequencies.pairs)[0]
    # return label name as result
    var new_node = node
    new_node.isLeaf = true
    new_node.label = pair[0]
    new_node.leaf_reason = reason
    result = new_node
    if verbose:
        display(new_node)


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

proc group_weighted_gini*(group: DataSet, classes: seq[char], n_samples: int): float32 {.noSideEffect.}  =
    let 
        size = group[1].len    

    var 
        p: float32 = 0.0
        score: float32 = 0.0
        gini: float32 = 0.0

    if size > 0:
        # score the group based on the score for each class
        # TODO: KS: 2020-04-22:  consider using CounterSet from tables
        for class_val in classes:
            p = float32(count(group[1], class_val)) / size.float32
            score += p * p
        # weight the group score by its relative size
        gini += (1.0 - score) * (size / n_samples)
    result = gini


proc gini_index*(groups: (DataSet, DataSet), classes: seq[char]): float32 =
# Calculate the Gini index for a split dataset    
    # count all samples at split point
    var n_samples: int
    n_samples = groups[0][1].len
    n_samples += groups[1][1].len
    # sum weighted Gini index for each group
    result = group_weighted_gini(groups[0], classes=classes, n_samples)
    result += group_weighted_gini(groups[1], classes=classes, n_samples)

proc get_split*(dataset: DataSet, n_rf_features: int): (Node, (DataSet, DataSet)) =
    # make list of feature indices that we will make split on
        
    var 
        best_index = MAX_IDX
        best_value = MAX_VAL
        best_score = MAX_SCORE
        best_groups: (DataSet, DataSet)
        gini: float32

    let 
        feature_matrix = dataset[0]
        n_features = feature_matrix[0].len
        classes = deduplicate(dataset[1])
        # shuffle order of features
    var feature_idx = toSeq(0 .. n_features-1)
    shuffle(feature_idx) # TODO: KS: 2020-04-27: ensure that we control randomization

    doAssert len(feature_matrix[0]) >= n_rf_features

    # limit number of features taken as split points
    for f_idx in countUp(0, n_rf_features-1):
        for row in feature_matrix:
            # echo fmt"Reading {f_idx} from {row}"
            var groups = test_split(f_idx, row[f_idx], dataset)
            gini = gini_index(groups, classes)
            if gini < best_score:
                best_index = f_idx
                best_value = row[f_idx]
                best_score = gini
                best_groups = groups
    if verbose:
        echo fmt"found new split: id:{best_index}, v:{best_value}, g:{best_score}"
    result = (
        Node(feature_idx: best_index,value: best_value, metrics_val: best_score),
        best_groups)

## Create child splits for a node or make terminal
proc split*(node: Node, groups: (DataSet, DataSet), max_depth: int, min_size: int, n_rf_features: int, depth: int) =
    let 
        left = groups[0]
        right = groups[1]
    if verbose:
        echo "=== splitting node with groups: ==="
        echo "left:", left
        echo "right:", right
        echo "depth:", depth
    

    # --- stop conditions
    # check for a no split (the other group is empty)
    if (left[1].len == 0) or (right[1].len == 0):
        let dataset: DataSet = merge_folds(@[left, right])
        node.left = to_terminal(node, dataset, reason="no split - empty group")
        node.right = node.left
        if verbose:
            echo "!! stop - no split (one or both groups are empty)"
        return
    # check for max depth
    if depth >= max_depth:
        if verbose:
            echo "!! stop - max depth"
        node.left = to_terminal(node, left, reason="stop - max depth")
        node.right = to_terminal(node, right, reason="stop - max depth")
        return

    # process left child
    if left[1].len <= min_size:
        if verbose:
            echo "!! stop - min size"
        node.left = to_terminal(node, left, reason="stop - min size on the left")
    else:
        if verbose:
            echo fmt"need to split left: {left}"
        let res = get_split(left, n_rf_features)
        node.left=res[0]
        split(node.left,res[1], max_depth, min_size, n_rf_features, depth+1)
    
    # process right child
    if right[0].len <= min_size:
        if verbose:
            echo "!! stop - min size"
        node.right = to_terminal(node, right, reason="stop - max depth on the right")
    else:
        if verbose:
            echo fmt"need to split right: {right}"
        let res = get_split(right, n_rf_features)
        node.right=res[0]
        split(node.right,res[1], max_depth, min_size, n_rf_features, depth+1)


proc to_graphviz*(node: Node, parent:string) =
    if not node.isLeaf:
        let child = fmt"f{node.feature_idx} v{node.value} {rand(100)}"
        if len(parent) > 0:
            echo fmt""""{parent}"->"{child}""""
        display_tree(node.left, child)
        display_tree(node.right, child)
    else:
        let child = fmt"{node.label} {rand(100)}"
        echo fmt""""{parent}"->"{child}""""

