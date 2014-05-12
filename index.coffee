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
    next = (error) ->
    
      layer = stack[index++]
      
      unless layer
        
        return out(error)  if out
        
        if error
          
          res.writeHead 500,
            "Content-Type": "text/html"

          res.end()
        else
          
          res.writeHead 404,
            "Content-Type": "text/html"

          res.end()
        return

      try
        arity = layer.length
        if error
          if arity is 4
            layer error, req, res, next
          else
            next error
        else if arity < 4
          layer req, res, next
        else
          next()
      catch event
        next event
      return
      
    stack = @stack
    index = 0
    next()
    return app


  return app

module.exports = myexpress