methods = require 'methods'

makeRoute = (verb, handler) ->

  route = (req, res, next) ->
    route.handler req, res, next
    return

  route.stack = []

  route.use = (verb, handler) ->
    @stack.push
      verb: verb
      handler: handler
    return

  route.handler = (req, res, out) ->
    next = (err) ->
      out() if err is "route"
      out err if err
      layer = stack[index++]

      unless layer
        res.statusCode = 404
        res.end()

      if layer.verb is req.method.toLowerCase() or layer.verb is "all"
        layer.handler req, res, next
      else
        next()

      return

    stack = @stack
    index = 0
    next()

    return

  methods.forEach (method) ->
    
    route[method] = (handler) ->
      route.use method, handler

      return @

    return


  return route


module.exports = makeRoute