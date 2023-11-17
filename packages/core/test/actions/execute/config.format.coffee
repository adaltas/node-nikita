
nikita = require '../../../lib'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.format', ->
  return unless tags.posix

  describe 'function', ->

    they 'return user value', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {stdout, data} = await @execute
          command: 'echo "This is my precious."'
          format: ({stdout}) => /^.*\s(\w+)\.$/.exec(stdout.trim())[1]
        stdout.should.eql 'This is my precious.\n'
        data.should.eql 'precious'

    they 'catch error', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @execute
          command: 'echo "this is my precious."'
          format: ({stdout}) => throw Error 'catchme'
        .should.be.rejectedWith [
          'NIKITA_UTILS_STRING_FORMAT_UDF_FAILURE:'
          'failed to format output with a user defined function, original error message is \'catchme\'.'
        ].join ' '
  
  describe 'enum', ->

    they 'yaml', ({ssh}) ->
      nikita
        $ssh: ssh
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
        $ssh: ssh
      , ->
        {stdout, data} = await @execute
          command: 'exit 1'
          format: 'json'
          code: [, 1]
        stdout.should.eql ''
        should.not.exist(data)

    they 'parsing error', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @execute
          command: 'echo invalid'
          format: 'json'
        .should.be.rejectedWith [
          'NIKITA_UTILS_STRING_FORMAT_PARSING_FAILURE:'
          'failed to parse output, format is "json",'
          'original error message is "Unexpected token \'i\', \\"invalid\\n\\" is not valid JSON".'
        ].join ' '
        
