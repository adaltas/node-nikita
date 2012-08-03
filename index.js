
require('iced-coffee-script');

var mecano = require('./lib/mecano');
var misc = require('./lib/misc');
for(var k in misc){
    mecano[k] = misc[k];
}
module.exports = mecano;
