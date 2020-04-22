import unittest
from ../src/random_forest import RandomForestClassifier

suite "Random forest":
    test "instantinate":
        let n_estimators: int = 10
        let criterion: string = "gini"
        let rf = RandomForestClassifier(n_estimators: n_estimators, criterion: criterion)
        check rf.n_estimators == n_estimators
        check rf.criterion == "gini"

