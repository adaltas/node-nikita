
# `nikita.ipa.group.add_member`

Add member to a group in FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group.add_member({
  cn: "somegroup",
  attributes: {
    user: ["someone"]
  },
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Member was added to the group: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cn':
            type: 'string'
            description: '''
            Name of the group to add.
            '''
          'attributes':
            type: 'object'
            properties:
              'user': type: 'array', minItems: 1, uniqueItems: true, items: type: 'string'
            description: '''
            Attributes associated with the group such as `ipaexternalmember`,
            `no_members`, `user` and `group`.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['cn', 'connection']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "group_add_member/1"
          params: [[config.cn], config.attributes]
          id: 0
      if data.error
        error = Error data.error.message
        error.code = data.error.code
        throw error
      else
        $status: true, result: data.result.result

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
