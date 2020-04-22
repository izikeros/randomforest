import ../src/data_types
import unittest
import ../src/split

let
    r1: DataRow = @[3.0, 2.1, 10.0, 3.0, 7.0]
    r2: DataRow = @[6.0, 4.0, 5.1,  8.0, 5.0]
    l1: char = 'A'
    l2: char = 'B'
    dataset = (@[r1, r2], @[l1,l2])
    empty: (seq[DataRow], seq[char]) = (@[], @[])

suite "Group gini":
    test "total: two samples, group: two samples, two classes":
        let g = group_weighted_gini(dataset, @[l1,l2], n_samples=2)
        check g == 0.5

    test "total: four samples, group: two samples, two classes":
        let g = group_weighted_gini(dataset, @[l1,l2], n_samples=4)
        check g == 0.25

suite "Test split":
    test "one above, one below: feature_id:0 val:4.0":
        let res = test_split(index=0, value=4.0, dataset=dataset)
        let lt = res[0]
        let ge = res[1]
        check lt == (@[r1], @[l1])
        check ge == (@[r2], @[l2])

    test "one equal, one below: feature_id:0 val:6.0":
        let res = test_split(index=0, value=6.0, dataset=dataset)
        let lt = res[0]
        let ge = res[1]
        check lt == (@[r1], @[l1])
        check ge == (@[r2], @[l2])
        
    test "one above, one below: feature_id:2 val:9.0":
        let res = test_split(index=2, value=9.0, dataset=dataset)
        let lt = res[0]
        let ge = res[1]
        check lt == (@[r2], @[l2])
        check ge == (@[r1], @[l1])

    test "none lower: feature_id:0 val:3.0":
        let res = test_split(index=0, value=3.0, dataset=dataset)
        let lt = res[0]
        let ge = res[1]
        check lt == empty
        check ge == (@[r1,r2], @[l1,l2])

    test "both lower: feature_id:1 val:5.0":
        let res = test_split(index=1, value=5.0, dataset=dataset)
        let lt = res[0]
        let ge = res[1]
        check lt == (@[r1,r2], @[l1,l2])
        check ge == empty