import data_types
import split

# Build a decision tree
proc build_tree*(train: DataSet, max_depth: int, min_size: int, n_features: int): Split = 
    let root = get_split(train, n_features)
    split(root, max_depth, min_size, n_features, 1)
    result = root