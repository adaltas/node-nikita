
pidfile_running = require "../src/misc/pidfile_running"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'pidfile_running', ->

  scratch = test.scratch @

  they 'give 0 if pidfile math a running process', (ssh, next) ->
    fs.writeFile ssh, "#{scratch}/pid", "#{process.pid}", (err) ->
      pidfile_running ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql true
        next()

  they 'give 1 if pidfile does not exists', (ssh, next) ->
    pidfile_running ssh, "#{scratch}/pid", (err, status) ->
      status.should.eql false
      next()

  they 'give 2 if pidfile exists but match no process', (ssh, next) ->
    fs.writeFile ssh, "#{scratch}/pid", "666666666", (err) ->
      pidfile_running ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql false
        next()