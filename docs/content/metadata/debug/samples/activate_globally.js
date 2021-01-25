// hide-next-line
const nikita = require('nikita');
nikita
({
  metadata: {
    debug: true
  }
})
.file.touch({
  target: '/tmp/a_file'
})
