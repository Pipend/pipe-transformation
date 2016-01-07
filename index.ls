{from-error-value-tuple, compile-and-execute, compile-and-execute-sync} = require \transpilation
require! \./transformation-context

# compile-parameters-sync :: Parameters -> String -> object -> [Error, a]
export compile-parameters-sync = (parameters, language, context) ->
    if !!parameters and parameters.trim!.length > 0
        compile-and-execute-sync parameters, language, (context ? {})

    else
        [null, {}]

# compile-parameters :: Document -> p Parameters
export compile-parameters = from-error-value-tuple compile-parameters-sync

# compile-transformation-sync :: String -> String -> [Error, (result -> Parameters -> result)]
export compile-transformation-sync = (transformation, language) -> 
    compile-and-execute-sync transformation, language, transformation-context!

# compile-transformation :: String -> String -> (result -> Parameters -> result)
export compile-transformation = from-error-value-tuple compile-transformation-sync