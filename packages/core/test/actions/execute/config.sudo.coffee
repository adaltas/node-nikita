
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.sudo', ->
  return unless tags.sudo

  they 'execute.assert', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @execute.assert
        command: 'whoami'
        content: 'root'
        $sudo: true
        trim: true

  they 'execute with bash', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @execute.assert
        bash: true
        command: 'whoami'
        content: 'root'
        $sudo: true
        trim: true

  they 'bash dispose tmp script', ({ssh}) ->
    # Tmpdir is voluntarily not destroyed with `dirty: true`
    # to ensure that the bash temporary script is correctly diposed
    tmpdir = await nikita
      $ssh: ssh
      $tmpdir: true
      $dirty: true
      $sudo: true
    , ({metadata: {tmpdir}}) ->
      @execute
        bash: true
        command: 'whoami'
        trim: true
      tmpdir
    {files} = await nikita.fs.base.readdir
      $ssh: ssh
      $sudo: true
      target: tmpdir
    files.length.should.eql 0
    nikita.fs.remove
      $ssh: ssh
      $sudo: true
      target: tmpdir
