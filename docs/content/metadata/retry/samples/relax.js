// hide-next-line
const nikita = require('nikita');
const assert = require('assert');
(async () => {
  var {status} = await nikita
  .call({
    metadata: {
      retry: 2,
      relax: true
    }
  }, ({metadata}) => {
    // Will fail 2 times
    throw Error('Oups')
  })
  // Will be executed because last action was not fatal
  assert.equal(status, false)
})()
