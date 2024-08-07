
import nikita from '@nikitajs/core'
import registry from '@nikitajs/core/registry'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.call', ->
  return unless test.tags.api

  it 'call action from global registry', ->
    try
      await nikita.call ->
        registry.register 'my_function', ({config}) ->
          pass_a_key: config.a_key
      await nikita.call ->
        {pass_a_key} = await nikita.my_function a_key: 'a value'
        pass_a_key.should.eql 'a value'
    finally ->
      nikita.call ->
        registry.unregister 'my_function'
  
  describe 'external module', ->

    they 'doesnt support plain declaration', ({ssh}) ->
      # The problem has found a solution to support `metadata.module`
      # Setting `metadata.module` conflict with the already defined value
      # setup by `registry#load`.
      # When argument is not defined (eg not a string, mapped to the handler),
      # mapping the metadata.module create a infinite loop
      # where `nikita.call` is importing itself
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await nikita.call
          $: false
          metadata:
            module: "#{tmpdir}/my_module.js"
          config:
            my_key: 'my value'
  
    they 'defined as a function', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.writeFile
          content: '''
          module.exports = ({config}) => {
            return config
          }
          '''
          target: "#{tmpdir}/my_module.js"
        await @call "#{tmpdir}/my_module.js", my_key: 'my value'
          .should.finally.containEql my_key: 'my value'
    
    they 'defined as CommonJS object', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.writeFile
          content: '''
          module.exports = {
            metadata: {
              header: 'hello'
            },
            handler: ({config, metadata}) => {
              return {config, metadata}
            }
          }
          '''
          target: "#{tmpdir}/my_module.js"
        {config, metadata} = await @call "#{tmpdir}/my_module.js", my_key: 'my value'
        config.should.containEql
          my_key: 'my value'
        metadata.should.containEql
          header: ['hello']
          module: "#{tmpdir}/my_module.js"
    
    they 'defined as an object with no handler', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.writeFile
          content: '''
          module.exports = {
            metadata: {
              header: 'hello'
            },
          }
          '''
          target: "#{tmpdir}/my_module.js"
        await @call "#{tmpdir}/my_module.js"
        .should.be.rejectedWith code: 'NIKITA_CALL_UNDEFINED_HANDLER'
        await @call "#{tmpdir}/my_module.js", () => 'getme'
        .should.be.resolvedWith 'getme'
    
    they 'dont overwrite argument', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.writeFile
          content: '''
          module.exports = {
            metadata: {
              argument_to_config: 'a_boolean',
              definitions: {
                config: {
                  type: 'object',
                  properties: {
                    a_boolean: {
                      type: 'boolean',
                      default: true
                    }
                  }
                }
              }
            },
            handler: ({config, metadata}) => {
              return {config, metadata}
            }
          }
          '''
          target: "#{tmpdir}/my_module.js"
        {config, metadata} = await @call "#{tmpdir}/my_module.js"
        config.should.eql
          a_boolean: true
        metadata.should.containEql
          argument: undefined
