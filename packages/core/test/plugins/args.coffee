
# import nikita from '@nikitajs/core'
# import test from '../test.coffee'

# describe 'plugins.args', ->
#   return unless test.tags.api

#   it 'argument is a function', ->
#     nikita.call ({args}) ->
#       args.length.should.eql 1
#       args[0].should.be.a.Function()

#   it 'argument is an object', ->
#     nikita
#     .registry.register
#       namespace: ['an', 'action']
#       action: ({args}) -> args
#     .an.action a_key: 'a value'
#     .then (args) ->
#       args.should.eql [ a_key: 'a value' ]

#   it 'argument is a string', ->
#     nikita
#     .registry.register
#       namespace: ['an', 'action']
#       action: ({args}) -> args
#     .an.action 'a value'
#     .then (args) ->
#       args.should.eql [ 'a value' ]

#   it 'argument is an [object]', ->
#     nikita
#     .registry.register
#       namespace: ['an', 'action']
#       action: handler: ({args}) -> args
#     .an.action [{a_key: 1}, {a_key: 2}]
#     .then (actions) ->
#       actions.should.eql [
#         [ { a_key: 1 } ]
#         [ { a_key: 2 } ]
#       ]

#   it 'argument is an [object], [string]', ->
#     nikita
#     .registry.register
#       namespace: ['an', 'action']
#       action: handler: ({args}) -> args
#     .an.action [{a_key: 1}, {a_key: 2}], ['a_string', 'b_string']
#     .then (actions) ->
#       actions.should.eql [
#         [ { a_key: 1 }, 'a_string' ]
#         [ { a_key: 2 }, 'a_string' ]
#         [ { a_key: 1 }, 'b_string' ]
#         [ { a_key: 2 }, 'b_string' ]
#       ]

#   it 'with raw_input option', ->
#     nikita
#     .registry.register
#       namespace: ['an', 'action']
#       action:
#         metadata: raw_input: true
#         handler: ({args}) -> args
#     .an.action [{a_key: 1}, {a_key: 2}]
#     .should.be.resolvedWith [[ { a_key: 1 }, {a_key: 2} ]]
