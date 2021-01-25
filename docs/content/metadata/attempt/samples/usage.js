// hide-next-line
const nikita = require('nikita');
// Dependencies
const assert = require('assert');
(async () => {
  var {attempt} = await nikita({
    metadata: {
      retry: 2
    }
  }, ({metadata}) => {
    if(metadata.attempt === 0){
      throw Error('Oups')
    }
    return {attempt: metadata.attempt}
  })
  // The first attempt failed with an error,
  // but the second attempt succeed
  assert.equal(attempt, 1)
})()
