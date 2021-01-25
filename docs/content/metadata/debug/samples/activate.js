// hide-next-line
const nikita = require('nikita');
nikita
.file.touch({
  target: '/tmp/a_file',
  metadata: {
    debug: true
  }
})
