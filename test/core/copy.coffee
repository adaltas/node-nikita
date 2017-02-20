
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

describe 'copy', ->

  scratch = test.scratch @

  describe 'file', ->

    they 'with a filename inside a existing directory', (ssh, next) ->
      # @timeout 1000000
      source = "#{__dirname}/../resources/a_dir/a_file"
      target = "#{scratch}/a_new_file"
      mecano
        ssh: ssh
      .copy
        source: source
        target: target
      , (err, status) ->
        return next err if err
        status.should.be.true()
      .call (options, next) ->
        misc.file.compare @options.ssh, [source, target], (err, md5) ->
          return next err if err
          md5.should.eql '3fb7c40c70b0ed19da713bd69ee12014'
          next()
      .copy
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
      .copy # Copy non existing file
        source: source
        target: "#{scratch}/existing_dir"
      , (err, status) ->
        status.should.be.true() unless err
      .call (options, callback) ->
        fs.exists @options.ssh, "#{scratch}/existing_dir/a_file", (err, exists) ->
          exists.should.be.true()
          callback()
      .then next

    they 'over an existing file', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      target = "#{scratch}/test_this_file"
      mecano
      .file
        ssh: ssh
        content: 'Hello you'
        target: target
      .copy
        ssh: ssh
        source: source
        target: target
      , (err, copied) ->
        return next err if err
        copied.should.be.true()
        misc.file.compare ssh, [source, target], (err, md5) ->
          return next err if err
          md5.should.eql '3fb7c40c70b0ed19da713bd69ee12014'
          mecano.copy
            ssh: ssh
            source: source
            target: target
          , (err, copied) ->
            return next err if err
            copied.should.be.false()
            next()

    they 'change permissions', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      target = "#{scratch}/test_this_file"
      mecano.file
        ssh: ssh
        content: 'Hello you'
        target: target
      .copy
        ssh: ssh
        source: source
        target: target
        mode: 0o750
      , (err, copied) ->
        return next err if err
        copied.should.be.true()
        fs.stat ssh, target, (err, stat) ->
          misc.mode.compare(stat.mode, 0o750).should.be.true()
          # Copy existing file
          mecano.copy
            ssh: ssh
            source: source
            target: target
            mode: 0o755
          , (err, copied) ->
            return next err if err
            fs.stat ssh, target, (err, stat) ->
              misc.mode.compare(stat.mode, 0o755).should.be.true()
              next()

    they 'handle hidden files', (ssh, next) ->
      mecano
      .file
        ssh: ssh
        content: 'hello'
        target: "#{scratch}/.a_empty_file"
      .copy
        ssh: ssh
        source: "#{scratch}/.a_empty_file"
        target: "#{scratch}/.a_copy"
      , (err, copied) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/.a_copy", 'ascii', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()
          
  describe 'link', ->

    they 'file into file', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'hello'
        target: "#{scratch}/org_file"
      .link
        source: "#{scratch}/org_file"
        target: "#{scratch}/ln_file"
      .copy
        source: "#{scratch}/ln_file"
        target: "#{scratch}/dst_file"
      , (err, copied) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/dst_file", 'ascii', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()

    they 'file parent dir', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'hello'
        target: "#{scratch}/source/org_file"
      , (err) ->
        return next err if err
      .link
        source: "#{scratch}/source/org_file"
        target: "#{scratch}/source/ln_file"
      , (err) ->
        return next err if err
      .copy
        source: "#{scratch}/source/ln_file"
        target: "#{scratch}"
      , (err, copied) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/ln_file", 'ascii', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()
          
  describe 'directory', ->

    they 'should copy without slash at the end', (ssh, next) ->
      # if the target doesn't exists, then copy as target
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../resources"
        target: "#{scratch}/toto"
      , (err, copied) ->
        return next err if err
        copied.should.be.true()
        checkDir ssh, "#{scratch}/toto", (err) ->
          return next err if err
          # if the target exists, then copy the folder inside target
          mecano.copy
            ssh: ssh
            source: "#{__dirname}/../resources"
            target: "#{scratch}/toto"
          , (err, copied) ->
            return next err if err
            copied.should.be.true()
            checkDir ssh, "#{scratch}/toto/resources", (err) ->
              next err

    they 'should copy the files when dir end with slash', (ssh, next) ->
      # if the target doesn't exists, then copy as target
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../resources/"
        target: "#{scratch}/lulu"
      , (err, copied) ->
        return next err if err
        copied.should.be.true()
        checkDir ssh, "#{scratch}/lulu", (err) ->
          return next err if err
          # if the target exists, then copy the files inside target
          mecano.copy
            ssh: ssh
            source: "#{__dirname}/../resources/"
            target: "#{scratch}/lulu"
          , (err, copied) ->
            return next err if err
            copied.should.be.false()
            checkDir ssh, "#{scratch}/lulu", (err) ->
              next err

    they 'should copy hidden files', (ssh, next) ->
      mecano
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/a_dir"
      .touch
        target: "#{scratch}/a_dir/a_file"
      .touch
        target: "#{scratch}/a_dir/.a_hidden_file"
      .copy
        source: "#{scratch}/a_dir"
        target: "#{scratch}/a_copy"
      , (err, copied) ->
        return next err if err
        glob ssh, "#{scratch}/a_copy/**", dot: true, (err, files) ->
          return next err if err
          files.sort().should.eql [
            '/tmp/mecano-test/a_copy',
            '/tmp/mecano-test/a_copy/.a_hidden_file',
            '/tmp/mecano-test/a_copy/a_file'
          ]
          next()


    they.skip 'should copy with globing and hidden files', (ssh, next) ->
      # if the target doesn't exists, then copy as target
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../*"
        target: "#{scratch}"
      , (err, copied) ->
        return next err if err
        copied.should.be.true()
        glob ssh, "#{scratch}/**", dot: true, (err, files) ->
          return next err if err
          next()
