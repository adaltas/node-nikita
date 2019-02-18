
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'system.running', ->
    
  they 'pid not running', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .system.running
      pid: 9999999
    , (err, {status}) ->
      status.should.be.false()
    .call ->
      logs.filter((log) -> /PID \d+ is not running/.test log).length.should.eql 1
    .promise()
        
  they 'pid running', ({ssh}) ->
    pid = null
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .system.execute
      cmd: """
      bash -c "while true ; do sleep 1; done" >/dev/null 2>&1 &
      echo $!
      """
    , (err, {stdout, stderr}) ->
      pid = stdout.trim().split(' ').pop() unless err
    .call ->
      @system.running
        pid: pid
      , (err, {status}) ->
        status.should.be.true()
      @system.execute
        cmd: "kill #{pid}"
        tolerant: true
    .call ->
      logs.filter((log) -> /PID \d+ is running/.test log).length.should.eql 1
    .promise()
        
  they 'pid file does not exists', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .system.running
      target: "#{scratch}/pid.lock"
    , (err, {status}) ->
      status.should.be.false()
    .call ->
      logs.filter((log) -> /PID file [^\s]+ does not exists/.test log).length.should.eql 1
    .promise()
        
  they 'pid file not running', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .file
      target: "#{scratch}/pid.lock"
      content: '9999999'
    .system.running
      target: "#{scratch}/pid.lock"
    , (err, {status}) ->
      status.should.be.false()
    .call ->
      logs.filter((log) -> /PID \d+ is not running/.test log).length.should.eql 1
    .promise()
        
  they 'pid file running', ({ssh}) ->
    pid = null
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .system.execute
      cmd: """
      bash -c "while true ; do sleep 1; done" >/dev/null 2>&1 &
      echo $! > #{scratch}/pid.lock
      """
    , (err, {stdout, stderr}) ->
      pid = stdout.trim().split(' ').pop() unless err
    .call ->
      @system.running
        target: "#{scratch}/pid.lock"
      , (err, {status}) ->
        status.should.be.true()
      @system.execute
        cmd: "kill `cat #{scratch}/pid.lock`"
        tolerant: true
    .call ->
      logs.filter((log) -> /PID \d+ is running/.test log).length.should.eql 1
    .promise()
