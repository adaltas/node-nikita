
###
Plugin `pubsub`

Provide a mechanism for actions to wait for a key to be published before
continuing their execution.

###


module.exports =
  name: '@nikitajs/engine/src/plugins/pubsub'
  require:
    '@nikitajs/engine/src/plugins/tools_find'
  hooks:
    'nikita:session:action': (action) ->
      engine = await action.tools.find ({metadata}) ->
        metadata.pubsub
      return action unless engine
      action.tools.pubsub =
        get: (key) ->
          engine.get key
        set: (key, value) ->
          engine.set key, value
      action
