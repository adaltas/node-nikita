
nikita = require '../../src'
pidfile_running = require '../../src/misc/pidfile_running'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'pidfile_running', ->

  they 'give 0 if pidfile math a running process', (ssh, next) ->
    nikita(ssh: ssh).fs.writeFile target: "#{scratch}/pid", content: "#{process.pid}", (err) ->
      pidfile_running ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql true
        next()

  they 'give 1 if pidfile does not exists', (ssh, next) ->
    pidfile_running ssh, "#{scratch}/pid", (err, status) ->
      status.should.eql false
      next()

  they 'give 2 if pidfile exists but match no process', (ssh, next) ->
    nikita(ssh: ssh).fs.writeFile target: "#{scratch}/pid", content: "666666666", (err) ->
      pidfile_running ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql false
        next()
