// hide-next-line
const nikita = require('nikita');
nikita
// Call an action with the `header` metadata
.execute({
  // highlight-range{1-3}
  metadata: {
    header: 'Check user'
  },
  command: 'whoami'
})
