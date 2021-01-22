const nikita = require('nikita');
// Dependencies
const assert = require('assert');
(async () => {
  // New Nikita session
  var {status} = await nikita
  // Register the touch action
  .registry.register({'touch': './lib/touch'})
  // Calling the registered action
  .touch({'target': '/tmp/a_file'})
  assert.equal(status, true)
})()
