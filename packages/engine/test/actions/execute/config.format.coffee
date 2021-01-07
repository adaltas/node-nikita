
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

describe 'actions.execute.config.format', ->

  they 'json', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {stdout, data} = await @execute
        command: 'echo \'{"key": "value"}\''
        format: 'json'
      stdout.should.eql '{"key": "value"}\n'
      data.should.eql key: "value"

  they 'yaml', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {stdout, data} = await @execute
        command: '''
        cat <<YAML
        key: value
        YAML
        '''
        format: 'yaml'
      stdout.should.eql 'key: value\n'
      data.should.eql key: "value"

  they 'with error', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {stdout, data} = await @execute
        command: 'exit 1'
        format: 'json'
        code_skipped: 1
      stdout.should.eql ''
      should.not.exist(data)
