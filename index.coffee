http = require('http')

myexpress = () ->
  app = (req, res, next) ->
    app.handle(req, res, next)
    return

  app.listen = (port, done) ->
    server = http.createServer(@)
    server.listen(port, done())

  app.stack = []
  app.use = (middleware) ->
    @stack.push middleware
    return

  app.handle = (req, res, out) ->
    next = (err) ->
      layer = stack[index++]

      if layer == undefined
        res.writeHead 404,
          "Content-Type": "text/html"
        res.end()
        return
      else
        layer req, res, next

      next()
      return
      
    stack = @stack
    index = 0
    next()
    return app


  return app

module.exports = myexpress