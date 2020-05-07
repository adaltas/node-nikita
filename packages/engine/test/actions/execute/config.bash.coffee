
nikita = require '../../../src'
{tags, ssh, scratch} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.execute.config.bash', ->

  they 'in generated path', ({ssh}) ->
    nikita
      ssh: ssh
    .execute
      cmd: "echo $BASH"
      bash: true
    .then ({stdout}) ->
      stdout.should.containEql 'bash'

  they.skip 'in user path', ({ssh}) ->
    nikita
      ssh: ssh
    .execute
      cmd: "echo $BASH"
      bash: true
      dirty: true
      target: "#{scratch}/my_script"
    , (err, {stdout}) ->
      stdout.should.containEql 'bash'
    .file.assert
      target: "#{scratch}/my_script"
    .execute
      cmd: "echo $BASH"
      bash: true
      dirty: false
      target: "#{scratch}/my_script"
    , (err, {stdout}) ->
      stdout.should.containEql 'bash'
    .file.assert
      target: "#{scratch}/my_script"
      not: true
    .promise()

  they.skip 'honors exit code', ({ssh}) ->
    nikita
      ssh: ssh
    .execute
      cmd: "exit 2"
      bash: true
      code_skipped: 2
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
