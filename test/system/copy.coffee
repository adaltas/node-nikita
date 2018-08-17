
nikita = require '../../src'
glob = require '../../src/misc/glob'
test = require '../test'
they = require 'ssh2-they'

describe 'system.copy', ->

  scratch = test.scratch @
  
  describe 'options parent', ->
    
    they 'create parent directory', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_new_file"
        content: 'hello'
      .system.copy
        source: "#{scratch}/a_new_file"
        target: "#{scratch}/a_dir/a_new_file"
      .file.assert
        target: "#{scratch}/a_dir/a_new_file"
        content: 'hello'
      .promise()
  
    they 'throw error if false', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_new_file"
        content: 'hello'
      .system.copy
        source: "#{scratch}/a_new_file"
        target: "#{scratch}/a_dir/a_new_file"
        parent: false
      .promise()
      .should.be.rejectedWith 'Invalid Target: no such file or directory, open "/tmp/nikita-test/a_dir/a_new_file"'
        
    they 'pass mode attribute', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_new_file"
        content: 'hello'
      .system.copy
        source: "#{scratch}/a_new_file"
        target: "#{scratch}/a_dir/a_new_file"
        parent: mode: 0o0700
        mode: 0o0604
      .file.assert
        target: "#{scratch}/a_dir"
        mode: 0o0700
      .file.assert
        target: "#{scratch}/a_dir/a_new_file"
        mode: 0o0604
      .promise()

  describe 'file', ->

    they 'with a filename inside a existing directory', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'a content'
      .system.copy
        source: "#{scratch}/a_file"
        target: "#{scratch}/a_target"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_target"
        md5: '3fb7c40c70b0ed19da713bd69ee12014'
      .system.copy
        source: "#{scratch}/a_file"
        target: "#{scratch}/a_target"
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'into a directory', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'a content'
      .system.mkdir
        target: "#{scratch}/existing_dir"
      .system.copy # Copy non existing file
        target: "#{scratch}/existing_dir"
        source: "#{scratch}/a_file"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/existing_dir/a_file"
      .promise()

    they 'over an existing file', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'a content'
      .file
        target: "#{scratch}/a_target_file"
        content: 'Hello you'
      .system.copy
        target: "#{scratch}/a_target_file"
        source: "#{scratch}/a_file"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_target_file"
        md5: '3fb7c40c70b0ed19da713bd69ee12014'
      .system.copy
        target: "#{scratch}/a_target_file"
        source: "#{scratch}/a_file"
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'change permissions', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/source_file"
        content: 'hello you'
        mode: 0o0644
      .file
        target: "#{scratch}/target_file"
        content: 'Hello you'
        mode: 0o0644
      .system.copy
        target: "#{scratch}/target_file"
        source: "#{scratch}/source_file"
        mode: 0o0750
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/target_file"
        mode: 0o0750
      .system.copy
        target: "#{scratch}/target_file"
        source: "#{scratch}/source_file"
        mode: 0o0755
      .file.assert
        target: "#{scratch}/target_file"
        mode: 0o0755
      .promise()

    they 'handle hidden files', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/.a_empty_file"
        content: 'hello'
      .system.copy
        target: "#{scratch}/.a_copy"
        source: "#{scratch}/.a_empty_file"
      .file.assert
        target: "#{scratch}/.a_copy"
        content: 'hello'
      .promise()
    
    they 'set permissions', (ssh) ->
      nikita
      .file.touch
        target: "#{scratch}/a_source_file"
        mode: 0o0606
      .system.copy
        target: "#{scratch}/a_target_file"
        source: "#{scratch}/a_source_file"
        mode: 0o0644
      .file.assert
        target: "#{scratch}/a_target_file"
        mode: 0o0644
      .promise()
    
    they 'preserve permissions', (ssh) ->
      nikita
      .file.touch
        target: "#{scratch}/a_source_file"
        mode: 0o0606
      .system.copy
        target: "#{scratch}/a_target_file"
        source: "#{scratch}/a_source_file"
        preserve: true
      .file.assert
        target: "#{scratch}/a_target_file"
        mode: 0o0606
      .promise()
  
  describe 'link', ->

    they 'file into file', (ssh) ->
      nikita
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
      .promise()

    they 'file parent dir', (ssh) ->
      nikita
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
      .promise()

  describe 'directory', ->

    they 'should copy without slash at the end', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir "#{scratch}/source/a_dir"
      .file.touch "#{scratch}/source/a_dir/a_file"
      .file.touch "#{scratch}/source/a_file"
      # if the target doesn't exists, then copy as target
      .system.copy
        source: "#{scratch}/source"
        target: "#{scratch}/target_1"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert "#{scratch}/target_1/a_dir/a_file"
      .file.assert "#{scratch}/target_1/a_file"
      # if the target exists, then copy the folder inside target
      .system.mkdir
        target: "#{scratch}/target_2"
      .system.copy
        source: "#{scratch}/source"
        target: "#{scratch}/target_2"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert "#{scratch}/target_2/source/a_dir/a_file"
      .file.assert "#{scratch}/target_2/source/a_file"
      .promise()

    they 'should copy the files when dir end with slash', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir "#{scratch}/source/a_dir"
      .file.touch "#{scratch}/source/a_dir/a_file"
      .file.touch "#{scratch}/source/a_file"
      # if the target doesn't exists, then copy as target
      .system.copy
        source: "#{scratch}/source/"
        target: "#{scratch}/target_1"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert "#{scratch}/target_1/a_dir/a_file"
      .file.assert "#{scratch}/target_1/a_file"
      # if the target exists, then copy the files inside target
      .system.mkdir
        target: "#{scratch}/target_2"
      .system.copy
        source: "#{scratch}/source/"
        target: "#{scratch}/target_2"
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert "#{scratch}/target_2/a_dir/a_file"
      .file.assert "#{scratch}/target_2/a_file"
      .promise()

    they 'should copy hidden files', (ssh) ->
      nikita
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
            '/tmp/nikita-test/a_copy',
            '/tmp/nikita-test/a_copy/.a_hidden_file',
            '/tmp/nikita-test/a_copy/a_file'
          ]
          callback()
      .promise()
    
    they 'set permissions', (ssh) ->
      nikita
      .system.mkdir
        target: "#{scratch}/a_source"
      .file.touch
        target: "#{scratch}/a_source/a_file"
        mode: 0o0606
      .system.mkdir
        target: "#{scratch}/a_source/a_dir"
        mode: 0o0777
      .file.touch
        target: "#{scratch}/a_source/a_dir/a_file"
        mode: 0o0644
      .system.copy
        target: "#{scratch}/a_target"
        source: "#{scratch}/a_source"
        mode: 0o0700
      .file.assert
        target: "#{scratch}/a_target/a_file"
        mode: 0o0700
      .file.assert
        target: "#{scratch}/a_target/a_dir"
        mode: 0o0700
      .file.assert
        target: "#{scratch}/a_target/a_dir/a_file"
        mode: 0o0700
      .promise()
    
    they 'preserve permissions', (ssh) ->
      nikita
      .system.mkdir
        target: "#{scratch}/a_source"
      .file.touch
        target: "#{scratch}/a_source/a_file"
        mode: 0o0606
      .system.mkdir
        target: "#{scratch}/a_source/a_dir"
        mode: 0o0700
      .file.touch
        target: "#{scratch}/a_source/a_dir/a_file"
        mode: 0o0644
      .system.copy
        target: "#{scratch}/a_target"
        source: "#{scratch}/a_source"
        preserve: true
      .file.assert
        target: "#{scratch}/a_target/a_file"
        mode: 0o0606
      .file.assert
        target: "#{scratch}/a_target/a_dir"
        mode: 0o0700
      .file.assert
        target: "#{scratch}/a_target/a_dir/a_file"
        mode: 0o0644
      .promise()

    they.skip 'should copy with globing and hidden files', (ssh) ->
      nikita
        ssh: ssh
      # if the target doesn't exists, then copy as target
      .system.copy
        source: "#{__dirname}/../*"
        target: "#{scratch}"
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        glob ssh, "#{scratch}/**", dot: true, (err, files) ->
          callback err
      .promise()
