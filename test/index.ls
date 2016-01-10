require! \assert
Promise = require \bluebird
{last} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
{
    summary-statistics, parse-date, round1, find-precision, bucketize,
    fold-obj-to-list, fill-intervals-ints, fill-intervals, date-from-object-id, 
    object-id-from-date, to-stacked-area, tco
} = (require \../transformation-context.ls)!
{compile-transformation-sync, compile-transformation} = require \../index.ls

describe \transformation, ->

    transformation-code = """
        result, {a} <- id
        (bucketize 10) result ++ a
    """

    # validate-transformed-result :: a -> P String?
    validate-transformation-function = (transformation-function) ->
        result = transformation-function [2, 12, 24], a: 36
        if result `is-equal-to-object` [0, 10, 20, 40]
            Promise.resolve null 
        else 
            Promise.reject "result be [0, 10, 20, 40] instead of #{result}"

    specify \compile-transformation-sync, ->
        [err, transformation-function] = compile-transformation-sync transformation-code, \livescript
        if !!err 
            Promise.reject err 
        else 
            validate-transformation-function transformation-function
        
    specify \compile-transformation, ->
        transformation-function <- compile-transformation transformation-code, \livescript .then
        validate-transformation-function transformation-function

    specify \summary-statistics, ->
        {avg, sigma, median, length} = summary-statistics [1 to 100]
        assert length == 100

    specify \parse-date, ->
        assert (parse-date '2016-01-01' .get-time!) == 1451606400000

    specify \round1, ->
        assert 1.235 == round1 3, 1.234567890

    specify \find-precision, ->
        assert 4 == find-precision 1.2345

    specify \fold-obj-to-list, ->
        result = fold-obj-to-list do 
            (key, value) -> "#{key}#{value}"
            a: 1, b: 1
        assert result `is-equal-to-object` [\a1, \b1]

    specify \fill-intervals-ints, ->
        assert [[10, 0], [20, 0], [30, 0], [40, 0]] `is-equal-to-object` fill-intervals-ints [[10, 0], [20, 0], [40, 0]]

    specify 'must fill intervals with given value', ->
        assert [[10, 0], [20, 0], [30, 1], [40, 0]] `is-equal-to-object` (fill-intervals-ints [[10, 0], [20, 0], [40, 0]], 1)

    specify \date-from-object-id, ->
        assert 1451606400000 (date-from-object-id object-id-from-date new Date '2016-01-01').get-time!

    specify \bucketize, ->
        assert [0, 10, 20, 40] `is-equal-to-object` ((bucketize 10) [2, 12, 24, 36])

    specify \fill-intervals, ->
        assert [[10, 0], [20, 0], [30, 0], [40, 0]] `is-equal-to-object` fill-intervals [[10, 0], [20, 0], [40, 0]]

    specify \tco, ->

        # sum :: Int -> Int -> Int
        sum = tco (x, y) ->
            if x == 0
                y
            else
                sum x - 1, y + x

        assert 5000050000 == sum 100000, 0

    specify \to-stacked-area, ->
        population-trend = 
            * label: \asia
              year: 1900
              population: 2000
            * label: \africa
              year: 1900
              population: 1000
            * label: \asia
              year: 2000
              population: 20000
            * label: \africa
              year: 2000
              population: 10000

        f = (continent, year, population) ->
            return
                * year
                * population
                * label: continent
                  year: year
                  population: population
                ...

        correct-stack-area = 
            * key: \asia
              values: 
                * f \asia, 1900, 2000
                * f \asia, 2000, 20000
              total: 22000
            * key: \africa
              values:
                * f \africa, 1900, 1000
                * f \africa, 2000, 10000
              total: 11000

        stack-area = to-stacked-area do 
            (.label)
            (.year)
            (.population)
            population-trend
        
        assert correct-stack-area `is-equal-to-object` stack-area

