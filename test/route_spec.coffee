request = require("supertest")
expect = require("chai").expect
http = require("http")
express = require("../")
makeRoute = undefined
describe "Add handlers to a route:", ->
  route = undefined
  handler1 = undefined
  handler2 = undefined
  before ->
    makeRoute = require("../lib/route")
    route = makeRoute()
    handler1 = ->

    handler2 = ->

    route.use "get", handler1
    route.use "post", handler2
    return

  it "adds multiple handlers to route", ->
    expect(route.stack).to.have.length 2
    return

  it "pushes action object to the stack", ->
    action = route.stack[0]
    expect(action).to.have.property "verb", "get"
    expect(action).to.have.property "handler", handler1
    return

  return

describe "Implement Route Handlers Invokation:", ->
  app = undefined
  route = undefined
  beforeEach ->
    makeRoute = require("../lib/route")
    app = express()
    route = makeRoute()
    app.use route
    return

  describe "calling next():", ->
    it "goes to the next handler", (done) ->
      route.use "get", (req, res, next) ->
        next()
        return

      route.use "get", (req, res) ->
        res.end "handler2"
        return

      request(app).get("/").expect("handler2").end done
      return

    it "exits the route if there's no more handler", (done) ->
      request(app).get("/").expect(404).end done
      return

    return

  describe "error handling:", ->
    it "exits the route if there's an error", (done) ->
      route.use "get", (req, res, next) ->
        next new Error("boom!")
        return

      route.use "get", (req, res, next) ->

      
      # would timeout
      request(app).get("/").expect(500).end done
      return

    return

  describe "verb matching:", ->
    beforeEach ->
      route.use "get", (req, res) ->
        res.end "got"
        return

      route.use "post", (req, res) ->
        res.end "posted"
        return

      return

    it "matches GET to the get handler", (done) ->
      request(app).get("/").expect("got").end done
      return

    it "matches POST to the post handler", (done) ->
      request(app).post("/").expect("posted").end done
      return

    return

  
  # it("matches DELETE to the all handler")
  # it("matches PATCH to the all handler")
  describe "match any verb:", ->
    beforeEach ->
      route.use "all", (req, res) ->
        res.end "all"
        return

      return

    it "matches POST to the all handler", (done) ->
      request(app).post("/").expect("all").end done
      return

    it "matches GET to the all handler", (done) ->
      request(app).get("/").expect("all").end done
      return

    return

  describe "calling next(route):", ->
    beforeEach ->
      route.use "get", (req, res, next) ->
        next "route"
        return

      route.use "get", ->
        throw new Error("boom") 
        return

      app.use (req, res) ->
        res.end "middleware"
        return

      return

    it "skip remaining handlers", (done) ->
      request(app).get("/").expect("middleware").end done
      return

    return

  return

describe "Implement Verbs For Route", ->
  app = undefined
  route = undefined
  methods = undefined
  try
    methods = require("methods").concat("all")
  catch e
    methods = []
  beforeEach ->
    makeRoute = require("../lib/route")
    app = express()
    route = makeRoute()
    app.use route
    return

  methods.forEach (method) ->
    it "should respond to " + method, (done) ->
      route[method] (req, res) ->
        res.end "success!"
        return

      method = "del"  if method is "delete"
      method = "get"  if method is "all"
      request(app)[method]("/").expect(200).end done
      return

    return

  it "should be able to chain verbs", (done) ->
    route.get((req, res, next) ->
      next()
      return
    ).get (req, res) ->
      res.end "got"
      return

    request(app).get("/").expect("got").end done
    return

  return

describe "Implement app.route", (done) ->
  app = undefined
  beforeEach ->
    app = express()
    return

  it "can create a new route", (done) ->
    route = app.route("/foo").get((req, res, next) ->
      next()
      return
    ).get((req, res) ->
      res.end "foo"
      return
    )
    expect(app.stack).to.have.length 1
    request(app).get("/foo").expect("foo").end done
    return

  return

describe "Implement Verbs For App", (done) ->
  app = undefined
  try
    methods = require("methods").concat("all")
  catch e
    methods = []
  beforeEach ->
    app = express()
    return

  methods.forEach (method) ->
    it "creates a new route for " + method, (done) ->
      app[method] "/foo", (req, res) ->
        res.end "ok"
        return

      method = "del"  if method is "delete"
      method = "get"  if method is "all"
      request(app)[method]("/foo").expect(200).end done
      return

    return

  it "can chain VERBS", (done) ->
    app.get("/foo", (req, res) ->
      res.end "foo"
      return
    ).get "/bar", (req, res) ->
      res.end "bar"
      return

    expect(app.stack).to.have.length 2
    request(app).get("/bar").expect("bar").end done
    return

  return
