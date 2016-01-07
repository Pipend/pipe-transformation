require! \moment

# prelude
{Obj, average, concat-map, drop, each, filter, find, fold, foldr1, gcd, id, keys, map, maximum, 
minimum, obj-to-pairs, sort, sum, tail, take, unique, mod, round, sort-by, group-by, floor, ceiling, mean, sqrt} = require \prelude-ls

{transpose} = require \prelude-extension

Rx = require \rx
io = require \socket.io-client

# [Number] -> {mean, sigma, median, length}
summary-statistics = (xs) ->
    ys = sort xs
    length = ys.length
    length1 = length - 1
    median = if ys.length % 2 == 0 then mean [ys[floor <| ys.length1/2], ys[ceiling <| ys.length1/2]] else ys[ys.length1/2]

    {x, x2} = xs |> fold do
        (acc, x) ->  {
           x: acc.x + x
           x2: acc.x2 + x * x
           index: acc.index + 1
        }
        {x: 0, x2: 0, index: 0}

    avg = x / xs.length
    sigma = sqrt (x2 / xs.length - avg * avg)
    {
        avg
        sigma
        median: median
        length: xs.length
    }

# parse-date :: String -> Date
parse-date = (s) -> new Date s

# today :: a -> Date
today = -> ((moment!start-of \day .format "YYYY-MM-DDT00:00:00.000") + \Z) |> parse-date

# round1 :: Int -> Number -> Number
round1 = (n, x) -->
    if n == 0 then Math.round x else (Math.round x * (n = Math.pow 10, n)) / n

# find-precision :: Number -> Int
find-precision = (n) ->
    f = (p) ->
        if (round1 p, n) == n then 
            p 
        else if p > 15 then 16 else f (p + 1)
    f 0

# bucketize :: Number -> [Number] -> [Int]
bucketize = (size) ->
    s2 = size / 2
    p = find-precision size
    map (round1 p) . (-> it - it `mod` size) . (+ s2)

# (k -> v -> kv) -> Map k v -> [kv]
fold-obj-to-list = (merger, object) -->
  [merger key, value for key, value of object]

# fill-intervals-ints :: [[Number ,Number]] -> Int? [[Number, Number]]
fill-intervals-ints = (list, default-value = 0) ->
    x-scale = list |> map (.0)
    fill-range do 
        list
        minimum x-scale
        maximum x-scale
        null
        default-value

# fill-range :: [[Number, Number]], Number, Number, Number, Number -> [[Number, Number]]
fill-range = (list, min-x-scale, max-x-scale, x-step, default-value = 0) ->
    
    x-step = x-step or (list 
        |> map (.0) 
        |> foldr1 gcd)

    [0 to (max-x-scale - min-x-scale) / x-step] |> map (i) ->
        x-value = min-x-scale + x-step * i
        [, y-value]? = list |> find ([x]) -> x == x-value
        [x-value, y-value ? default-value]

# fill-intervals :: [[Number, Number]], Int? -> [[Number, Number]]
fill-intervals = (list, default-value = 0) ->
    precision = Math.pow 10, (list |> map find-precision . (.0) |> maximum)
    list 
        |> map -> [(round it.0 * precision), it.1] 
        |> -> fill-intervals-ints it, default-value
        |> map -> [it.0 / precision, it.1]

# to-stacked-area :: (a -> String) -> (a -> Number) -> (a -> Number) -> [a] -> [{key :: String, total :: Number, values :: [[Number, Number, a]]]
# map a result array to the input of stacked-area
to-stacked-area = (key-f, x, y, result) -->
    result
    |> group-by key-f
    |> fold-obj-to-list (key, values) ->
        values := values |> map (v) ->
            [(x v), (y v), v]
        |> sort-by (.0)
        
        key: key
        values: values
        total: sum . map (.1) <| values
    |> sort-by (.total * -1)

# from-web-socket :: String -> Observer -> Subject
from-web-socket = (address, open-observer) ->
    
    if !!window.socket
        window.socket.close!
        window.socket.destroy!
    
    socket = io do 
        address
        reconnection: true
        force-new: true
    
    window.socket = socket
    
    # Rx.Observable.create :: Observer -> (a -> Void)
    # observable :: Observable
    observable = Rx.Observable.create (observer) ->
        
        if !!open-observer
            socket.on \connect, ->
                open-observer.on-next!
                open-observer.on-completed!
            
        socket.io.on \packet, ({data}?) ->
            if !!data 
                observer.on-next do
                    name: data.0
                    data: data.1
        
        socket.on \error, (err) ->
            observer.on-error err

        socket.on \reconnect_error, (err) ->
            observer.on-error err

        socket.on \reconnect_failed, ->
            observer.on-error new Error 'reconnection failed'

        socket.io.on \close, ->
            observer.on-completed!

        !->
            socket.close!
            socket.destroy!

    observer = Rx.Observer.create (event) ->
        if !!socket.connected
            socket.emit event.name, event.data

    Rx.Subject.create observer, observable

# date-from-object-id :: ObjectId -> Date, where ObjectId :: String
date-from-object-id = (object-id) -> new Date (parse-int (object-id.substring 0, 8), 16) * 1000

# object-id-from-date :: Date -> ObjectId, where ObjectId :: String
object-id-from-date = (date) -> ((floor date.getTime! / 1000).to-string 16) + "0000000000000000"

# credit: https://gist.github.com/Gozala/1697037
# tail-call-optimization :: Function -> Function
tail-call-optimization = (fn) ->
    active = null
    next-args = null
    ->
        args = null
        result = null
        next-args := arguments
        if not active
            active := true
            while next-args
                args := next-args
                next-args := null
                result := fn.apply this, args
            active := false
        result

# all functions defined here are accessible by the transformation code
module.exports = -> 
    {
        bucketize
        date-from-object-id
        day-to-timestamp: -> it * 86400000
        moment
        fill-intervals
        fill-intervals-ints
        fill-range
        find-precision
        fold-obj-to-list
        from-web-socket
        object-id-from-date
        parse-date
        today: today!
        to-timestamp: (s) -> (moment (new Date s)).unix! * 1000
        transpose
        round1
        summary-statistics
        tco: tail-call-optimization
        to-stacked-area
    } <<< @window <<< (require \prelude-ls) <<< 
        highland: require \highland
        JSONStream: require \JSONStream
        Rx: require \rx
        stream: require \stream