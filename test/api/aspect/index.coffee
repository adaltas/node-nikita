
nikita = require '../../../src'
{tags} = require '../../test'
  
return unless tags.api

describe 'aspect', ->

  describe 'after and before work co-jointly', ->

    it 'is a string and match a action type', ->
      history = []
      nikita()
      .registry.register 'my_action', ({options}) -> history.push "action #{options.key}"
      .before 'my_action', ({options}) -> history.push "before #{options.key}"
      .after 'my_action', ({options}) -> history.push "after #{options.key}"
      .my_action key: 'called'
      .call ->
        history.should.eql ['before called', 'action called', 'after called']
      .promise()
