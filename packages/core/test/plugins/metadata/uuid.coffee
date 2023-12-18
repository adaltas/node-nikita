
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.uuid', ->
  return unless test.tags.api

  it 'in root action', ->
    nikita ({metadata: {uuid}}) ->
      uuid.should.match /^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/

  it 'in the same in child action', ->
    nikita ({metadata: {uuid: parentUuid}}) ->
      @call ->
        @call ({metadata: {uuid: childUuid}}) ->
          childUuid.should.eql parentUuid
      
