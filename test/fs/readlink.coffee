
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'fs.readlink', ->

  they 'get value', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_source"
    .fs.symlink
      target: "#{scratch}/a_target"
      source: "#{scratch}/a_source"
    .fs.readlink
      target: "#{scratch}/a_target"
    , (err, {target}) ->
      target.should.eql "#{scratch}/a_source"
    .promise()
