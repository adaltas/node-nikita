
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.argument (native)', ->
  return unless test.tags.api
  
  describe 'usage', ->

    it 'string', ->
      nikita
        $register: action: (->)
      .action 'abc', 'def', ({metadata: {argument}}) ->
        argument.should.eql 'def'

    it 'boolean', ->
      nikita
        $register: action: (->)
      .action false, true, ({metadata: {argument}}) ->
        argument.should.eql true

    it 'number', ->
      nikita
        $register: action: (->)
      .action 123, 456, ({metadata: {argument}}) ->
        argument.should.eql 456

    it 'null', ->
      nikita
        $register: action: (->)
      .action 'abc', null, ({metadata: {argument}}) ->
        should(argument).eql null
