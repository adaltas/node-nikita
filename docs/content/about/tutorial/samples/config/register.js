// hide-next-line
const nikita = require('nikita');
// Dependencies
const assert = require('assert');
(async () => {
  // hide-range{1-2}
  // Cleanup the state
  await nikita.fs.remove({source: '/tmp/a_file'})
  // New Nikita session
  var {status} = await nikita
  // Register the touch action
  .registry.register({touch: './lib/touch'})
  // Calling the registered action
  .touch({target: '/tmp/a_file'})
  assert.equal(status, true)
})()
