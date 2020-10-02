
# registration of `nikita.file` actions

registry = require '@nikitajs/engine/src/registry'

module.exports =
  file:
    '': '@nikitajs/file/src'
    cache: '@nikitajs/file/src/cache'
    cson: '@nikitajs/file/src/cson'
    download: '@nikitajs/file/src/download'
    ini: '@nikitajs/file/src/ini'
    json: '@nikitajs/file/src/json'
    properties:
      '': '@nikitajs/file/src/properties'
      read: '@nikitajs/file/src/properties/read'
    render: '@nikitajs/file/src/render'
    touch: '@nikitajs/file/src/touch'
    types:
      'ceph_conf': '@nikitajs/file/src/types/ceph_conf'
    upload: '@nikitajs/file/src/upload'
    yaml: '@nikitajs/file/src/yaml'
(->
  await registry.register module.exports
)()
