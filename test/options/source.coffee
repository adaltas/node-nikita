
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'options "target"', ->

  scratch = test.scratch @

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
