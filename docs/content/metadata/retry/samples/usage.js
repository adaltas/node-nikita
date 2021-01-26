// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
nikita
.call({
  metadata: {
    retry: 3
  }
}, ({metadata}) => {
  // First 2 attempts failed with an assertion error,
  // but the 3rd one succeeded
  assert.equal(metadata.attempt, 2)
})
