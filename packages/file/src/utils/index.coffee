
utils = require "@nikitajs/engine/src/utils"

module.exports = {
  ...utils
  curl: require './curl'
  partial: require './partial'
}
