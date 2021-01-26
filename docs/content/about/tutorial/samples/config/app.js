// hide-next-line
const nikita = require('nikita');
// Dependencies
const assert = require('assert');
(async () => {
  // hide-range{1-2}
  // Cleanup the state
  await nikita.fs.remove({source: "/tmp/a_file"})
  // New Nikita session
  var {status} = await nikita.call('./lib/touch', {target: '/tmp/a_file'})
  assert.equal(status, true)
})()
