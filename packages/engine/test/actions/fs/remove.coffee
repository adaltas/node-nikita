
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.remove', ->
  
  they 'accept an option', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.remove
        source: "#{tmpdir}/a_file"
      .should.be.resolvedWith status: true

  they 'accept a string', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.remove "#{tmpdir}/a_file"
      .should.be.resolvedWith status: true

  they 'accept an array of strings', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/file_1"
        content: ''
      @fs.base.writeFile
        target: "#{tmpdir}/file_2"
        content: ''
      @fs.remove [
        "#{tmpdir}/file_1"
        "#{tmpdir}/file_2"
      ]
      .should.be.resolvedWith [{status: true}, {status: true}]

  they 'a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.remove
        source: "#{tmpdir}/a_file"
      .should.be.resolvedWith status: true
      @fs.remove
        source: "#{tmpdir}/a_file"
      .should.be.resolvedWith status: false

  they 'a link', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.base.symlink source: "#{tmpdir}/a_file", target: "#{tmpdir}/a_link"
      @fs.remove
        source: "#{tmpdir}/a_link"
      .should.be.resolvedWith status: true
      @fs.assert
        target: "#{tmpdir}/a_link"
        not: true

  they 'use a pattern', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
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
      .should.be.resolvedWith status: true
      @fs.assert "#{tmpdir}/a_dir.tar.gz", not: true
      @fs.assert "#{tmpdir}/a_dir.tgz", not: true
      @fs.assert "#{tmpdir}/a_dir.zip"
      @fs.assert "#{tmpdir}/a_dir", type: 'directory'

  they 'a dir', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir
        target: "#{tmpdir}/remove_dir"
      @fs.remove
        target: "#{tmpdir}/remove_dir"
      .should.be.resolvedWith status: true
      @fs.remove
        target: "#{tmpdir}/remove_dir"
      .should.be.resolvedWith status: false
