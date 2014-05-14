express = require('../')
request = require('supertest')
expect = require('chai').expect
http = require('http')

describe 'empty app', ->
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
    
  describe 'listen port', () ->
    port = 4000

    it 'should return a http.Server', (done) ->
      server = app.listen(port, done)
      expect(server).to.be.instanceOf(http.Server)
      return
    return
    
  return

describe 'app.user', () ->
  app = null
  m1 = () ->
  m2 = () ->

  before () ->
    app = express()
    return

  it 'should be able to add middlewares to stack', () ->
    app.use(m1)
    app.use(m2)
    expect(app.stack.length).to.equal(2)
    return

  return

describe 'calling middleware stack', () ->
  app = null

  beforeEach () ->
    app = express()
    return

  it 'should be able to call a single middleware', (done) ->
    m1 = (req, res, next) ->
      res.end('hello from m1')

      return

    app.use(m1)
    request(app).get('/')
    .expect('hello from m1')
    .end done

    return

  it 'Should be able to call `next` to go to the next middleware', (done) ->
    calls = []
    m1 = (req,res,next) ->
      calls.push 'm1'
      next()

    m2 = (req,res,next) ->
      calls.push 'm2'
      res.end 'hello from m2'

    app.use m1
    app.use m2
    request(app).get('/').expect('hello from m2').end (err) ->
      expect(calls).to.deep.equal(['m1','m2'])
      done err

    return

  it 'Should 404 at the end of middleware chain', (done) ->
    m1 = (req, res, next) ->
      next()
      return

    m2 = (req, res, next) ->
      next()
      return

    app.use m1
    app.use m2
    request(app).get('/').expect(404).end done

    return

  it 'Should 404 if no middleware is added', (done) ->
    request(app).get('/').expect(404).end done

    return

  return

describe 'Implement Error Handling', ->
  app = undefined
  beforeEach ->
    app = new express()
    return

  it 'should return 500 for unhandled error', (done) ->
    m1 = (req, res, next) ->
      next new Error('boom1!')
      return

    app.use m1
    request(app).get('/').expect(500).end done

    return

  it 'should return 500 for uncaught error', (done) ->
    m1 = (req, res, next) ->
      throw new Error('boom2!')
      return

    app.use m1
    request(app).get('/').expect(500).end done

    return

  it 'should ignore error handlers when `next` is called without an error', (done) ->
    m1 = (req, res, next) ->
      next()
      return

    e1 = (err, req, res, next) ->

    # timeout
    m2 = (req, res, next) ->
      res.end 'm2'
      return

    app.use m1
    app.use e1 # should skip this
    app.use m2
    request(app).get('/').expect('m2').end done

    return

  it 'should skip normal middlewares if `next` is called with an error', (done) ->
    m1 = (req, res, next) ->
      next new Error('boom!')
      return

    m2 = (req, res, next) ->

    # timeout
    e1 = (err, req, res, next) ->
      res.end 'e1'
      return

    app.use m1
    app.use m2 # should skip this. will timeout if called.
    app.use e1
    request(app).get('/').expect('e1').end done

    return


  return

describe "Layer class and the match method", ->
  layer = undefined
  fn = undefined
  beforeEach ->
    Layer = require("../lib/layer")
    fn = ->
    layer = new Layer("/foo", fn)

    return

  it "sets layer.handle to be the middleware", ->
    expect(layer.handle).to.eql fn

    return

  it "returns undefined if path doesn't match", ->
    expect(layer.match("/bar")).to.be.undefined

    return

  it "returns matched path if layer matches the request path exactly", ->
    match = layer.match("/foo")
    expect(match).to.not.be.undefined
    expect(match).to.have.property "path", "/foo"

    return

  it "returns matched prefix if the layer matches the prefix of the request path", ->
    match = layer.match("/foo/bar")
    expect(match).to.not.be.undefined
    expect(match).to.have.property "path", "/foo"
    
    return

  return

describe "app.use should add a Layer to stack", () ->

  app = undefined
  Layer = undefined

  beforeEach () ->
    app = express()
    Layer = require("../lib/layer")
    app.use () ->
    app.use "/foo", () ->
    
    return

  it "first layer's path should be /", () ->
    layer = app.stack[0]
    expect(layer.match("/foo")).to.not.be.undefined
    
    return

  it "second layer's path should be /foo", () ->
    layer = app.stack[1]
    expect(layer.match("/")).to.be.undefined
    expect(layer.match("/foo")).to.not.be.undefined
  
    return

  return

describe "The middlewares called should match request path:", ->
  app = undefined
  before ->
    app = express()
    app.use "/foo", (req, res, next) ->
      res.end "foo"

      return

    app.use "/", (req, res) ->
      res.end "root"

      return

    return

  it "returns root for GET /", (done) ->
    request(app).get("/").expect("root").end done

    return

  it "returns foo for GET /foo", (done) ->
    request(app).get("/foo").expect("foo").end done

    return

  it "returns foo for GET /foo/bar", (done) ->
    request(app).get("/foo/bar").expect("foo").end done

    return

  return

describe "The error handlers called should match request path:", ->
  app = undefined
  before ->
    app = express()
    app.use "/foo", (req, res, next) ->
      throw "boom!"
      
      return

    app.use "/foo/a", (err, req, res, next) ->
      res.end "error handled /foo/a"

      return

    app.use "/foo/b", (err, req, res, next) ->
      res.end "error handled /foo/b"

      return

    return

  it "handles error with /foo/a", (done) ->
    request(app).get("/foo/a").expect("error handled /foo/a").end done

    return

  it "handles error with /foo/b", (done) ->
    request(app).get("/foo/b").expect("error handled /foo/b").end done

    return

  it "returns 500 for /foo", (done) ->
    request(app).get("/foo").expect(500).end done

    return

  return
