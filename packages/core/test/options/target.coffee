
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'options "source"', ->

  they 'home', (ssh) ->
    nikita
      ssh: ssh
    .call source: '~', ({options}) ->
      unless ssh
      then options.source.should.eql "#{process.env.HOME}"
      else options.source.should.eql "."
    .promise()

  they 'relative to home', (ssh) ->
    nikita
      ssh: ssh
    .call source: '~/.profile', ({options}) ->
      unless ssh
      then options.source.should.eql "#{process.env.HOME}/.profile"
      else options.source.should.eql ".profile"
    .promise()
