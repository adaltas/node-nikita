
# `nikita.network.http.wait`

Check if one or multiple hosts listen one or multiple ports periodically over an
HTTP connection and continue once all the connections succeed. Status will be
set to "false" if the user connections succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Return

Status is set to "true" if the first connection attempt was a failure and the 
connection finaly succeeded.


## Schema definitions

    definitions =
      config:
        type: 'object'
        $ref: 'module://@nikitajs/network/src/http#/definitions/config'
        properties:
          'interval':
            default: 2000 # see https://github.com/ajv-validator/ajv/issues/337
            $ref: 'module://@nikitajs/network/src/tcp/wait#/definitions/config/properties/interval'
          status_code:
            type: 'array'
            default: ['1xx', '2xx', '3xx']
            items:
              oneOf: [
                type: 'string'
              ,
                instanceof: 'RegExp'
              ]
            description: '''
            Accepted status codes. Accepted values are strings and regular
            expressions. String patterns are defined using the `x` character.
            For example the value `5xx` accept all HTTP status code from the 5
            class.
            '''
          'timeout':
            $ref: 'module://@nikitajs/network/src/tcp/wait#/definitions/config/properties/timeout'
          

## Handler

    handler = ({config, tools: {log}}) ->
      start = Date.now()
      config.status_code = config.status_code.map (item) ->
        item = new RegExp '^'+item.replaceAll('x', '\\d')+'$' if typeof item is 'string'
        item
      count = 0
      while true
        {error, status_code} = await @network.http
          $relax: true
          method: config.method
          url: config.url
        log
          message: if error
          then "Attemp #{count} faild with error"
          else "Attemp #{count} return status #{status_code}"
          attempt: count
          status_code: status_code
        return count > 0 if not error and config.status_code.some (code) -> code.test status_code
        await @wait config.interval
        if config.timeout and start + config.timeout > Date.now()
          throw errors.NIKITA_HTTP_WAIT_TIMEOUT({config})
        count++

## Errors

    errors =
      NIKITA_HTTP_WAIT_TIMEOUT: ({config}) ->
        utils.error 'NIKITA_HTTP_WAIT_TIMEOUT', [
          "timeout reached after #{config.timeout}ms."
        ]

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
