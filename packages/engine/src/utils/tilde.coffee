
tilde = require 'tilde-expansion'
path = require 'path'

module.exports =
  normalize: (location) ->
    new Promise (accept, reject) ->
      tilde location, (location) ->
        accept path.normalize location
  resolve: (locations...) ->
    normalized = for location in locations
      module.exports.normalize location
    normalized = await Promise.all normalized
    path.resolve ...normalized
