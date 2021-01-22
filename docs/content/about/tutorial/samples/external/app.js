const nikita = require('nikita');
// Dependencies
const assert = require('assert');
const touch = require('./lib/touch');
(async () => {
  // New Nikita session
  var {status} = await nikita.call(touch)
  assert.equal(status, true)
})()
