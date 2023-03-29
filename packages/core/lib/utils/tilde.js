
const tilde = require('tilde-expansion');
const path = require('path');

/*
Not, those function are not aware of an SSH connection
and can't use `path.posix` when appropriate over SSH.
It could be assumed that a path starting with `~` is 
always posix but this is not yet handled and tested.
*/
module.exports = {
  normalize: function(location) {
    return new Promise(function(accept, reject) {
      return tilde(location, function(location) {
        return accept(path.normalize(location));
      });
    });
  },
  resolve: async function(...locations) {
    const normalized = locations.map(module.exports.normalize)
    const paths = (await Promise.all(normalized));
    return path.resolve(...paths);
  }
};
