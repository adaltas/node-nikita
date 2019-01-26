
module.exports =
  is: (obj) ->
    # promise && !!promise.then
    return !!obj and (typeof obj is 'object' || typeof obj is 'function') and typeof obj.then is 'function'
