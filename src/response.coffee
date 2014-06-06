http = require 'http'
mime = require 'mime'
accepts = require 'accepts'
crc32 = require 'buffer-crc32'

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

proto.send = (statusCode, body) ->
  if body? then @statusCode = statusCode else body = statusCode

  if typeof body is 'number'
    @default_type 'text/plain'
    @statusCode = body
    body = http.STATUS_CODES[body]
  else if typeof body is 'string'
    @default_type 'text/html'
  else if Buffer.isBuffer body
    @default_type 'application/octet-stream'
  else
    @default_type 'application/json'
    body = JSON.stringify body

  if Buffer.isBuffer body then bodyLength = body.length else bodyLength = Buffer.byteLength body
  @setHeader 'Content-Length', bodyLength

  if !@getHeader('ETag') and @req.method == 'GET' and bodyLength
    @setHeader('ETag', '"' + crc32.unsigned(body) + '"')

  if @getHeader('ETag') is @req.headers["if-none-match"] or @getHeader('Last-Modified') <= @req.headers['if-modified-since']
    @statusCode = 304

  @end body

  return


module.exports = proto
