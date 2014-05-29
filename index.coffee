http = require("http")
Layer = require("./src/layer")

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
        func = layer.handle

        req.params = {}
        req.params = (layer.match req.url).params

        if func.handle?
          tempPath = req.url.split "/"
          req.url = "/" + tempPath[tempPath.length - 1]

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


  return app

module.exports = myexpress