p2re = require 'path-to-regexp'

Layer = (req, res, prefix) ->
  req = if req[req.length - 1] is '/' then req[0...req.length - 1] else req

  @path = req

  @handle = res

  @match = (path) ->
    names = []
    params = {}

    re = p2re @path, names, end: prefix || false
    paths = re.exec(decodeURIComponent(path))

    if re.test path
      for item, i in names
        params[item.name] = paths[i + 1]

      path: paths[0]
      params: params

  return


module.exports = Layer