http = require 'http'
Layer = require './lib/layer'
Route = require './lib/route'
Injector = require './lib/injector'
methods = require('methods').concat 'all'
_request = require './lib/request'
_response = require './lib/response'

myexpress = () ->
  app = (req, res, next) ->
    app.monkey_patch req, res
    app.handle req, res, next
    return

  app.listen = () ->
    server = http.createServer(@)
    server.listen.apply server, arguments

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

        if out
          subApp = app
          return out err

        if err
          res.statusCode = err.statusCode || 500
          res.end()
        else
          res.statusCode = 404
          res.end()

        return

      try
        return next err  unless layer.match req.url
        req.app = app
        func = layer.handle

        req.params = {}
        req.params = (layer.match req.url).params

        if func.handle?
          req.app = subApp
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
    subApp = undefined
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

  app.monkey_patch = (req, res) ->
    req.__proto__ = _request
    res.__proto__ = _response
    req.res = res
    res.req = req
    return

  methods.forEach (method) ->
    app[method] = (path, handler) ->
      route = app.route path
      route[method] handler
      return @

    return

  return app


module.exports = myexpress
