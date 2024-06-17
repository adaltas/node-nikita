
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.header', ->
  return unless test.tags.api
  
  it 'validate schema', ->
    nikita
      $header: [false, false]
      $handler: (->)
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      message: [
        # 'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        # 'one error was found in the configuration of root action:'
        # 'nikita#/definitions/metadata/properties/header/type'
        # 'metadata/header must be string, type is "string".'
        'NIKITA_SCHEMA_VALIDATION_CONFIG:',
        'multiple errors were found in the configuration of root action:',
        'nikita#/definitions/metadata/properties/header/items/type metadata/header/0 must be string,',
        'type is ["string"];'
        'nikita#/definitions/metadata/properties/header/items/type metadata/header/1 must be string,',
        'type is ["string"].'
      ].join ' '
  
  it 'coersion', ->
    nikita $header: 'Some header', ({metadata: {header}}) ->
      header.should.eql ['Some header']
  
  it 'default', ->
    nikita ({metadata: {header}}) ->
      should(header is undefined).be.true()
