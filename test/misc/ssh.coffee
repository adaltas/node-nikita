
ssh = require '../../src/misc/ssh'
connect = require 'ssh2-connect'
test = require '../test'

describe 'misc ssh', ->

    it 'compare two null', ->
      ssh.compare(null, null).should.be.true()
      ssh.compare(null, false).should.be.true()

    it 'compare identical instances', (next) ->
      config = test.config().ssh
      connect config, (err, conn) ->
        return next err if err
        try ssh.compare(conn, conn).should.be.true()
        finally conn.end()
        next()

    it 'compare an instance with a config', (next) ->
      config = test.config().ssh
      connect config, (err, conn) ->
        return next err if err
        try ssh.compare(conn, config).should.be.true()
        finally conn?.end()
        next err

    it 'compare a config with an instance', (next) ->
      config = test.config().ssh
      connect config, (err, conn) ->
        return next err if err
        try ssh.compare(config, conn).should.be.true()
        finally conn?.end()
        next err
