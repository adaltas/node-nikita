
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.backup', ->
  return unless test.tags.posix

  describe 'file', ->

    they 'backup to a directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: 'Hello'
          target: "#{tmpdir}/a_file"
        {$status, filename} = await @tools.backup
          name: 'my_backup'
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/backup"
        $status.should.be.true()
        await @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          filetype: 'file'
        await @wait 1000
        {$status, filename} = await @tools.backup
          name: 'my_backup'
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/backup"
        $status.should.be.true()
        await @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          filetype: 'file'

    they 'compress', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file
          content: 'Hello'
          target: "#{tmpdir}/a_file"
        {$status, base_dir, name, filename, target} = await @tools.backup
          name: 'my_backup'
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/backup"
          compress: true
        $status.should.be.true()
        base_dir.should.eql "#{tmpdir}/backup"
        name.should.eql 'my_backup'
        filename.should.match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z\.tgz/
        target.should.eql "#{base_dir}/my_backup/#{filename}"
        await @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          filetype: 'file'

  describe 'command', ->

    they 'pipe to a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status, filename} = await @tools.backup
          name: 'my_backup'
          command: "echo hello"
          target: "#{tmpdir}/backup"
        $status.should.be.true()
        await @fs.assert
          target: "#{tmpdir}/backup/my_backup/#{filename}"
          content: "hello\n"
