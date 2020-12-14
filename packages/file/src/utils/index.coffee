
utils = require "@nikitajs/engine/lib/utils"

module.exports = {
  ...utils
  curl: require './curl'
  ini: require './ini'
  partial: require './partial'
}
