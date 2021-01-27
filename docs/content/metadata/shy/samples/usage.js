// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
(async () => {
  var {status} = await nikita
  .call(async function() {
    var {status} = await this.execute({
      metadata: {
        shy: true
      },
      command: 'exit 0'
    })
    // Status of the child
    assert.equal(status, true)
  })
  // Status of the parent is not affected by the child
  assert.equal(status, false)
})()
