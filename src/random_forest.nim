import utils
# from eval import evaluate_algorithm
from data_types import DataLol

type
    RandomForestClassifier* = ref object of RootObj
        n_estimators*: int
        criterion*: string

proc fit*(clf: RandomForestClassifier, x_train: DataLol, y_train: seq[char]): bool =
    result = true
    