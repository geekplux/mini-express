express = require('../')
request = require('supertest')
expect = require("chai").expect
http = require('http')

describe 'app', ->
  app = express()
  describe 'create http server', ->
    it 'responds 404', (done) ->
      server = http.createServer(app)
      request(server)
      .get('/foo')
      .expect(404)
      .end done
      return
    return
    
  describe '#listen', () ->
    port = 4000;
    server = null
    before (done) ->
      server = app.listen(port,done)

    it 'should return a http.Server', (done) ->
      expect(server).to.be.instanceof(http.Server)
      return
    return
    
  return