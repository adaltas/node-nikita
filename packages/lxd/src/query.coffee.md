
# `nikita.lxc.query`

Send a raw query to LXD.

## Example

```js
const { data } = await nikita.lxc.query({
  path: "/1.0/instances/c1",
});
console.info(`Container c1 info: ${data}`);
```

## TODO

The `lxc query` command comes with a few flag which we shall support:

```
Flags:
      --raw       Print the raw response
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'code':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/code'
          'data':
            type: 'string'
            description: '''
            Data to send to the action in the form of application/json stringified object.
            '''
          'format':
            type: 'string'
            enum: ['json', 'string']
            default: 'json'
            description: '''
            Format to use for the output data, either `json` or `string`.
            '''
          'path':
            type: 'string'
            description: '''
            The API path in the form of `[<remote>:]<API path>`, for example
            `/1.0/instances/c1`
            '''
          'request':
            enum: ['GET', 'PUT', 'DELETE', 'POST', 'PATCH']
            default: 'GET'
            description: '''
            Action to use for the API call.
            '''
          'wait':
            type: 'boolean'
            default: false
            description: '''
            If true, activates the wait flag that waits for the operation to complete.
            '''
        required: ['path']

## Handler

    handler = ({config}) ->
      {$status, stdout} = await @execute
        command: [
          'lxc', 'query', 
          "--wait" if config.wait, 
          "--request", config.request, 
          "--data '#{config.data}'" if config.data?, 
          config.path,
          # "|| exit 42"
        ].join ' '
        code: config.code
      $status: $status
      switch config.format
        when 'json' 
         if $status then data: JSON.parse stdout else data: {}
        when 'string' 
         if $status then data: stdout else data: ""
      

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
