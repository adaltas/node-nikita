
parameters = require 'parameters'

parameters
  name: 'lxdvmhost'
  description: "LXD VM host based on Virtual Box"
  commands:
    'start':
      description: 'Start the cluster'
      options:
        debug:
          type: 'boolean'
          shortcut: 'b'
          description: 'Print debug output'
        log:
          type: 'string'
          description: 'Path to the directory storing logs.'
      route: require './start'
    'stop':
      description: 'Stop the cluster'
      options:
        debug:
          type: 'boolean'
          shortcut: 'b'
          description: 'Print debug output'
        log:
          type: 'string'
          description: 'Path to the directory storing logs.'
      route: require './stop'
.route()
