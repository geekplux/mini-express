getArgumentsName = (fn) ->
  fnText = fn.toString()

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

  names



createInjector = (handler, app) ->
  injector = (req, res, next) ->
    injector.dependencies_loader(req, res, next) (err, values) ->
      if err and next instanceof Function then next err else handler.apply handler, values
      return
    return



  injector.extract_params = () ->
    return getArgumentsName handler

  injector.dependencies_loader = (req, res, next) ->

    names = @extract_params()
    appFac = []
    values = []
    _arguments = arguments
    _factories = app._factories
    error = undefined

    params = getArgumentsName @dependencies_loader
    for item, i in _arguments
      _factories[params[i]] = item


    for item in names
      appFac.push app._factories[item]

    next = (err, value) ->
      error = err
      values.push value if value?
      return if index == appFac.length

      func = appFac[index++]

      unless func
        error = new Error "Factory not defined: " + names[index - 1] unless error
      else if func instanceof Function
        try
          func req, res, next
        catch e
          next e
      else
        next err, func

      return
      

    index = 0
    next()

    return (handler) ->
      handler error, values



  return injector


module.exports = createInjector