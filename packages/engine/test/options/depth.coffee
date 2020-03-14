
nikita = require '../../src'

describe 'options `depth`', ->

  it 'start at depth 0 with registered action', ->
    nikita.registry.register [''], ({metadata}) ->
      key: "root value, depth #{metadata.depth}"
    {key} = await nikita()
    key.should.eql 'root value, depth 0'
    nikita.registry.unregister ['']

  it 'start at depth 0 with action argument', ->
    {key} = await nikita ({metadata}) ->
      key: "root value, depth #{metadata.depth}"
    key.should.eql 'root value, depth 0'
    nikita.registry.unregister ['']
