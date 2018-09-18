
connect = require 'ssh2-connect'
misc = require '../../src/misc'
{tags, ssh} = require '../test'

return unless tags.api

describe 'misc ssh', ->

    it 'compare two null', ->
      misc.ssh.compare(null, null).should.be.true()
      misc.ssh.compare(null, false).should.be.true()

    it 'compare identical instances', (next) ->
      connect ssh, (err, conn) ->
        return next err if err
        try misc.ssh.compare(conn, conn).should.be.true()
        finally conn.end()
        next()

    it 'compare an instance with a config', (next) ->
      connect ssh, (err, conn) ->
        return next err if err
        try misc.ssh.compare(conn, ssh).should.be.true()
        finally conn?.end()
        next err

    it 'compare a config with an instance', (next) ->
      connect ssh, (err, conn) ->
        return next err if err
        try misc.ssh.compare(ssh, conn).should.be.true()
        finally conn?.end()
        next err
