
module.exports =
  tags:
    tools_dconf: true
  ssh: [{
    env: DBUS_SESSION_BUS_ADDRESS:'unix:path=/tmp/dbus.sock'
  },{
    ssh: host: 'localhost', username: 'root'
    env: DBUS_SESSION_BUS_ADDRESS:'unix:path=/tmp/dbus.sock'
  }]
