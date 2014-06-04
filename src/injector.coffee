getParameters = (fn) ->
  fnText = fn.toString()

  if getParameters.cache[fnText]
    getParameters.cache[fnText]

  FN_ARGS = /^function\s*[^\(]*\(\s*([^\)]*)\)/m
  FN_ARG_SPLIT = /,/
  FN_ARG = /^\s*(_?)(\S+?)\1\s*$/
  STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/g

  names = []
  argDecl = fnText.replace(STRIP_COMMENTS, "").match(FN_ARGS)
  argDecl[1].split(FN_ARG_SPLIT).forEach (arg) ->
    arg.replace FN_ARG, (all, underscore, name) ->
      names.push name
      return
    return

  getParameters.cache[fn] = names
  names

getParameters.cache = {}


createInjector = (handler, app) ->
  injector = (req, res, next) ->
    injector.invoke req, res, next
    return


  injector.invoke = (req, res, next) ->
    loader = @dependencies_loader(req, res, next)
    loader (err, values) ->
      if err
        next err
      else
        handler.apply null, values
      return


  injector.extract_params = () ->
    getParameters handler


  injector.dependencies_loader = (req, res, done) ->
    params = @extract_params()
    index = 0
    (func) ->
      next = ->
        dependency = params[index]
        index++

        if dependency is "req"
          values.push req
          next()
          return

        if dependency is "res"
          values.push res
          next()
          return

        if dependency is "next"
          values.push done
          next()
          return

        if dependency
          factory = app._factories[dependency]

          unless factory
            func new Error("Factory not defined: " + dependency)
            return

          try
            factory req, res, (err, value) ->
              if err
                func err
                return
              values.push value
              next()
              return

          catch e
            func e

        else
          func null, values

        return

      values = []
      next()
      return


  return injector


module.exports = createInjector
