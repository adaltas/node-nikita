
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.remove', ->
  
  they 'accept an option', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.remove
        source: "#{tmpdir}/a_file"
      .should.be.finally.containEql status: true

  they 'accept a string', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      {status} = await @fs.remove "#{tmpdir}/a_file"
      status.should.be.true()

  they 'accept an array of strings', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/file_1"
        content: ''
      @fs.base.writeFile
        target: "#{tmpdir}/file_2"
        content: ''
      (await @fs.remove [
        "#{tmpdir}/file_1"
        "#{tmpdir}/file_2"
      ])
      .map ({status}) -> status
      .should.eql [true, true]

  they 'a file', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.remove
        source: "#{tmpdir}/a_file"
      .should.be.finally.containEql status: true
      @fs.remove
        source: "#{tmpdir}/a_file"
      .should.be.finally.containEql status: false

  they 'a link', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.base.symlink source: "#{tmpdir}/a_file", target: "#{tmpdir}/a_link"
      @fs.remove
        source: "#{tmpdir}/a_link"
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/a_link"
        not: true

  they 'use a pattern', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir
        target: "#{tmpdir}/a_dir"
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir/a_file"
        content: ''
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir.tar.gz"
        content: ''
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir.tz"
        content: ''
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir.zip"
        content: ''
      @fs.remove
        source: "#{tmpdir}/*gz"
      .should.be.finally.containEql status: true
      @fs.assert "#{tmpdir}/a_dir.tar.gz", not: true
      @fs.assert "#{tmpdir}/a_dir.tgz", not: true
      @fs.assert "#{tmpdir}/a_dir.zip"
      @fs.assert "#{tmpdir}/a_dir", type: 'directory'

  they 'a dir', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir
        target: "#{tmpdir}/remove_dir"
      @fs.remove
        target: "#{tmpdir}/remove_dir"
      .should.be.finally.containEql status: true
      @fs.remove
        target: "#{tmpdir}/remove_dir"
      .should.be.finally.containEql status: false
