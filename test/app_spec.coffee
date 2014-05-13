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
