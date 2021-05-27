
# `nikita.system.user.remove`

Create or modify a Unix user.

## Callback parameters

* `$status`   
  Value is "true" if user was created or modified.

## Example

```coffee
require('nikita')
.system.user.remove({
  name: 'a_user'
}, function(err, {status}){
  console.log(err ? err.message : 'User removed: ' + status);
})
```

The result of the above action can be viewed with the command
`cat /etc/passwd | grep myself` producing an output similar to
"a\_user:x:490:490:A System User:/home/a\_user:/bin/bash". You can also check
you are a member of the "wheel" group (gid of "10") with the command
`id a\_user` producing an output similar to 
"uid=490(hive) gid=10(wheel) groups=10(wheel)".

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          name:
            type: 'string'
            description: '''
            Name of the user to removed.
            '''
        required: ['name']

## Handler

    handler = ({config}) ->
      @execute
        command: "userdel #{config.name}"
        code_skipped: 6

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
      definitions: definitions
