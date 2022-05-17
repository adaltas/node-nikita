# `nikita.lxc.file.pull`

Pull files from containers.

## Example

```js
const {$status} = await nikita.lxc.file.pull({
  container: 'my_container',
  source: '/root/a_file',
  target: `./folder/a_file`
})
console.info(`File was pulled: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'algo':
            $ref: 'module://@nikitajs/core/lib/actions/fs/hash#/definitions/config/properties/algo'
            default: 'md5'
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
            description: '''
            Name of the container in lxd.
            '''
          'source':
            type: 'string'
            description: '''
            Container side. Path to the file to pull from the container.
            '''
          'target':
            type: 'string'
            description: '''
            Local machine side. Path to the destination of the file once it has been pulled from the container, inside the local machine.
            '''
          'create_dirs':
            type: 'boolean'
            default: false
            description: '''
            Local machine side. If true, create any directories necessary when pulling the image to your local machine.
            '''
        required: ['container', 'source', 'target']

## Handler

    handler = ({config, metadata: {tmpdir}}) ->
      throw Error "Invalid Option: source is required" if not config.source 
      throw Error "Invalid Option: target is required" if not config.target 
      {$status} = await @lxc.running
        container: config.container
      status_running = $status
      if $status
        try
          {$status} = await @execute
            command: """
            # Is open ssl installed on host?
            command -v openssl >/dev/null || exit 2
            # Ensure source is a file
            lxc exec #{config.container} -- [ -f "#{config.source}" ] || exit 3
            # Get source hash
            sourceDgst=`cat <<EOF | lxc exec #{config.container} -- sh
            # Ensure openssl is available
            command -v openssl >/dev/null || exit 4
            # Source does not exist
            openssl dgst -#{config.algo} #{config.source} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
            EOF`
            targetDgst=`openssl dgst -#{config.algo} #{config.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'`
            [ "$sourceDgst" != "$targetDgst" ] || exit 42
            """
            code: [0, 42]
            trap: true
        catch err
          throw Error "Invalid Requirement: openssl not installed on host" if err.exit_code is 2
          throw Error "Invalid Option: source is not a file, got #{JSON.stringify config.source}" if err.exit_code is 3
          throw utils.error 'NIKITA_LXD_FILE_PULL_MISSING_OPENSSL', [
            'the openssl package must be installed in the container'
            'and accessible from the `$PATH`.'
          ] if err.exit_code is 4
      if not status_running or $status
        # note, if create_dirs is true, create recursive directories
        if config.create_dirs 
          await @fs.mkdir path.dirname config.target 
        # note, if the target doesn't have a filename, we take the one of the source
        if config.target.endsWith('/')
          config.target = path.join config.target, path.basename config.source
        # note, we call lxc query to make an api call and we output in the file we want
        {data, $status} = await @lxc.query
          path: "/1.0/instances/#{config.container}/files?path=#{config.source}"
          wait: true
          format: 'string'
        await @fs.base.writeFile
          target: config.target
          content: data
        $status: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        tmpdir: true
        definitions: definitions

## Dependencies

    path = require 'path'
    utils = require '../utils'
