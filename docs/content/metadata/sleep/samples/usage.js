// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
nikita
.call({
  metadata: {
    retry: 3,
    sleep: 5000
  }
}, ({metadata}) => {
  // First 2 attempts fail with an assertion error,
  // the 3rd attempt succeeds in about 10 seconds
  assert.equal(metadata.attempt, 2)
})
