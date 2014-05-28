http = require("http")
Layer = require("./lib/layer")

myexpress = () ->
  app = (req, res, next) ->
    app.handle req, res, next
    return

  app.listen = (port, done) ->
    server = http.createServer(@)
    server.listen(port, done())

  app.stack = []
  app.use = (path, middleware) ->

    unless middleware?
      middleware = path
      path = "/"

    layer = new Layer(path, middleware)
    @stack.push layer

    return

  app.handle = (req, res, out) ->

    next = (err) ->

      layer = stack[index++]

      unless layer
              
        return out err if out
        
        if err
          res.writeHead 500,
            "Content-Type": "text/html"
          res.end()
        else
          res.writeHead 404,
            "Content-Type": "text/html"
          res.end()

        return

      try
        return next err  unless layer.match req.url

        req.params = {}
        req.params = (layer.match req.url).params

        if err
          layer.handle err, req, res, next
          next err
        else
          layer.handle req, res, next
          next()

      catch e
        next e
      
      return
      
    stack = @stack
    index = 0
    next()

    return


  return app

module.exports = myexpress