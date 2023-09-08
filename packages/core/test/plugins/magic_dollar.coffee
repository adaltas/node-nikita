
{tags} = require '../test'
nikita = require '../../lib'

describe 'plugins.magic_dollar', ->
  return unless tags.api

  it 'extract metadata', ->
    metadata = await nikita
      $key: 'value'
    , ({metadata}) ->
      metadata
    metadata.should.containEql key: 'value'
