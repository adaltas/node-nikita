
path = require 'path'
shell = require 'shell'
nikita = require '@nikitajs/core'
require '@nikitajs/log/lib/register'
require '@nikitajs/lxd/lib/register'

module.exports = (config) ->
  shell
    name: 'nikita-test-runner'
    description: '''
    Execute test inside the LXD environment.
    '''
    options:
      container:
        default: "#{config.container}"
        description: '''
        Name of the container.
        '''
        required: !config.container
      cwd:
        default: "#{config.cwd}"
        description: '''
        Absolute path inside the container to use as the working directory.
        '''
        required: !config.cwd
    commands:
      'enter':
        description: '''
        Enter inside the container console.
        '''
        handler: ({params}) ->
          nikita
          .log.cli pad: host: 20, header: 60
          .log.md filename: './logs/enter.md'
          .execute
            $header: 'Container enter'
            command: """
            lxc exec \
              --cwd #{params.cwd} \
              #{params.container} -- bash
            """
            stdio: ['inherit', 'inherit', 'inherit']
            stdin: process.stdin
            stdout: process.stdout
            stderr: process.stderr
      'exec':
        description: '''
        Execute a command inside the container console.
        '''
        main: 'command'
        handler: ({params}) ->
          nikita
          .log.cli pad: host: 20, header: 60
          .log.md filename: './logs/exec.md'
          .execute
            $header: 'Container exec'
            command: """
            lxc exec \
              --cwd #{params.cwd} \
              #{params.container} -- #{params.command}
            """
            stdio: ['inherit', 'inherit', 'inherit']
            stdin: process.stdin
            stdout: process.stdout
            stderr: process.stderr
      'run':
        description: '''
        Start and stop the container and execute all the tests.
        '''
        handler: ({params}) ->
          nikita
          .log.cli pad: host: 20, header: 60
          .log.md filename: './logs/start.md'
          .call '@nikitajs/lxd-runner/lib/actions/run', {...config, ...params}
      'start':
        description: '''
        Start the container.
        '''
        handler: ({params}) ->
          nikita
          .log.cli pad: host: 20, header: 60
          .log.md filename: './logs/start.md'
          .call '@nikitajs/lxd-runner/lib/actions/start', {...config, ...params}
      'stop':
        description: '''
        Stop the container.
        '''
        handler: ({params}) ->
          nikita
          .log.cli pad: host: 20, header: 60
          .log.md filename: './logs/stop.md'
          .call '@nikitajs/lxd-runner/lib/actions/stop', {...config, ...params}
      'test':
        description: '''
        Execute all the tests.
        '''
        handler: ({params}) ->
          nikita
          .log.cli pad: host: 20, header: 60
          .log.md filename: './logs/test.md'
          .call '@nikitajs/lxd-runner/lib/actions/test', {...config, ...params}
  .route()
