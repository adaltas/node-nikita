
import nikita from '@nikitajs/core'
import test from '../test.coffee'

describe 'plugins.magic_dollar', ->
  return unless test.tags.api

  it 'extract metadata', ->
    metadata = await nikita
      $key: 'value'
    , ({metadata}) ->
      metadata
    metadata.should.containEql key: 'value'
