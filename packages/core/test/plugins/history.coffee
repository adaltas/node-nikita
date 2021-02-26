
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.history', ->
  return unless tags.api

  describe 'children', ->

    it 'get previous action', ->
      nikita.call ({context}) ->
        @call -> 'mayday'
        @call ({parent}) ->
          parent.children[0].output
      .should.be.resolvedWith 'mayday'

    it 'get previous action children', ->
      nikita.call ({context}) ->
        @call -> @call -> 'mayday'
        @call ({parent}) ->
          parent.children[0].children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'siblings', ->
    
    it 'start with empty array', ->
      nikita ({siblings}) ->
        siblings.should.eql []

    it 'get previous action', ->
      nikita.call ({context}) ->
        @call -> 'mayday'
        @call ({parent, siblings}) ->
          siblings.slice(-1)[0].output
      .should.be.resolvedWith 'mayday'

    it 'get previous slibling children', ->
      nikita.call ({context}) ->
        @call -> @call -> 'mayday'
        @call ({parent, siblings}) ->
          siblings.slice(-1)[0].children[0].output
      .should.be.resolvedWith 'mayday'
              
  describe 'sibling', ->

    it 'get previous action', ->
      nikita.call ({context}) ->
        @call -> 'mayday'
        @call ({parent, sibling}) ->
          sibling.output
      .should.be.resolvedWith 'mayday'

    it 'get previous slibling children', ->
      nikita.call ({context}) ->
        @call -> @call -> 'mayday'
        @call ({parent, sibling}) ->
          sibling.children[0].output
      .should.be.resolvedWith 'mayday'
