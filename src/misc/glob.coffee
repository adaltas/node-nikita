
path = require 'path'
glob = require 'glob'
minimatch = require 'minimatch'
exec = require 'ssh2-exec'

module.exports = (ssh, pattern, callback) ->
  if ssh
    pattern = path.normalize pattern
    exec ssh, "find -f #{pattern}", (err, stdout) ->
      return callback err if err
      files = stdout.trim().split /\r\n|[\n\r\u0085\u2028\u2029]/g
      # files = files.filter (file) -> path.basename(file).substr(0, 1) isnt '.'
      files = files.filter (file) -> minimatch file, pattern
      callback err, files
  else
    glob "#{pattern}", (err, files) ->
      callback err, files
