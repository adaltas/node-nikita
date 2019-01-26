
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'file.ini option stringify_single_key', ->

  they 'stringify write only key on props', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      content:
        'user':
          'name': 'toto'
          '--hasACar': ''
      target: "#{scratch}/user.ini"
      merge: false
      stringify: misc.ini.stringify_single_key
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user]\nname = toto\n--hasACar\n'
    .promise()

  they 'merge ini containing single key lines', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor\n'
    .file.ini
      content: user: preference: {language: 'c++', color: ''}
      stringify: misc.ini.stringify_single_key
      target: "#{scratch}/user.ini"
      merge: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = c++\ncolor\n'
    .promise()
