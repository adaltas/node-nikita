// hide-next-line
const nikita = require('nikita');
nikita.call({
  who: 'leon',
  handler: ({config}) => {
    console.info(config.who)
  }
})
