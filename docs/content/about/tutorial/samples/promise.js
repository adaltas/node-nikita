// hide-next-line
const nikita = require('nikita');
// Call asynchronous function
(async () => {
  // Await result from Promise
  var result = await nikita.call({
    who: 'leon',
    handler: ({config}) => {
      return {who: config.who}
    }
  })
  // Run the next function
  console.log(result.who)
})()
