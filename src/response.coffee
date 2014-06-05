http = require 'http'

proto = {}
proto.isExpress = true
proto.__proto__ = http.ServerResponse::

proto.redirect = (statusCode, path) ->
  res = @
  unless path?
    path = statusCode
    statusCode = 302

  res.writeHead statusCode,
    'Location': path
    'Content-Length': 0

  res.end()
  return

module.exports = proto
