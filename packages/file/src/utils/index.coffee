
utils = require '@nikitajs/core/lib/utils'

module.exports = {
  ...utils
  diff: require './diff'
  ini: require './ini'
  partial: require './partial'
}
