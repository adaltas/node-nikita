

module.exports = (string, options) ->
  options.engine ?= 'nunjunks'
  return switch options.engine
    when 'nunjunks' then (new nunjucks.Environment()).renderString string, options
    else throw Error "Invalid engine: #{options.engine}"

nunjucks = require 'nunjucks/src/environment'
