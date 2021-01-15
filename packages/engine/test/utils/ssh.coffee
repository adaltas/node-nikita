
nikita = require '../../src'
utils = require '../../src/utils'
{tags, config} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('mocha-they')(config.filter ({ssh}) -> !!ssh)

describe 'utils.ssh', ->

  they 'compare two null', ({ssh}) ->
    utils.ssh.compare(null, null).should.be.true()
    utils.ssh.compare(null, false).should.be.true()

  they 'compare identical configs', ({ssh}) ->
    utils.ssh.compare(ssh, ssh).should.be.true()

  they 'compare identical connections', ({ssh}) ->
    {ssh: conn1} = await nikita.ssh.open ssh
    {ssh: conn2} = await nikita.ssh.open ssh
    utils.ssh.compare(conn1, conn2).should.be.true()
    nikita.ssh.close ssh: conn1
    nikita.ssh.close ssh: conn2

  they 'compare a connection with a config', ({ssh}) ->
    {ssh: conn} = await nikita.ssh.open ssh
    utils.ssh.compare(conn, ssh).should.be.true()
    nikita.ssh.close ssh: conn

  they 'compare a config with a connection', ({ssh}) ->
    {ssh: conn} = await nikita.ssh.open ssh
    utils.ssh.compare(ssh, conn).should.be.true()
    nikita.ssh.close ssh: conn
