
utils = require '@nikitajs/core/lib/utils'
diff = require '@nikitajs/file/lib/utils/diff'

module.exports = {
  ...utils
  diff: diff,
  iptables: require './iptables'
}
