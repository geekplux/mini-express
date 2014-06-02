request = require("supertest")
expect = require("chai").expect
http = require("http")
express = require("../")
inject = undefined
try
  inject = require("../lib/injector")
describe "app.factory", ->
  app = undefined
  fn = undefined
  beforeEach ->
    app = express()
    fn = ->

    app.factory "foo", fn
    return

  it "should add a factory in app._factories", ->
    expect(app._factories).to.be.an "object"
    expect(app._factories).to.have.property "foo", fn
    return

  return

describe "Handler Dependencies Analysis:", ->
  handler = (foo, bar, baz) ->
  noargs = ->
  it "extracts the parameter names", ->
    expect(inject(noargs).extract_params()).to.deep.equal []
    expect(inject(handler).extract_params()).to.deep.equal [
      "foo"
      "bar"
      "baz"
    ]
    return

  return

describe "Implement Dependencies Loader:", ->
  load = (handler, cb) ->
    injector = inject(handler, app)
    loader = injector.dependencies_loader()
    loader cb
    return
  app = undefined
  injector = undefined
  loader = undefined
  beforeEach ->
    app = express()
    return

  describe "load named dependencies:", ->
    beforeEach ->
      app.factory "foo", fooFactory = (req, res, next) ->
        next null, "foo value"
        return

      app.factory "bar", barFactory = (req, res, next) ->
        next null, "bar value"
        return

      return

    it "loads values", (done) ->
      handler = (bar, foo) ->

      load handler, (err, values) ->
        expect(values).to.deep.equal [
          "bar value"
          "foo value"
        ]
        done()
        return

      return

    return

  describe "dependencies error handling:", ->
    beforeEach ->
      app.factory "foo", fooFactory = (req, res, next) ->
        next new Error("foo error")
        return

      app.factory "bar", barFactory = (req, res, next) ->
        throw new Error("bar error")
        return

      return

    it "gets error returned by factory", (done) ->
      handler = (foo) ->
      load handler, (err) ->
        expect(err).to.be.instanceOf Error
        expect(err.message).to.equal "foo error"
        done()
        return

      return

    it "gets error thrown by factory", (done) ->
      handler = (bar) ->
      load handler, (err) ->
        expect(err).to.be.instanceOf Error
        expect(err.message).to.equal "bar error"
        done()
        return

      return

    it "gets an error if factory is not defined", (done) ->
      handler = (baz) ->
      load handler, (err) ->
        expect(err).to.be.instanceOf Error
        expect(err.message).to.equal "Factory not defined: baz"
        done()
        return

      return

    return

  describe "load bulitin dependencies:", ->
    it "can load req, res, and next", (done) ->
      handler = (next, req, res) ->
      req = 1
      res = 2
      next = 3
      injector = inject(handler, app)
      loader = injector.dependencies_loader(req, res, next)
      loader (err, values) ->
        expect(values).to.deep.equal [
          3
          1
          2
        ]
        done()
        return

      return

    return

  describe "pass req and res to factories", ->
    it "can calls factories with req, res", (done) ->
      handler = (foo) ->
      req = 1
      res = 2
      app.factory "foo", (req, res, cb) ->
        cb null, [
          req
          res
          "foo"
        ]
        return

      injector = inject(handler, app)
      loader = injector.dependencies_loader(req, res)
      loader (err, values) ->
        args = values[0]
        expect(args[0]).to.equal req
        expect(args[1]).to.equal res
        done()
        return

      return

    return

  return

describe "Implement Injector Invokation:", ->
  app = undefined
  injector = undefined
  beforeEach ->
    app = express()
    app.factory "foo", (req, res, next) ->
      next null, "foo value"
      return

    return

  it "can call injector as a request handler", (done) ->
    handler = (res, foo) ->
      expect(res).to.equal 2
      expect(foo).to.equal "foo value"
      done()
      return
    req = 1
    res = 2
    next = 3
    injector = inject(handler, app)
    injector req, res, next
    return

  it "calls next with error if injection fails", (done) ->
    next = (err) ->
      expect(err).to.be.instanceOf Error
      expect(err.message).to.equal "Factory not defined: unknown_dep"
      done()
      return
    handler = (unknown_dep) ->
    req = 1
    res = 2
    injector = inject(handler, app)
    injector req, res, next
    return

  return

describe "Implement app.inject", ->
  app = undefined
  beforeEach ->
    app = express()
    app.factory "foo", (res, req, cb) ->
      cb null, "hello from foo DI!"
      return

    return

  it "can create an injector", (done) ->
    app.use app.inject((res, foo) ->
      res.end foo
      return
    )
    request(app).get("/").expect("hello from foo DI!").end done
    return

  return
