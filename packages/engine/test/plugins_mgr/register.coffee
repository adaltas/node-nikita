
plugins = require '../../src/plugins'

describe 'session.plugins.register', ->

  it 'validate arguments', ->
    (->
      plugins().register (->)
    ).should.throw [
      'PLUGINS_REGISTER_INVALID_ARGUMENT:'
      'a plugin must consist of keys representing the hook module name'
      'associated with function implementing the hook, got function() {}.'
    ].join ' '
