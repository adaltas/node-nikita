
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
  
    they 'defined as a function', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          content: '''
          module.exports = ({config}) => {
            return config
          }
          '''
          target: "#{tmpdir}/my_module.js"
        result = await @call "#{tmpdir}/my_module.js", my_key: 'my value'
        result.should.containEql my_key: 'my value'
    
    they 'defined as an object', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
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
          header: 'hello'
          module: "#{tmpdir}/my_module.js"
    
    they 'defined as an object with no handler', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
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
        await @fs.base.writeFile
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
