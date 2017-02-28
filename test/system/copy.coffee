
path = require 'path'
mecano = require '../../src'
misc = require '../../src/misc'
glob = require '../../src/misc/glob'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

checkDir = (ssh, dir, callback) ->
  fs.readdir ssh, "#{__dirname}/../resources", (err, files) ->
    return callback err if err
    scratchFiles = []
    for f in files
      continue if f.substr(0, 1) is '.'
      scratchFiles.push f
    fs.readdir ssh, dir, (err, files) ->
      return callback err if err
      dirFiles = []
      for f in files
        continue if f.substr(0, 1) is '.'
        dirFiles.push f
      scratchFiles.sort().should.eql dirFiles.sort()
      callback()

describe 'system.copy', ->

  scratch = test.scratch @

  describe 'file', ->

    they 'with a filename inside a existing directory', (ssh, next) ->
      # @timeout 1000000
      source = "#{__dirname}/../resources/a_dir/a_file"
      target = "#{scratch}/a_new_file"
      mecano
        ssh: ssh
      .system.copy
        source: source
        target: target
      , (err, status) ->
        return next err if err
        status.should.be.true()
      .file.assert
        target: target
        md5: '3fb7c40c70b0ed19da713bd69ee12014'
      .system.copy
        ssh: ssh
        source: source
        target: target
      , (err, status) ->
        return next err if err
        status.should.be.false()
        next()

    they 'into a directory', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      mecano
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/existing_dir"
      .system.copy # Copy non existing file
        source: source
        target: "#{scratch}/existing_dir"
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/existing_dir/a_file"
      .then next

    they 'over an existing file', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      target = "#{scratch}/test_this_file"
      mecano
        ssh: ssh
      .file
        content: 'Hello you'
        target: target
      .system.copy
        source: source
        target: target
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: target
        md5: '3fb7c40c70b0ed19da713bd69ee12014'
      .system.copy
        source: source
        target: target
      , (err, status) ->
        status.should.be.false() unless err
      .then next

    they 'change permissions', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      target = "#{scratch}/test_this_file"
      mecano
        ssh: ssh
      .file
        content: 'Hello you'
        target: target
      .system.copy
        source: source
        target: target
        mode: 0o750
      , (err, status) ->
        return next err if err
        status.should.be.true() unless err
      .file.assert
        target: target
        mode: 0o0750
      .system.copy
        source: source
        target: target
        mode: 0o0755
      .file.assert
        target: target
        mode: 0o0755
      .then next

    they 'handle hidden files', (ssh, next) ->
      mecano
      .file
        ssh: ssh
        content: 'hello'
        target: "#{scratch}/.a_empty_file"
      .system.copy
        ssh: ssh
        source: "#{scratch}/.a_empty_file"
        target: "#{scratch}/.a_copy"
      .file.assert
        target: "#{scratch}/.a_copy"
        content: 'hello'
      .then next
          
  describe 'link', ->

    they 'file into file', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'hello'
        target: "#{scratch}/org_file"
      .system.link
        source: "#{scratch}/org_file"
        target: "#{scratch}/ln_file"
      .system.copy
        source: "#{scratch}/ln_file"
        target: "#{scratch}/dst_file"
      .file.assert
        target: "#{scratch}/dst_file"
        content: 'hello'
      .then next

    they 'file parent dir', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'hello'
        target: "#{scratch}/source/org_file"
      , (err) ->
        return next err if err
      .system.link
        source: "#{scratch}/source/org_file"
        target: "#{scratch}/source/ln_file"
      , (err) ->
        return next err if err
      .system.copy
        source: "#{scratch}/source/ln_file"
        target: "#{scratch}"
      .file.assert
        target: "#{scratch}/ln_file"
        content: 'hello'
      .then next
          
  describe 'directory', ->

    they 'should copy without slash at the end', (ssh, next) ->
      mecano
        ssh: ssh
      # if the target doesn't exists, then copy as target
      .system.copy
        source: "#{__dirname}/../resources"
        target: "#{scratch}/toto"
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        checkDir ssh, "#{scratch}/toto", (err) ->
          callback err
      # if the target exists, then copy the folder inside target
      .system.copy
        source: "#{__dirname}/../resources"
        target: "#{scratch}/toto"
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        checkDir ssh, "#{scratch}/toto/resources", (err) ->
          callback err
      .then next

    they 'should copy the files when dir end with slash', (ssh, next) ->
      mecano
        ssh: ssh
      # if the target doesn't exists, then copy as target
      .system.copy
        source: "#{__dirname}/../resources/"
        target: "#{scratch}/lulu"
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        checkDir ssh, "#{scratch}/lulu", (err) ->
          callback err
      # if the target exists, then copy the files inside target
      .system.copy
        source: "#{__dirname}/../resources/"
        target: "#{scratch}/lulu"
      , (err, status) ->
        status.should.be.false() unless err
      .call (_, callback) ->
        checkDir ssh, "#{scratch}/lulu", (err) ->
          callback err
      .then next

    they 'should copy hidden files', (ssh, next) ->
      mecano
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/a_dir"
      .file.touch
        target: "#{scratch}/a_dir/a_file"
      .file.touch
        target: "#{scratch}/a_dir/.a_hidden_file"
      .system.copy
        source: "#{scratch}/a_dir"
        target: "#{scratch}/a_copy"
      .call (_, callback) ->
        glob ssh, "#{scratch}/a_copy/**", dot: true, (err, files) ->
          return callback err if err
          files.sort().should.eql [
            '/tmp/mecano-test/a_copy',
            '/tmp/mecano-test/a_copy/.a_hidden_file',
            '/tmp/mecano-test/a_copy/a_file'
          ]
          callback()
      .then next

    they.skip 'should copy with globing and hidden files', (ssh, next) ->
      mecano
        ssh: ssh
      # if the target doesn't exists, then copy as target
      .system.copy
        source: "#{__dirname}/../*"
        target: "#{scratch}"
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        glob ssh, "#{scratch}/**", dot: true, (err, files) ->
          callback err
      .then next
