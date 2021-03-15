# `nikita.lxc.cluster.stop`

Delete a cluster of LXD instances.

## Example

```yaml
networks:
  lxdbr0public: {}
  lxdbr1private: {}
containers:
  nikita:
    image: "images:centos/7"
predelete: path/to/action
```

## Schema

    schema =
      type: 'object'
      properties:
        'containers':
          $ref: 'module://@nikitajs/lxd/src/cluster#/properties/containers'
        'networks':
          type: 'object'
          default: {}
          patternProperties: '.*':
            $ref: 'module://@nikitajs/lxd/src/network#/properties/properties'
        'force':
          type: 'boolean'
          default: false
          description: """
          If true, the containers will be deleted even if running.
          """
        'pre_delete':
          typeof: 'function'
      required: ['containers']

## Handler

    handler = ({config}) ->
      # Run action before delete
      if !!config.pre_delete
        await @call config, config.pre_delete
      # Delete containers
      for containerName, containerConfig of config.containers
        await @lxc.delete
          $header: "Container #{containerName} : delete"
          container: containerName
          force: config.force
      for networkName, networkConfig of config.networks
        await @lxc.network.delete
          $header: "Network #{networkName} : delete"
          network: networkName
      {}

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
