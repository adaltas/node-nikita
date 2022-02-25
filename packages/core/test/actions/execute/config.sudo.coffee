
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.sudo', ->
  return unless tags.sudo

  they 'execute.assert', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @execute.assert
        command: 'whoami'
        content: 'root'
        $sudo: true
        trim: true
