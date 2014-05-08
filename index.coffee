http = require('http')

myexpress = () ->
  app = (req, res, next) ->
    res.statusCode = 404
    res.end()
    return

  app.listen = (port, done) ->
    server = http.createServer(@)
    server.listen(port, done())

  return app

module.exports = myexpress