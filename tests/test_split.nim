import ../src/data_types
import unittest
import ../src/split
import ../src/utils

let
    r1: DataRow = @[3.0, 2.1, 10.0, 3.0, 7.0]
    # r1: DataRow = @[8.0, 2.1, 10.0, 3.0, 7.0]
    r2: DataRow = @[6.0, 4.0, 5.1, 8.0, 5.0]
    r3: DataRow = @[13.0, 12.1, 10.0, 3.0, 7.0]
    r4: DataRow = @[16.0, 14.0, 5.1, 8.0, 5.0]

    l1: Label = 'A'
    l2: Label = 'B'
    dataset = (@[r1, r2], @[l1, l2])
    dataset4 = (@[r1, r2, r3, r4], @[l1, l2, l2, l2])
    empty: (seq[DataRow], seq[Label]) = (@[], @[])

suite "Split":
    # test "Too many features to build the tree - raise AssertionError":
    #     let groups = (dataset,dataset4)
    #     let s = Node()
    #     expect(AssertionError):
    #         split(node=s, groups=groups, max_depth=10, min_size=1, n_rf_features=10, depth=0)

    test "base":
        # let groups = (dataset,dataset4)
        # let s = Node()
        let res = get_split(merge_folds(@[dataset,dataset4]), n_rf_features=5)
        let s = res[0]
        let groups = res[1]
        split(node=s, groups=groups, max_depth=10, min_size=0, n_rf_features=5, depth=0)
        echo "results"
        display(s)
    #     # echo "digraph G {"
    #     # display_tree(s,"")
    #     # echo "}"
    #     # echo dataset4
    test "left group is empty":
        let s = Node()
        let groups = (empty, dataset4)
        split(node=s, groups=groups, max_depth=10, min_size=0, n_rf_features=5, depth=0)
        # let classes = dataset4.get_classes
        # let gini_val = gini_index(groups=groups, classes=classes)
        # s.metrics_val = gini_val
        display(s)
        check s.label == 'B'

    test "right group is empty":
        let s = Node()
        let groups = (empty, dataset4)
        split(node=s, groups=groups, max_depth=10, min_size=0, n_rf_features=5, depth=0)
        display(s)
        check s.label == 'B'

    # test "stop on max depth":
    #     echo ""
    # test "process left child":
    #     echo ""
    # test "process right child":
    #     echo ""


# suite "To terminal":
#     test "base":        
#         let node = to_terminal(Node(), dataset4) 
#         let expected = Node(isLeaf: true, label: 'B')
#         # display(node)
#         # display(expected)
#         check node == expected

# suite "Group gini":
#     test "total: two samples, group: two samples, two classes":
#         let g = group_weighted_gini(dataset, @[l1,l2], n_samples=2)
#         check g == 0.5

#     test "total: four samples, group: two samples, two classes":
#         let g = group_weighted_gini(dataset, @[l1,l2], n_samples=4)
#         check g == 0.25

# suite "Test split":
#     test "one above, one below: feature_id:0 val:4.0":
#         let res = test_split(index=0, value=4.0, dataset=dataset)
#         let lt = res[0]
#         let ge = res[1]
#         check lt == (@[r1], @[l1])
#         check ge == (@[r2], @[l2])

#     test "one equal, one below: feature_id:0 val:6.0":
#         let res = test_split(index=0, value=6.0, dataset=dataset)
#         let lt = res[0]
#         let ge = res[1]
#         check lt == (@[r1], @[l1])
#         check ge == (@[r2], @[l2])

#     test "one above, one below: feature_id:2 val:9.0":
#         let res = test_split(index=2, value=9.0, dataset=dataset)
#         let lt = res[0]
#         let ge = res[1]
#         check lt == (@[r2], @[l2])
#         check ge == (@[r1], @[l1])

#     test "none lower: feature_id:0 val:3.0":
#         let res = test_split(index=0, value=3.0, dataset=dataset)
#         let lt = res[0]
#         let ge = res[1]
#         check lt == empty
#         check ge == (@[r1,r2], @[l1,l2])

#     test "both lower: feature_id:1 val:5.0":
#         let res = test_split(index=1, value=5.0, dataset=dataset)
#         let lt = res[0]
#         let ge = res[1]
#         check lt == (@[r1,r2], @[l1,l2])
#         check ge == empty

# suite "Get split":
#     test "is running":
#         let res = get_split(dataset4, n_rf_features=5)
#         let node = res[0]
#         let groups = res[1]
#         # TODO: KS: 2020-04-23: add tests to check correctness


# suite "Display node":
#     test "display node":
#         display(Node())

#     test "display leaf":
#         display(Node(isLeaf: true, label: 'B'))

# # TODO: KS: 2020-05-03: Check sklearn implementation of to graphviz
# # suite "To graphviz":
# #     test "base":
    