http = require 'http'
Layer = require './src/layer'
Route = require './src/route'
Injector = require './src/injector'
methods = require('methods').concat 'all'

myexpress = () ->
  app = (req, res, next) ->
    app.handle req, res, next
    return

  app.listen = (port, done) ->
    server = http.createServer(@)
    server.listen(port, done())

  app.stack = []
  app.use = (path, middleware, prefix) ->

    unless middleware?
      middleware = path
      path = '/'

    layer = new Layer(path, middleware, prefix)
    @stack.push layer

    return

  app.handle = (req, res, out) ->

    next = (err) ->

      layer = stack[index++]

      unless layer

        return out err if out

        if err
          res.writeHead 500,
            'Content-Type': 'text/html'
          res.end()
        else
          res.writeHead 404,
            'Content-Type': 'text/html'
          res.end()

        return

      try
        return next err  unless layer.match req.url
        func = layer.handle

        req.params = {}
        req.params = (layer.match req.url).params

        if func.handle?
          tempPath = req.url.split '/'
          req.url = '/' + tempPath[tempPath.length - 1]

        if err
          func err, req, res, next
          next err
        else
          func req, res, next
          next()

      catch e
        next e

      return

    stack = @stack
    index = 0
    next()

    return

  app.route = (path) ->
    prefix = true

    route = new Route()
    app.use(path, route, prefix)

    return route

  app._factories = {}
  app.factory = (name, fn) ->
    app._factories[name] = fn

  app.inject = (handler) ->
    Injector handler, app

  methods.forEach (method) ->
    app[method] = (path, handler) ->
      route = app.route path
      route[method] handler
      return @

    return

  return app


module.exports = myexpress
