
makeRoute = (verb, handler) ->

  return (req, res, next) ->
    if verb is req.method.toLowerCase()
      handler req, res, next
    else
      next()


module.exports = makeRoute