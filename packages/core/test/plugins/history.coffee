
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.history', ->
  return unless tags.api

  describe 'children', ->

    it 'get previous action', ->
      nikita.call ->
        @call -> 'mayday'
        @call ({parent}) ->
          parent.children[0].output
      .should.be.resolvedWith 'mayday'

    it 'get previous action children', ->
      nikita.call ->
        @call -> @call -> 'mayday'
        @call ({parent}) ->
          parent.children[0].children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'siblings', ->
    
    it 'start with empty array', ->
      nikita ({siblings}) ->
        siblings.should.eql []

    it 'get previous action', ->
      nikita.call ->
        @call -> 'mayday'
        @call ({siblings}) ->
          siblings.slice(-1)[0].output
      .should.be.resolvedWith 'mayday'

    it 'get previous slibling children', ->
      nikita.call ->
        @call -> @call -> 'mayday'
        @call ({siblings}) ->
          siblings.slice(-1)[0].children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'sibling', ->

    it 'get previous action', ->
      nikita.call ->
        @call -> 'mayday'
        @call ({sibling}) ->
          sibling.output
      .should.be.resolvedWith 'mayday'

    it 'get previous slibling children', ->
      nikita.call ->
        @call -> @call -> 'mayday'
        @call ({sibling}) ->
          sibling.children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'bastard', ->

    it 'child not attached to parent', ->
      nikita.call ->
        @call $bastard: true, (->)
        @call ({parent}) ->
          parent.children.length.should.eql 0
