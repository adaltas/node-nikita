
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.execute.config.format', ->
  return unless test.tags.posix

  describe 'udf', ->

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
  
  describe 'constant', ->

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

    they 'json with error', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {stdout, stderr, data} = await @execute
          command: 'exit 1'
          format: 'json'
          code: [, 1]
        stdout.should.eql ''
        stderr.should.eql ''
        should.not.exist(data)

    they 'json parsing error', ({ssh}) ->
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

    they 'jsonline empty', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {stdout, stderr, data} = await @execute
          command: 'echo -n ""'
          format: 'jsonlines'
          bash: true
        stdout.should.eql ''
        stderr.should.eql ''
        data.should.eql []

    they 'lines', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {stdout, stderr, data} = await @execute
          command: 'echo line a; echo line b;'
          format: 'lines'
          trim: true
        stdout.should.eql 'line a\nline b'
        stderr.should.eql ''
        data.should.eql ['line a', 'line b']
        
