http = require 'http'

proto = {}
proto.isExpress = true
proto.__proto__ = http.IncomingMessage::

module.exports = proto
