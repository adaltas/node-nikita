
{lines} = require '@nikitajs/core/lib/misc/string'

module.exports = (err, stderr) ->
  stderr = stderr.trim()
  err.message = stderr if lines(stderr).length is 1
