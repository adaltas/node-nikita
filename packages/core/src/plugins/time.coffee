
module.exports =
  name: '@nikitajs/core/src/plugins/time'
  hooks:
    'nikita:session:action':
      handler: (action) ->
        action.metadata.time_start = Date.now()
    'nikita:session:result':
      before: '@nikitajs/core/src/plugins/history'
      handler: ({action}) ->
        action.metadata.time_end = Date.now()
