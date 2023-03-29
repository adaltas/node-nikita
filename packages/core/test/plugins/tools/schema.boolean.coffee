
{tags} = require '../../test'
nikita = require '../../../lib'

describe 'plugins.tools.schema.boolean', ->
  return unless tags.api
  definitions =
    config:
        type: 'object'
        properties:
          'a_boolean':
            type: 'boolean'
            default: true

  it 'default value', ->
    nikita.call
      $definitions: definitions
      $handler: ({config}) ->
        config.a_boolean.should.eql true

  it 'default true with config `true`', ->
    nikita.call
      $definitions: definitions
      a_boolean: true
      $handler: ({config}) ->
        config.a_boolean.should.eql true

  it 'default true with config `false`', ->
    nikita.call
      $definitions: definitions
      a_boolean: false
      $handler: ({config}) ->
        config.a_boolean.should.eql false
