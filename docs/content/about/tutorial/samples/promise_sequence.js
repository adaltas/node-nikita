// hide-next-line
const nikita = require('nikita');
// Dependencies
const assert = require('assert');
(async () => {
  var history = []
  // Await result from Promise
  var result = await nikita
  // Call 1st action
  .call(() => {
    return new Promise((resolve) => {
      setTimeout(() => {
        history.push('first')
        resolve()
      }, 200)
    })
  })
  // Call 2nd action
  .call(() => {
    return new Promise((resolve) => {
      setTimeout(() => {
        history.push('second')
        resolve()
      }, 100)
    })
  })
  // Call 3rd action
  .call(() => {
    return 'done'
  })
  // Verify
  assert.equal(result, 'done')
  assert.deepEqual(history, ['first','second'])
})()
