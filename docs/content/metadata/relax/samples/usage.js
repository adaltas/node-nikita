// hide-next-line
const nikita = require('nikita');
nikita
.execute({
  metadata: {
    relax: true
  },
  command: 'systemctl start mariadb'
})
