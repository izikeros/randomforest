# Random forest classifier in NIM
<!--
![[CircleCI](https://circleci.com/gh/izikeros/randomforest.svg?style=svg)
[![Status](https://img.shields.io/badge/status-beta-orange.svg[badge])]()
[![License](:https://img.shields.io/badge/License-GPL%20v3-blue.svg[License])]()
-->
RandomForestClassifier interface is a subset of Python's scikit-learn `sklearn.ensemble.RandomForestClassifier`

# Installation
```sh
nimble install randomforest
```

# Usage
```nim
import randomforest
clf = RandomForest(n_estimators=10, criterion="gini")
clf.fit(X_train, y_train)
y = clf.predict(X_test)
```

