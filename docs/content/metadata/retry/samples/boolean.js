// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
nikita
.call({
  metadata: {
    retry: true
  }
}, function ({metadata}) {
  // First 9 attempts failed with an assertion error,
  // but 10th attempt succeeded
  assert.equal(metadata.attempt, 9)
})
