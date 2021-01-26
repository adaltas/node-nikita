// hide-next-line
const nikita = require('nikita');
(async () => {
  const {error} = await nikita
  .execute({
    metadata: {
      relax: true
    },
    command: 'invalid command'
  })
  console.log(error)
})()
