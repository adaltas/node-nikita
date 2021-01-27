// hide-next-line
const nikita = require('nikita');
nikita.call({
  who: 'leon'
}, ({config}) => {
    console.info(config.who)
  }
)
