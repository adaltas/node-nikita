const nikita = require('nikita');
// Call anonymous asynchronous function
(async () => {
  // Await result from Promise
  var result = await nikita.call({
    who: 'leon',
    handler: ({config}) => {
      return {who: config.who}
    }
  })
  // Sequentially run the next command
  console.log(result.who)
})()
