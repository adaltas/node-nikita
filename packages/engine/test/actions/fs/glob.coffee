
path = require 'path'
{Minimatch} = require 'minimatch'
nikita = require '../../../src'
{tags, ssh, scratch} = require '../../test'
they = require('ssh2-they').configure ssh

describe 'actions.fs.glob', ->
  return unless tags.posix

  they 'should traverse a directory', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile "#{tmpdir}/test/a_file", content: ''
      @fs.base.mkdir "#{tmpdir}/test/a_dir"
      @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/*"
      files.should.eql [
        path.normalize "#{tmpdir}/test/a_file"
        path.normalize "#{tmpdir}/test/a_dir"
      ]

  they 'should traverse a directory recursively', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile "#{tmpdir}/test/a_file", content: ''
      @fs.base.mkdir "#{tmpdir}/test/a_dir"
      @fs.base.mkdir "#{tmpdir}/test/a_dir/a_sub_dir"
      @fs.base.writeFile "#{tmpdir}/test/a_dir/a_sub_dir/a_file", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**"
      files.should.eql [
        "#{tmpdir}/test"
        "#{tmpdir}/test/a_file"
        "#{tmpdir}/test/a_dir"
        "#{tmpdir}/test/a_dir/a_sub_dir"
        "#{tmpdir}/test/a_dir/a_sub_dir/a_file"
      ]
      # Default behavior
      (new Minimatch('/a_dir/**').match '/a_dir/').should.be.true()

  they 'should match an extension patern', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile "#{tmpdir}/test/a_file.coffee", content: ''
      @fs.base.mkdir "#{tmpdir}/test/a_dir"
      @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file.coffee", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/*.coffee"
      files.should.eql [
        path.normalize "#{tmpdir}/test/a_file.coffee"
      ]

  they 'should match an extension patern in recursion', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
      dirty: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile "#{tmpdir}/test/a_file.coffee", content: ''
      @fs.base.mkdir "#{tmpdir}/test/a_dir"
      @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file.coffee", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**/*.coffee"
      files.should.eql [
        path.normalize "#{tmpdir}/test/a_dir/a_file.coffee"
        path.normalize "#{tmpdir}/test/a_file.coffee"
      ]
  
  they 'return an empty array on no match', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {files} = await @fs.glob "#{tmpdir}/invalid/*.coffee"
      files.should.eql []
  
  they 'config `dot`', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile "#{tmpdir}/test/.git", content: ''
      @fs.base.mkdir "#{tmpdir}/test/a_dir"
      @fs.base.writeFile "#{tmpdir}/test/a_dir/.gitignore", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**", dot: true
      files.should.eql [
        "#{tmpdir}/test"
        "#{tmpdir}/test/.git"
        "#{tmpdir}/test/a_dir"
        "#{tmpdir}/test/a_dir/.gitignore"
      ]
  
  they 'config `trailing`', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile "#{tmpdir}/test/a_file", content: ''
      @fs.base.mkdir "#{tmpdir}/test/a_dir"
      @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**", trailing: true
      files.should.eql [
        "#{tmpdir}/test/"
        "#{tmpdir}/test/a_file"
        "#{tmpdir}/test/a_dir/"
        "#{tmpdir}/test/a_dir/a_file"
      ]
