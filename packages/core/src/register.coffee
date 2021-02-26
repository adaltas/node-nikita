
registry = require './registry'
utils = require './utils'

module.exports =
  '': handler: (->)
  'assert': '@nikitajs/core/src/actions/assert'
  'call':
    '': '@nikitajs/core/src/actions/call'
  'execute':
    '': '@nikitajs/core/src/actions/execute'
    'assert': '@nikitajs/core/src/actions/execute/assert'
    'wait': '@nikitajs/core/src/actions/execute/wait'
  'fs':
    'base':
      'chmod': '@nikitajs/core/src/actions/fs/base/chmod'
      'chown': '@nikitajs/core/src/actions/fs/base/chown'
      'copy': '@nikitajs/core/src/actions/fs/base/copy'
      'createReadStream': '@nikitajs/core/src/actions/fs/base/createReadStream'
      'createWriteStream': '@nikitajs/core/src/actions/fs/base/createWriteStream'
      'exists': '@nikitajs/core/src/actions/fs/base/exists'
      'lstat': '@nikitajs/core/src/actions/fs/base/lstat'
      'mkdir': '@nikitajs/core/src/actions/fs/base/mkdir'
      'readdir': '@nikitajs/core/src/actions/fs/base/readdir'
      'readFile': '@nikitajs/core/src/actions/fs/base/readFile'
      'readlink': '@nikitajs/core/src/actions/fs/base/readlink'
      'rename': '@nikitajs/core/src/actions/fs/base/rename'
      'rmdir': '@nikitajs/core/src/actions/fs/base/rmdir'
      'stat': '@nikitajs/core/src/actions/fs/base/stat'
      'symlink': '@nikitajs/core/src/actions/fs/base/symlink'
      'unlink': '@nikitajs/core/src/actions/fs/base/unlink'
      'writeFile': '@nikitajs/core/src/actions/fs/base/writeFile'
    'assert': '@nikitajs/core/src/actions/fs/assert'
    'chmod': '@nikitajs/core/src/actions/fs/chmod'
    'chown': '@nikitajs/core/src/actions/fs/chown'
    'copy': '@nikitajs/core/src/actions/fs/copy'
    'glob': '@nikitajs/core/src/actions/fs/glob'
    'hash': '@nikitajs/core/src/actions/fs/hash'
    'link': '@nikitajs/core/src/actions/fs/link'
    'mkdir': '@nikitajs/core/src/actions/fs/mkdir'
    'move': '@nikitajs/core/src/actions/fs/move'
    'remove': '@nikitajs/core/src/actions/fs/remove'
    'wait': '@nikitajs/core/src/actions/fs/wait'
  'log':
    '': handler: (->)
    'cli': '@nikitajs/core/src/actions/log/cli'
    'csv': '@nikitajs/core/src/actions/log/csv'
    'fs': '@nikitajs/core/src/actions/log/fs'
    'md': '@nikitajs/core/src/actions/log/md'
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
    'open': '@nikitajs/core/src/actions/ssh/open'
    'close': '@nikitajs/core/src/actions/ssh/close'
    'root': '@nikitajs/core/src/actions/ssh/root'
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
  'wait': '@nikitajs/core/src/actions/wait'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
