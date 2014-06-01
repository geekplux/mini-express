request = require("supertest")
expect = require("chai").expect
http = require("http")
express = require("../")
describe "App get method:", ->
  app = undefined
  before ->
    app = express()
    app.get "/foo", (req, res) ->
      res.end "foo"
      return

    return

  it "should respond for GET request", (done) ->
    request(app).get("/foo").expect("foo").end done
    return

  it "should 404 non GET requests", (done) ->
    request(app).post("/foo").expect(404).end done
    return

  it "should 404 non whole path match", (done) ->
    request(app).get("/foo/bar").expect(404).end done
    return

  return

describe "All http verbs:", ->
  methods = undefined
  app = undefined
  try
    methods = require("methods")
  catch e
    methods = []
  beforeEach ->
    app = express()
    return

  methods.forEach (method) ->
    it "responds to " + method, (done) ->
      app[method] "/foo", (req, res) ->
        res.end "foo"
        return

      method = "del"  if method is "delete"
      request(app)[method]("/foo").expect(200).end done
      return

    return

  return
