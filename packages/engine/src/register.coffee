
registry = require './registry'
utils = require './utils'

module.exports =
  '': handler: (->)
  'assert': '@nikitajs/engine/src/actions/assert'
  'call':
    '': {}
  'execute':
    '': '@nikitajs/engine/src/actions/execute'
    'assert': '@nikitajs/engine/src/actions/execute/assert'
    'wait': '@nikitajs/engine/src/actions/execute/wait'
  'fs':
    'base':
      'chmod': '@nikitajs/engine/src/actions/fs/base/chmod'
      'chown': '@nikitajs/engine/src/actions/fs/base/chown'
      'copy': '@nikitajs/engine/src/actions/fs/base/copy'
      'createReadStream': '@nikitajs/engine/src/actions/fs/base/createReadStream'
      'createWriteStream': '@nikitajs/engine/src/actions/fs/base/createWriteStream'
      'exists': '@nikitajs/engine/src/actions/fs/base/exists'
      'lstat': '@nikitajs/engine/src/actions/fs/base/lstat'
      'mkdir': '@nikitajs/engine/src/actions/fs/base/mkdir'
      'readdir': '@nikitajs/engine/src/actions/fs/base/readdir'
      'readFile': '@nikitajs/engine/src/actions/fs/base/readFile'
      'readlink': '@nikitajs/engine/src/actions/fs/base/readlink'
      'rename': '@nikitajs/engine/src/actions/fs/base/rename'
      'rmdir': '@nikitajs/engine/src/actions/fs/base/rmdir'
      'stat': '@nikitajs/engine/src/actions/fs/base/stat'
      'symlink': '@nikitajs/engine/src/actions/fs/base/symlink'
      'unlink': '@nikitajs/engine/src/actions/fs/base/unlink'
      'writeFile': '@nikitajs/engine/src/actions/fs/base/writeFile'
    'assert': '@nikitajs/engine/src/actions/fs/assert'
    'chmod': '@nikitajs/engine/src/actions/fs/chmod'
    'chown': '@nikitajs/engine/src/actions/fs/chown'
    'copy': '@nikitajs/engine/src/actions/fs/copy'
    'glob': '@nikitajs/engine/src/actions/fs/glob'
    'hash': '@nikitajs/engine/src/actions/fs/hash'
    'link': '@nikitajs/engine/src/actions/fs/link'
    'mkdir': '@nikitajs/engine/src/actions/fs/mkdir'
    'move': '@nikitajs/engine/src/actions/fs/move'
    'remove': '@nikitajs/engine/src/actions/fs/remove'
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
  #       throw utils.error 'NIKITA_STATUS_POSITION_INVALID', [
  #         'argument position must be an integer if defined,'
  #         "get #{JSON.stringify position}"
  #       ]
  'wait': '@nikitajs/engine/src/actions/wait'
(->
  await registry.register module.exports
)()
