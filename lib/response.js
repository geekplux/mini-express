// Generated by CoffeeScript 1.7.1
(function() {
  var accepts, crc32, http, mime, proto;

  http = require('http');

  mime = require('mime');

  accepts = require('accepts');

  crc32 = require('buffer-crc32');

  proto = {};

  proto.isExpress = true;

  proto.__proto__ = http.ServerResponse.prototype;

  proto.redirect = function(statusCode, path) {
    if (path == null) {
      path = statusCode;
      statusCode = 302;
    }
    this.writeHead(statusCode, {
      'Location': path,
      'Content-Length': 0
    });
  };

  proto.type = function(fileType) {
    this.setHeader('Content-Type', mime.lookup(fileType));
  };

  proto.default_type = function(fileType) {
    if (!this.getHeader("content-type")) {
      this.type(fileType);
    }
  };

  proto.format = function(file) {
    var accept, err, fileType, type;
    accept = accepts(this.req);
    fileType = Object.keys(file);
    type = accept.types(fileType);
    if (fileType.length) {
      this.type(type);
      file[type]();
    } else {
      err = new Error('Not Acceptable');
      err.statusCode = 406;
      throw err;
    }
  };

  proto.send = function(statusCode, body) {
    var bodyLength;
    if (body != null) {
      this.statusCode = statusCode;
    } else {
      body = statusCode;
    }
    if (typeof body === 'number') {
      this.default_type('text/plain');
      this.statusCode = body;
      body = http.STATUS_CODES[body];
    } else if (typeof body === 'string') {
      this.default_type('text/html');
    } else if (Buffer.isBuffer(body)) {
      this.default_type('application/octet-stream');
    } else {
      this.default_type('application/json');
      body = JSON.stringify(body);
    }
    if (Buffer.isBuffer(body)) {
      bodyLength = body.length;
    } else {
      bodyLength = Buffer.byteLength(body);
    }
    this.setHeader('Content-Length', bodyLength);
    if (!this.getHeader('ETag') && this.req.method === 'GET' && bodyLength) {
      this.setHeader('ETag', '"' + crc32.unsigned(body) + '"');
    }
    if (this.getHeader('ETag') === this.req.headers["if-none-match"] || this.getHeader('Last-Modified') <= this.req.headers['if-modified-since']) {
      this.statusCode = 304;
    }
    this.end(body);
  };

  module.exports = proto;

}).call(this);
