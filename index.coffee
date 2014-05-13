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

      unless layer
              
        return out(err)  if out
        
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
        if err
          layer err, req, res, next
          next err
        else
          layer req, res, next
          next()
      catch e
        next e
      
      return
      
    stack = @stack
    index = 0
    next()
    return app


  return app

module.exports = myexpress