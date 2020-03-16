
nikita = require '../../src'

describe 'session', ->

  it 'call registered action', ->
    n = nikita()
    {key} = await n.action()
    key.should.eql 'action value, depth 1'
    {key} = await n.an.action()
    key.should.eql 'an.action value, depth 1'

  it 'chain calls', ->
    n = nikita()
    {key} = await n.action().action()
    key.should.eql 'action value, depth 1'
    {key} = await n.an.action().an.action()
    key.should.eql 'an.action value, depth 1'

  it 'call unregisted action', ->
    try
      nikita().an()
    catch e
      e.message.should.eql 'No action named an'

  it 'chain action after unregisted action', ->
    try
      nikita().invalid.action.broken()
    catch e
      e.message.should.eql 'Cannot read property \'action\' of undefined'

  it 'call unregisted action with namespace', ->
    try
      nikita().an.action.broken()
      throw Error 'CulDeSac'
    catch e
      e.message.should.eql 'nikita(...).an.action.broken is not a function'
