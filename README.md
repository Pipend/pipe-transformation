[![Build Status](https://travis-ci.org/Pipend/pipe-transformation.svg?branch=master)](https://travis-ci.org/Pipend/pipe-transformation)
[![Coverage Status](https://coveralls.io/repos/Pipend/pipe-transformation/badge.svg?branch=master&service=github)](https://coveralls.io/github/Pipend/pipe-transformation?branch=master)

## Installation
* `npm install pipe-transformation`

## Development
* run `gulp` to watch and build changes

* `npm test` to run the unit tests

* `gulp coverage` to run the unit tests & get the code coverage

## Compilation of Transformation code in Pipe

#### Usage
```
{compile-transformation-sync} = require \pipe-transformation
```

#### Functions
* `compile-transformation-sync` : `TransformationCode :: String -> Language :: String -> [Error, (result -> Parameters -> result)]`
> Language can be one of "javascript", "babel" or "livescript"

* `compile-transformation` : `TransformationCode :: String -> Language :: String -> p (result, Parameters -> result)`

## Context for the Transformation layer in Pipe

#### Usage
```
{summary-statistics} = require \pipe-transformation/transformation-context
```

#### Functions
* `summary-statistics` : `[Number] -> {mean :: Number, sigma :: Number, median :: Number, length :: Number}`
 
* `parse-date` : `String -> Date`
 
* `round1` : `NumberOfDecimalPlaces::Int -> Number -> FormattedNumber::Number`
> example: `round1 3, 1.234567890` returns `1.235`

* `find-precision` : `Number -> Int`
> example: `find-precision 1.2345` returns `4`

* `today` : `() -> Date`

* `bucketize` : `Number -> [Number] -> [Int]`
> example: `(bucketize 10) [2, 12, 24, 36]` returns `[0, 10, 20, 40]`

* `fold-obj-to-list` : `(k -> v -> kv) -> Map k v -> [kv]`

* `fill-intervals-ints` : `[[Number ,Number]] -> Int? [[Number, Number]]`

* `fill-range` : `[[Number, Number]], Number, Number, Number, Number -> [[Number, Number]]`

* `fill-intervals` : `[[Number, Number]], Int? -> [[Number, Number]]`

* `to-stacked-area` : `(Item -> String) -> (Item -> Number) -> (Item -> Number) -> [Item] -> [{key :: String, total :: Number, values :: [[Number, Number, Item]]]`
> converts a list of items to a data structure than can be used for plotting a stack area chart

* `from-web-socket` : `String -> Observer -> Subject`

* `date-from-object-id` : `ObjectId :: String -> Date`
> converts a mongodb object id to a javascript date object

* `object-id-from-date` : `Date -> ObjectId :: String`
> converts a javascript data object to a mongodb object id

* `tail-call-optimization` : `Function -> Function`
> more information: https://gist.github.com/Gozala/1697037

