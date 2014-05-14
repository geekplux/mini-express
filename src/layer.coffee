Layer = (req, res) ->

  @path = req
  @handle = res
  @match = (path) ->
    if path.indexOf(@path) >= 0
      return path: @path

  return


module.exports = Layer