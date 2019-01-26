
nikita = require '@nikita/core'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'file.types.yum_repo', ->

  they 'generate from content', (ssh) ->
    nikita
      ssh: ssh
    .file.types.ceph_conf
      target: "#{scratch}/ceph_conf_test.repo"
      content:
        'global':
          'fsid': 'a7-a6-d0'
          'prop with spaces': '2spaces'
          'prop ip': '192.168.10.1'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/ceph_conf_test.repo"
      content: "[global]\nfsid = a7-a6-d0\nprop with spaces = 2spaces\nprop ip = 192.168.10.1\n"
    .promise()

  they 'status not modified', (ssh) ->
    nikita
      ssh: ssh
    .file.types.ceph_conf
      target: "#{scratch}/ceph_conf_test.repo"
      content:
        'global':
          'fsid': 'a7-a6-d0'
          'prop with spaces': '2spaces'
          'prop ip': '192.168.10.1'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.types.ceph_conf
      target: "#{scratch}/ceph_conf_test.repo"
      content:
        'global':
          'fsid': 'a7-a6-d0'
          'prop with spaces': '2spaces'
          'prop ip': '192.168.10.1'
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/ceph_conf_test.repo"
      content: "[global]\nfsid = a7-a6-d0\nprop with spaces = 2spaces\nprop ip = 192.168.10.1\n"
    .promise()
