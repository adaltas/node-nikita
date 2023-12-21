
import nikita from '@nikitajs/core'
import test from '../test.coffee'

describe 'plugins.history', ->
  return unless test.tags.api

  describe 'children', ->

    it 'get previous action', ->
      nikita.call ->
        await @call -> 'mayday'
        await @call ({parent}) ->
          parent.children[0].output
      .should.be.resolvedWith 'mayday'

    it 'get previous action children', ->
      nikita.call ->
        await @call -> @call -> 'mayday'
        await @call ({parent}) ->
          parent.children[0].children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'siblings', ->
    
    it 'start with empty array', ->
      nikita ({siblings}) ->
        siblings.should.eql []

    it 'get previous action', ->
      nikita.call ->
        await @call -> 'mayday'
        await @call ({siblings}) ->
          siblings.slice(-1)[0].output
      .should.be.resolvedWith 'mayday'

    it 'get previous slibling children', ->
      nikita.call ->
        await @call -> @call -> 'mayday'
        await @call ({siblings}) ->
          siblings.slice(-1)[0].children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'sibling', ->
    
    it 'an alias of last element in siblings', ->
      nikita.call ->
        await @call -> 'send'
        await @call -> 'mayday'
        await @call $raw_output: true, ({sibling, siblings}) ->
          should(sibling is siblings[siblings.length - 1]).be.true()
          sibling.should.eql siblings[siblings.length - 1]

    it 'get previous action', ->
      nikita.call ->
        await @call -> 'send'
        await @call -> 'mayday'
        await @call ({sibling}) ->
          sibling.output
      .should.be.resolvedWith 'mayday'

    it 'get previous slibling children', ->
      nikita.call ->
        await @call -> 'send'
        await @call -> @call -> 'mayday'
        await @call ({sibling}) ->
          sibling.children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'bastard', ->

    it 'child not attached to parent', ->
      nikita.call ->
        await @call $bastard: true, (->)
        await @call ({parent}) ->
          parent.children.length.should.eql 0
