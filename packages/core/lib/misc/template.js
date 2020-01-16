// Generated by CoffeeScript 2.5.0
var nunjucks;

module.exports = function(string, options) {
  if (options.engine == null) {
    options.engine = 'nunjunks';
  }
  switch (options.engine) {
    case 'nunjunks':
      return (new nunjucks.Environment()).renderString(string, options);
    default:
      throw Error(`Invalid engine: ${options.engine}`);
  }
};

nunjucks = require('nunjucks/src/environment');
