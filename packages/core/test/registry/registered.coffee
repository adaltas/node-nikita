
import nikita from '@nikitajs/core'
import registry from '@nikitajs/core/registry'
import test from '../test.coffee'

describe 'registry.registered', ->
  return unless test.tags.api

  describe 'global', ->

    it 'return false with 1 level', ->
      registry.registered('does_not_exists').should.be.false()
      registry.registered(['does_not_exists']).should.be.false()

    it 'return false with multi level', ->
      registry.registered(['does', 'not', 'exists']).should.be.false()

    it 'return true with 1 level', ->
      await registry.register ['my_module'], (->)
      registry.registered('my_module').should.be.true()
      registry.registered(['my_module']).should.be.true()
      registry.unregister ['my_module']

    it 'return true with multi level', ->
      await registry.register ['my', 'module'], (->)
      registry.registered(['my', 'module']).should.be.true()
      registry.registered(['my']).should.be.false()
      registry.unregister ['my', 'module']

  describe 'local', ->

    it 'return false with 1 level', ->
      nikita
      .registry.registered
        namespace: 'does_not_exists'
      .should.finally.be.false()
      nikita
      .registry.registered
        namespace: ['does_not_exists']
      .should.finally.be.false()

    it 'return false with multi level ', ->
      nikita
      .registry.registered
        namespace: ['does', 'not', 'exists']
      .should.finally.be.false()

    it 'return true with 1 level', ->
      # With the current fluent API, no action can be called asynchronously.
      n = nikita.registry.register
        namespace: ['my_action']
        action: handler: (->)
      await n.registry.registered
        namespace: 'my_action'
      .should.finally.be.true()
      n
      .registry.registered
        namespace: ['my_action']
      .should.be.rejectedWith 'NIKITA_SCHEDULER_CLOSED: cannot schedule new items when closed.'

    it 'return true with multi level', ->
      await nikita
      .registry.register
        namespace: ['my', 'module'],
        action: handler: (->)
      .registry.registered
        namespace: ['my']
      .should.finally.be.false()

  describe 'parent', ->

    it 'accept property declared in parent', ->
      reg_0 = registry.create()
      reg_0.register 'parent_0_action', (->)
      reg_1 = registry.create parent: reg_0
      reg_1.register 'parent_1_action', (->)
      reg_2 = registry.create parent: reg_1
      reg_2.register 'parent_2_action', (->)
      reg_2.registered('parent_2_action').should.be.true()
      reg_2.registered('parent_1_action').should.be.true()
      reg_2.registered('parent_0_action').should.be.true()
  
  describe 'partial', ->

    it 'check action', ->
      reg = registry.create()
      reg.register ['my', 'nice', 'module'], (->)
      reg.registered(['my', 'nice', 'module'], partial: true).should.be.true()

    it 'check namespace', ->
      reg = registry.create()
      reg.register ['my', 'nice', 'module'], (->)
      reg.registered(['my'], partial: true).should.be.true()
      reg.registered(['my', 'nice'], partial: true).should.be.true()

    it 'ensure non enumerable property are skipped', ->
      reg = registry.create()
      reg.registered(['register'], partial: true).should.be.false()

    it 'option partial check all path', ->
      reg = registry.create()
      reg.register ['my', 'nice', 'module'], (->)
      reg.registered(['wrong', 'nice'], partial: true).should.be.false()

    it 'honor parent', ->
      reg_parent = registry.create()
      reg_parent.register ['my', 'nice', 'module'], (->)
      reg_child = registry.create parent: reg_parent
      reg_child.registered(['my', 'nice'], partial: true).should.be.true()
