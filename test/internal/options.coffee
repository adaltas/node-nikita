
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api callback', ->

  scratch = test.scratch @

  it 'multiple options', ->
    nikita()
    .internal.options [
      [{key_1_1: '1.1'}, {key_1_2: '1.2'}]
      [{key_2_1: '2.1'}, {key_2_2: '2.2'}]
      # (->)
    ] , 'call'
    .map((action) ->
      (action.handler is undefined).should.be.a.true()
      action.action.should.eql ['call']
      action.sleep.should.eql 3000
      action.retry.should.eql 0
      action.disabled.should.be.false()
      action.status.should.be.true()
      action
    )
    .map((action) ->
      filter = {}
      for k, v of action
        filter[k] = v if /^key_/.test k
      filter
    ).should.eql [
      { key_1_1: '1.1', key_2_1: '2.1' }
      { key_1_2: '1.2', key_2_1: '2.1' }
      { key_1_1: '1.1', key_2_2: '2.2' },
      { key_1_2: '1.2', key_2_2: '2.2' }
    ]

  it 'interpret function as handler', ->
    nikita()
    .internal.options [
      [{key_1_1: '1.1'}, {key_1_2: '1.2'}]
      [{key_2_1: '2.1'}, {key_2_2: '2.2'}]
      (->)
    ] , 'call'
    .map((action) ->
      action.handler.should.be.a.Function()
      action
    )
    .map((action) ->
      filter = {}
      for k, v of action
        filter[k] = v if /^key_/.test k
      filter
    )
    .should.eql [
      { key_1_1: '1.1', key_2_1: '2.1' }
      { key_1_2: '1.2', key_2_1: '2.1' }
      { key_1_1: '1.1', key_2_2: '2.2' },
      { key_1_2: '1.2', key_2_2: '2.2' }
    ]

  it 'interpret strings as a module exporting a function', (next) ->
    nikita
    .file
      target: "#{scratch}/a_module.js"
      content: '''
      module.exports = function(){
        return 'ok';
      }
      '''
    .call ->
      @internal.options [
        [{key: '1.1'}, {key: '1.2'}]
        "#{scratch}/a_module"
      ] , 'call'
      .map((action) ->
        action.handler().should.eql 'ok'
        action
      )
      .map((action) -> action.key )
      .should.eql [ '1.1', '1.2' ]
    .next next

  it 'overwrite module exported handler and user provided handler', (next) ->
    nikita
    .file
      target: "#{scratch}/module_exported_handler_and_user_provided_handler.js"
      content: '''
      module.exports = function(){
        return 'module';
      }
      '''
    .call ->
      @internal.options [
        [{key: '1.1'}, {key: '1.2'}]
        (-> 'user')
        "#{scratch}/module_exported_handler_and_user_provided_handler"
      ] , 'call'
      .map((action) ->
        action.handler().should.eql 'module'
        action.callback().should.eql 'user'
        action
      )
      .map((action) -> action.key )
      .should.eql [ '1.1', '1.2' ]
    .call ->
      @internal.options [
        [{key: '1.1'}, {key: '1.2'}]
        "#{scratch}/module_exported_handler_and_user_provided_handler"
        (-> 'user')
      ] , 'call'
      .map((action) ->
        action.handler().should.eql 'module'
        action.callback().should.eql 'user'
        action
      )
      .map((action) -> action.key )
      .should.eql [ '1.1', '1.2' ]
    .next next
