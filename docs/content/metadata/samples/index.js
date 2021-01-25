// hide-next-line
const nikita = require('nikita');
// Dependencies
const assert = require('assert');
// Call with metadata
nikita.call({
  // highlight-range{1-3}
  metadata: {
    header: 'my action'
  }
}, function({metadata}){
  assert.equal(metadata.header, 'my action')
})
