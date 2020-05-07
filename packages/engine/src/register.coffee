
registry = require './registry'
error = require './utils/error'

module.exports =
  '': handler: (->)
  'call':
    '': {}
  'execute':
    '': '@nikitajs/engine/src/actions/execute'
    'assert': '@nikitajs/engine/src/actions/execute/assert'
  'fs':
    'chmod': '@nikitajs/engine/src/actions/fs/chmod'
    'chown': '@nikitajs/engine/src/actions/fs/chown'
    'copy': '@nikitajs/engine/src/actions/fs/copy'
    'createReadStream': '@nikitajs/engine/src/actions/fs/createReadStream'
    'createWriteStream': '@nikitajs/engine/src/actions/fs/createWriteStream'
    'exists': '@nikitajs/engine/src/actions/fs/exists'
    'lstat': '@nikitajs/engine/src/actions/fs/lstat'
    'mkdir': '@nikitajs/engine/src/actions/fs/mkdir'
    'readdir': '@nikitajs/engine/src/actions/fs/readdir'
    'readFile': '@nikitajs/engine/src/actions/fs/readFile'
    'readlink': '@nikitajs/engine/src/actions/fs/readlink'
    'rename': '@nikitajs/engine/src/actions/fs/rename'
    'rmdir': '@nikitajs/engine/src/actions/fs/rmdir'
    'stat': '@nikitajs/engine/src/actions/fs/stat'
    'symlink': '@nikitajs/engine/src/actions/fs/symlink'
    'unlink': '@nikitajs/engine/src/actions/fs/unlink'
    'writeFile': '@nikitajs/engine/src/actions/fs/writeFile'
  'log':
    '': handler: (->)
    'cli': '@nikitajs/engine/src/actions/log/cli'
    'csv': '@nikitajs/engine/src/actions/log/csv'
    'fs': '@nikitajs/engine/src/actions/log/fs'
    'md': '@nikitajs/engine/src/actions/log/md'
  'registry':
    'get':
      metadata: raw: true
      handler: ({parent, args: [namespace]}) ->
        parent.registry.get namespace
    'register':
      metadata: raw: true
      handler: ({parent, args: [namespace, action]}) ->
        parent.registry.register namespace, action
    'registered':
      metadata: raw: true
      handler: ({parent, args: [namespace]}) ->
        parent.registry.registered namespace
    'unregister':
      metadata: raw: true
      handler: ({parent, args: [namespace]}) ->
        parent.registry.unregister namespace
  'ssh':
    '': '@nikitajs/engine/src/actions/ssh'
    'open': '@nikitajs/engine/src/actions/ssh/open'
    'close': '@nikitajs/engine/src/actions/ssh/close'
    'root': '@nikitajs/engine/src/actions/ssh/root'
  # 'status':
  #   metadata: raw: true
  #   handler: ({parent, args: [position]}) ->
  #     if typeof position is 'number'
  #       parent.children.slice(position)[0].output.status
  #     else unless position?
  #       parent.children.some (child) -> child.output.status
  #     else
  #       throw error 'NIKITA_STATUS_POSITION_INVALID', [
  #         'argument position must be an integer if defined,'
  #         "get #{JSON.stringify position}"
  #       ]
  'wait': '@nikitajs/engine/src/actions/wait'
(->
  await registry.register module.exports
)()
