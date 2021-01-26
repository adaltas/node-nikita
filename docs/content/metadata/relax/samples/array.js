// hide-next-line
const nikita = require('nikita');
nikita
.execute({
  metadata: {
    relax: ['NIKITA_EXECUTE_EXIT_CODE_INVALID', 'ANOTHER_CODE']
  },
  command: 'invalid command'
})
