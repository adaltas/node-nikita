// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
nikita({
  metadata: {
    sleep: 5000
  }
})
// Use the global sleep value of 5s
.call({
  metadata: {
    retry: 3,
  }
}, ({metadata}) => {
  assert.equal(metadata.attempt, 2)
})
// Overwrite the global value of 5s and use 1s
.call({
  metadata: {
    retry: 3,
    sleep: 1000
  }
}, ({metadata}) => {
  assert.equal(metadata.attempt, 2)
})
