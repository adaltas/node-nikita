
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
glob = require "../#{lib}/misc/glob"
test = require './test'
they = require 'ssh2-they'
path = require 'path'

describe 'glob', ->

  they 'should traverse a directory', (ssh, next) ->
    glob ssh, "#{__dirname}/../lib/*", (err, files) ->
      return next err if err
      files.should.containEql path.normalize "#{__dirname}/../lib/copy.js"
      files.should.containEql path.normalize "#{__dirname}/../lib/misc"
      files.should.not.containEql path.normalize "#{__dirname}/../lib/misc/glob.js"
      next()

  they 'should traverse a directory recursively', (ssh, next) ->
    glob ssh, "#{__dirname}/../lib/**", (err, files) ->
      return next err if err
      files.should.containEql path.normalize "#{__dirname}/../lib/copy.js"
      files.should.containEql path.normalize "#{__dirname}/../lib/misc"
      files.should.containEql path.normalize "#{__dirname}/../lib/misc/glob.js"
      next()

  they 'should match an extension patern', (ssh, next) ->
    glob ssh, "#{__dirname}/../lib/*.js", (err, files) ->
      return next err if err
      files.should.containEql path.normalize "#{__dirname}/../lib/copy.js"
      files.should.not.containEql path.normalize "#{__dirname}/../lib/misc"
      files.should.not.containEql path.normalize "#{__dirname}/../lib/misc/glob.js"
      next()
