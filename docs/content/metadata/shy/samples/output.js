// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
(async () => {
  // Status is set when shy is desactivated (default behavior)
  var {status} = await nikita
  .execute({
    metadata: {
      shy: false
    },
    command: 'exit 0'
  })
  assert.equal(status, true)
  // Status is set when shy is activated
  var {status} = await nikita
  .call({
    metadata: {
      shy: true
    },
    command: 'exit 0'
  })
  assert.equal(status, true)
})()
