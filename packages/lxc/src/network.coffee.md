# `nikita.lxc.network`

Initialize a Linux Container with given image name, container name and options

## Options

Options for the different commands

### `network.create`
* `name`
  The network name
* `config`
  The network initial configuration

### `network.delete`
* `name`
  The network to delete

### `network.config`
* `name`
  The network name to configure
* `config`
  The new configuration

### `network.attach` and `network.detach`
* `name`
  Network name
* `container`
  Container name

## Callback Parameters
* `err`
  Error object if any
* `status`
  Was the operation was succesfull

## Example
```
require('nikita')
.lxc.network.create({
  name: "net0"
}, function(err, {status}) {
  console.log( err ? err.message : 'The network was created')
});

```

## Source Code

    module.exports.create = ({options}, callback) ->
      @log message: "Entering Network create", level: "DEBUG", module: "nikita/lib/lxc/network/create"
      # TODO

    module.exports.delete = ({options}, callback) ->
      @log message: "Entering Network delete", level: "DEBUG", module: "nikita/lib/lxc/network/delete"
      # TODO

    module.exports.configure = ({options}, callback) ->
      @log message: "Entering Network configure", level: "DEBUG", module: "nikita/lib/lxc/network/configure"
      # TODO

    module.exports.attach = ({options}, callback) ->
      @log message: "Entering Network attach", level: "DEBUG", module: "nikita/lib/lxc/network/attach"
      # TODO

    module.exports.detach = ({options}, callback) ->
      @log message: "Entering Network detach", level: "DEBUG", module: "nikita/lib/lxc/network/detach"
      # TODO
