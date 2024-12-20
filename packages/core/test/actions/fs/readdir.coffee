
import fs from 'node:fs/promises'
import {Dirent} from  'node:fs'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.readdir', ->
  return unless test.tags.posix

  it 'get native behavior', ->
    nikita
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await fs.mkdir "#{tmpdir}/parent"
      await fs.mkdir "#{tmpdir}/parent/a_dir"
      await fs.writeFile "#{tmpdir}/parent/file_1", ''
      await fs.writeFile "#{tmpdir}/parent/file_2", ''
      # No options
      files = await fs.readdir "#{tmpdir}/parent"
      files.should.eql ['a_dir', 'file_1', 'file_2']
      # Option `withFileTypes`
      files = await fs.readdir "#{tmpdir}/parent", withFileTypes: true
      # console.log files.sort().map (file) -> JSON.parse JSON.stringify file
      files
      .sort()
      .map (file) -> JSON.parse JSON.stringify file # Convert Dirent to object literal
      .should.match [
        { name: 'a_dir', parentPath: "#{tmpdir}/parent" }
        { name: 'file_1', parentPath: "#{tmpdir}/parent" }
        { name: 'file_2', parentPath: "#{tmpdir}/parent" }
      ].map (match) =>
        # Node.js 20 introduce a `path` property with the parent dir
        # Node.js 23 remove path in favor of parentPath
        if parseInt(process.versions.node.split('.')[0], 10) < 20 then name: match.name else match
      files[0].isDirectory().should.be.true()
      files[1].isFile().should.be.true()

  they 'target option as argument', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent"
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent/a_dir"
      await @fs.writeFile "{{parent.metadata.tmpdir}}/parent/file_1", content: 'hello'
      await @fs.writeFile "{{parent.metadata.tmpdir}}/parent/file_2", content: 'hello'
      @fs.readdir "{{parent.metadata.tmpdir}}/parent"
      .then ({files}) ->
        files.sort().should.eql ['a_dir', 'file_1', 'file_2']

  they 'target does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.readdir "{{parent.metadata.tmpdir}}/missing"
      .should.be.rejectedWith
        code: 'NIKITA_FS_READDIR_TARGET_ENOENT'
        message: /NIKITA_FS_READDIR_TARGET_ENOENT: fail to read a directory, target is not a directory, got ".*\/missing"/

  they 'handle missing file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent"
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent/a_dir"
      await @fs.writeFile "{{parent.metadata.tmpdir}}/parent/file_1", content: 'hello'
      await @fs.writeFile "{{parent.metadata.tmpdir}}/parent/file_2", content: 'hello'
      @fs.readdir "{{parent.metadata.tmpdir}}/parent", withFileTypes: true
      .then ({files}) ->
        files = files.sort()
        files.map (file) -> JSON.parse JSON.stringify file # Convert Dirent to object literal
        .should.eql [
          { name: 'a_dir' }
          { name: 'file_1' }
          { name: 'file_2' }
        ]
        files[0].isDirectory().should.be.true()
        files[1].isFile().should.be.true()
