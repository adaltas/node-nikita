
# `nikita.docker.tools.execute`

Execute a docker command.

## Schema definitions

    definitions =
      config:
        type: 'object'
        allOf: [
          $ref: '#/definitions/docker'
        ,
          properties:
            'bash':
              type: ['boolean', 'string']
              description: '''
              Serialize the command into a file and execute it with bash.
              '''
            'command':
              oneOf: [
                type: 'string'
              ,
                typeof: 'function'
              ]
              description: '''
              String, Object or array; Command to execute. A value provided as a
              function is interpreted as an action and will be called by forwarding
              the config object. The result is the expected to be the command
              to execute.
              '''
            'cwd':
              type: 'string'
              description: '''
              Current working directory from where to execute the command.
              '''
            'code':
              $ref: 'module://@nikitajs/core/src/actions/execute#/definitions/config/properties/code'
              default: {}
            'docker':
              $ref: '#/definitions/docker'
            'format':
              $ref: 'module://@nikitajs/core/src/actions/execute#/definitions/config/properties/format'
        ]
        required: ['command']
      # Note, we can't use additionalProperties properties with anyOf for now,
      # from the doc: "There are some proposals to address this in the next
      # version of the JSON schema specification."
      # additionalProperties: false
      'docker':
        type: 'object'
        description: '''
        Isolate all the parent configuration properties into a docker
        property, used when providing and cascading a docker configuration at
        a global scale.
        '''
        properties:
          'compose':
            type: 'boolean'
            description: '''
            Use the `docker compose` (or `docker-compose`) command instead of
            `docker`.
            '''
          'docker_host':
            type: 'string'
            description: '''
            The value associated with the `DOCKER_HOST` environment variable,
            for example `tcp://dind:2375`.
            '''
          'machine':
            type: 'string'
            format: 'hostname'
            description: '''
            Name of the docker-machine, required if using docker-machine.
            '''
          'opts':
            type: 'object'
            default: {}
            description: '''
            Options passed to the `docker` or `docker compose` command.
            '''

## Handler

    handler = ({config, tools: {find}}) ->
      # Merge global config
      config.docker = await find ({config: {docker}}) -> docker
      config = merge config, config.docker
      # Build Docker 
      config.opts = for option, value of config.opts
        continue if value is null
        value = 'true' if value is true
        value = 'false' if value is false
        if option in ['tlsverify'] then  "--#{option}" else "--#{option}=#{value}"
      config.opts = config.opts.join ' '
      try
        await @execute
          code: config.code
          format: config.format
          trap: true
          command: [
            if config.docker_host
              """
              export DOCKER_HOST=#{config.docker_host}
              """
            if config.machine
              """
              if command -v docker-machine ; then echo 1; fi
              machine='#{config.machine or ''}'
              if [ -z "#{config.machine or ''}" ]; then exit 5; fi
              if docker-machine status "${machine}" | egrep 'Stopped|Saved'; then
                docker-machine start "${machine}";
              fi
              eval "$(docker-machine env ${machine})"
              """
            if config.compose
              """
              opts='#{config.opts}'
              bin=`command -v docker-compose >/dev/null 2>&1  && echo "docker-compose $opts" || echo "docker $opts compose"` 
              $bin #{config.command}
              """
            else
              "docker #{config.opts} #{config.command}"
          ].join '\n'
      catch err
        throw Error err.stderr.trim() if utils.string.lines(err.stderr.trim()).length is 1
        throw Error err.stderr.trim().replace 'Error response from daemon: ', '' if /^Error response from daemon/.test err.stderr

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'command'
        definitions: definitions

## Dependencies

    utils = require '../utils'
    {merge} = require 'mixme'
