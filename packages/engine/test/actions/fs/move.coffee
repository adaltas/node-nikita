
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.move', ->

  they 'error missing target', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.move
        source: "#{tmpdir}/a_file"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `fs.move`:'
        '#/required config should have required property \'target\'.'
      ].join ' '

  they 'error missing source', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.move
        target: "#{tmpdir}/a_file"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `fs.move`:'
        '#/required config should have required property \'source\'.'
      ].join ' '

  they 'rename a file', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/org_file"
        content: ''
      @fs.move
        target: "#{tmpdir}/new_name"
        source: "#{tmpdir}/org_file"
      .should.be.finally.containEql status: true
      # The target file should exists
      @fs.assert
        target: "#{tmpdir}/new_name"
      # The source file should no longer exists
      @fs.assert
        target: "#{tmpdir}/org_file"
        not: true

  they 'rename a directory', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.mkdir "#{tmpdir}/a_dir"
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir/a_file"
        content: ''
      @fs.move
        source: "#{tmpdir}/a_dir"
        target: "#{tmpdir}/moved"
      .should.be.finally.containEql status: true
      # The target file should exists
      @fs.assert
        target: "#{tmpdir}/moved"
        filetype: 'directory'
      # The source file should no longer exists
      @fs.assert
        target: "#{tmpdir}/a_dir"
        not: true

  they 'overwrite a file', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/src1.txt"
        content: 'hello'
      @fs.base.writeFile
        target: "#{tmpdir}/src2.txt"
        content: 'hello'
      @fs.base.writeFile
        target: "#{tmpdir}/dest.txt"
        content: 'overwritten'
      @fs.move
        source: "#{tmpdir}/src1.txt"
        target: "#{tmpdir}/dest.txt"
      .should.be.finally.containEql status: true
      @fs.move # Move a file with the same content
        source: "#{tmpdir}/src2.txt"
        target: "#{tmpdir}/dest.txt"
      .should.be.finally.containEql status: false
      @fs.assert
        target: "#{tmpdir}/dest.txt"
        content: 'hello'
      @fs.assert
        target: "#{tmpdir}/src2.txt"
        not: true

  they 'force bypass checksum comparison', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/src.txt"
        content: 'hello'
      @fs.base.writeFile
        target: "#{tmpdir}/dest.txt"
        content: 'hello'
      @fs.move
        source: "#{tmpdir}/src.txt"
        target: "#{tmpdir}/dest.txt"
        force: 1
      .should.be.finally.containEql status: true
