const nikita = require('nikita');
// Dependencies
nikita.call(
  // Anonymous asynchronous function
  async ({context}) => {
    // Await result from Promise
    var result = await context.call({
      who: 'leon',
      handler: ({config, context}) => {
        return {who: config.who}
      }
    })
    // Sequentially run the next command
    console.log(result.who)
  }
)
