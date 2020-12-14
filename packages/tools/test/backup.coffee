
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'tools.backup', ->

  describe 'file', ->

    they 'backup to a directory', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {status, filename} = await @tools.backup
          name: 'my_backup'
          source: "#{__filename}"
          target: "#{tmpdir}/backup"
        status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          filetype: 'file'
        @wait 1000
        {status, filename} = await @tools.backup
          name: 'my_backup'
          source: "#{__filename}"
          target: "#{tmpdir}/backup"
        status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          filetype: 'file'

    they 'compress', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {status, base_dir, name, filename, target} = await @tools.backup
          name: 'my_backup'
          source: "#{__filename}"
          target: "#{tmpdir}/backup"
          compress: true
        status.should.be.true()
        base_dir.should.eql "#{tmpdir}/backup"
        name.should.eql 'my_backup'
        filename.should.match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z\.tgz/
        target.should.eql "#{base_dir}/my_backup/#{filename}"
        @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          filetype: 'file'

  describe 'command', ->

    they 'pipe to a file', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {status, filename} = await @tools.backup
          name: 'my_backup'
          command: "echo hello"
          target: "#{tmpdir}/backup"
        status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          content: "hello\n"
