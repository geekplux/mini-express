http = require 'http'
mime = require 'mime'
accepts = require 'accepts'

proto = {}
proto.isExpress = true
proto.__proto__ = http.ServerResponse::

proto.redirect = (statusCode, path) ->
  unless path?
    path = statusCode
    statusCode = 302

  @writeHead statusCode,
    'Location': path
    'Content-Length': 0

  return

proto.type = (fileType) ->
  @setHeader 'Content-Type', mime.lookup fileType
  return

proto.default_type = (fileType) ->
  @type fileType  unless @getHeader("content-type")
  return

proto.format = (file) ->
  accept = accepts @req
  fileType = Object.keys file
  type = accept.types fileType

  if fileType.length
    @type type
    file[type]()
  else
    err = new Error 'Not Acceptable'
    err.statusCode = 406
    throw err
    # @statusCode = 406
    # @end()

  return

module.exports = proto
