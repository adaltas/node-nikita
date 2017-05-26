
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.compress', ->

  scratch = test.scratch @

  they 'should see extension .tgz', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.tgz"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.tgz"
    .then next

  they 'should see extension .zip', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.zip"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.zip"
    .then next

  they 'should see extension .tar.bz2', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.tar.bz2"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.tar.bz2"
    .then next

  they 'should see extension .tar.xz', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.tar.xz"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.tar.xz"
    .then next
  
  they 'remove source file with clean option', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'hellow'
    .tools.compress
      source: "#{scratch}/a_dir/a_file"
      target: "#{scratch}/a_dir.tar.xz"
      clean: true
    , (err, status) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir/a_file"
      not: true
    .then next
  
  they 'remove source directory with clean option', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'hellow'
    .tools.compress
      source: "#{scratch}/a_dir"
      target: "#{scratch}/a_dir.tar.xz"
      clean: true
    , (err, status) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir"
      not: true
    .then next

  they 'should pass error for invalid extension', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: __filename
      target: __filename
      relax: true
    , (err) ->
      err.message.should.eql 'Unsupported Extension: ".coffee"'
    .then next
