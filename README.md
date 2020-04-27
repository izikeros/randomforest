# Random forest classifier

<!--
![[CircleCI](https://circleci.com/gh/izikeros/randomforest.svg?style=svg)
[![Status](https://img.shields.io/badge/status-beta-orange.svg[badge])]()
[![License](:https://img.shields.io/badge/License-GPL%20v3-blue.svg[License])]()
-->
Nim implementation of RandomForestClassifier. The interface is a subset of Python's scikit-learn `sklearn.ensemble.RandomForestClassifier`

## Requirements

nim>=1.0

## Installation

```sh
nimble install randomforest
```

## Usage

```nim
import randomforest
clf = RandomForestClassifier(n_estimators=10, criterion="gini")
clf.fit(X_train, y_train)
y = clf.predict(X_test)
```

## Credits

Thank you Jason Brownlee for the article [How to Implement Random Forest From Scratch in Python](https://machinelearningmastery.com/implement-random-forest-scratch-python/) - this implementation was inspired by approach used in the article.

## Related projects

[DecisionTreeNim](https://github.com/Michedev/DecisionTreeNim) - Nim package for decision trees and random forest
[scikit-learn](https://scikit-learn.org/) - Machine learning library for Python - used as reference implementation.

## License

[GPL-3](LICENSE) [Krystian Safjan](https://safjan.com/).

