
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.schema', ->
  return unless test.tags.api

  it 'disabled when `false`', ->
    nikita
    .registry.register ['test', 'schema'],
      metadata: definitions: config:
        type: 'object'
        properties:
          'a_key': type: 'string'
        required: ['a_key']
      handler: (->)
    .test.schema
      $schema: false
      $handler: (->)
