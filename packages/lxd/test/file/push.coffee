
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxd

describe 'lxd.file.push', ->

  they 'a new file', (ssh) ->
    nikita
      ssh: ssh
    .lxd.delete
      name: 'c1'
    .lxd.init
      image: 'ubuntu:18.04'
      name: 'c1'
    .file
      target: "#{scratch}/a_file"
      content: 'something'
    .lxd.file.push
      name: 'c1'
      source: "#{scratch}/a_file"
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.true()
    .lxd.file.exists
      name: 'c1'
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'the same file', (ssh) ->
    nikita
      ssh: ssh
    .lxd.delete
      name: 'c1'
    .lxd.init
      image: 'ubuntu:18.04'
      name: 'c1'
    .file
      target: "#{scratch}/a_file"
      content: 'something'
    .lxd.file.push
      name: 'c1'
      source: "#{scratch}/a_file"
      target: '/root/a_file'
    .lxd.file.push
      name: 'c1'
      source: "#{scratch}/a_file"
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
