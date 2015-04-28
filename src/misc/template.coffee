

module.exports = (string, options) ->
  options.engine ?= 'nunjunks'
  return switch options.engine
    when 'nunjunks' then (new nunjucks.Environment()).renderString string, options
    when 'eco' then eco.render string, options
    else throw Error "Invalid engine: #{options.engine}"

eco = require 'eco'
nunjucks = require 'nunjucks/src/environment'
