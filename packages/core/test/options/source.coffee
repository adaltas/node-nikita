
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'options "target"', ->

  they 'home', (ssh) ->
    nikita
      ssh: ssh
    .call target: '~', ({options}) ->
      unless ssh
      then options.target.should.eql "#{process.env.HOME}"
      else options.target.should.eql "."
    .promise()

  they 'relative to home', (ssh) ->
    nikita
      ssh: ssh
    .call target: '~/.profile', ({options}) ->
      unless ssh
      then options.target.should.eql "#{process.env.HOME}/.profile"
      else options.target.should.eql ".profile"
    .promise()
