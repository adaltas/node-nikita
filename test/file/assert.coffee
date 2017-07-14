
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'fs'

describe 'file.assert', ->

  scratch = test.scratch @
  
  describe 'exists', ->

    they 'file doesnt not exist', (ssh) ->
      nikita
        ssh: ssh
      .file.assert "#{scratch}/a_file", relax: true, (err) ->
        err.message.should.eql "File does not exists: \"#{scratch}/a_file\""
      .promise()

    they 'file exists', (ssh) ->
      nikita
        ssh: ssh
      .file.touch "#{scratch}/a_file"
      .file.assert "#{scratch}/a_file"
      .promise()

    they 'with option not', (ssh) ->
      nikita
        ssh: ssh
      .file.assert "#{scratch}/a_file", not: true
      .file.touch "#{scratch}/a_file"
      .file.assert "#{scratch}/a_file", not: true, relax: true, (err) ->
        err.message.should.eql "File exists: \"#{scratch}/a_file\""
      .promise()

    they 'requires target', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        content: "are u here"
        relax: true
      , (err) ->
        err.message.should.eql 'Missing option: "target"'
      .promise()

    they 'send custom error message', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}/a_file"
        error: 'Got it'
        relax: true
      , (err) ->
        err.message.should.eql 'Got it'
      .promise()
  
  describe 'type', ->
    
    they 'assert a file', (ssh) ->
      nikita
        ssh: ssh
      .file.touch "#{scratch}/a_file"
      .file.assert
        target: "#{scratch}/a_file"
        filetype: 'file'
      .file.assert
        target: "#{scratch}/a_file"
        filetype: fs.constants.S_IFREG
      .file.assert
        target: "#{scratch}"
        filetype: 'file'
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid filetype: expect a regular file'
      .promise()
    
    they 'assert a directory', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}"
        filetype: 'directory'
      .file.assert
        target: "#{scratch}"
        filetype: fs.constants.S_IFDIR
      .file.touch "#{scratch}/a_file"
      .file.assert
        target: "#{scratch}/a_file"
        filetype: 'directory'
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid filetype: expect a directory'
      .promise()

  describe 'content', ->

    they 'content match', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        content: "are u here"
      .promise()

    they 'option source is alias of target', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        source: "#{scratch}/a_file"
        content: "are u here"
      .promise()

    they 'content dont match', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        content: "are u sure"
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid content: expect "are u sure" and got "are u here"'
      .promise()

    they 'content match regexp', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "toto\nest\r\nau\rbistrot"
      .file.assert
        target: "#{scratch}/a_file"
        content: /^bistrot$/m
      .promise()

    they 'with option not', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        content: "are u sure"
        not: true
      .file.assert
        target: "#{scratch}/a_file"
        content: "are u here"
        relax: true
        not: true
      , (err) ->
        err.message.should.eql 'Unexpected content: "are u here"'
      .promise()

    they 'send custom error message', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        content: "are u sure"
        error: 'Got it'
        relax: true
      , (err) ->
        err.message.should.eql "Got it"
      .promise()
  
  describe 'option md5', ->
    
    they 'detect if file does not exists', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}/a_file"
        md5: 'toto'
        relax: true
      , (err) ->
        err.message.should.eql "Target does not exists: #{scratch}/a_file"
      .promise()
    
    they 'validate hash', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}/a_file"
        md5: 'toto'
        relax: true
      , (err) ->
        err.message.should.eql "Target does not exists: #{scratch}/a_file"
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        md5: "invalidmd5signature"
        relax: true
      , (err) ->
        err.message.should.eql "Invalid md5 signature: expect \"invalidmd5signature\" and got \"f0a1e0f2412f62cc97178fd6b44dc978\""
      .file.assert
        target: "#{scratch}/a_file"
        md5: "f0a1e0f2412f62cc97178fd6b44dc978"
      .promise()

    they 'with option not', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        md5: 'toto'
        not: true
      .file.assert
        target: "#{scratch}/a_file"
        md5: "f0a1e0f2412f62cc97178fd6b44dc978"
        not: true
        relax: true
      , (err) ->
        err.message.should.eql "Matching md5 signature: \"f0a1e0f2412f62cc97178fd6b44dc978\""
      .promise()

    they 'send custom error message', (ssh) ->
      nikita
        ssh: ssh
      .file.touch
        target: "#{scratch}/a_file"
      .file.assert
        target: "#{scratch}/a_file"
        md5: 'toto'
        error: 'Got it'
        relax: true
      , (err) ->
        err.message.should.eql 'Got it'
      .promise()

  describe 'option sha1', ->
    
    they 'validate hash', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}/a_file"
        sha1: 'toto'
        relax: true
      , (err) ->
        err.message.should.eql "Target does not exists: #{scratch}/a_file"
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        sha1: "invalidsignature"
        relax: true
      , (err) ->
        err.message.should.eql "Invalid sha1 signature: expect \"invalidsignature\" and got \"94d1f318f02816c590bd65595c28df1dd7ff326b\""
      .file.assert
        target: "#{scratch}/a_file"
        sha1: "94d1f318f02816c590bd65595c28df1dd7ff326b"
      .promise()

  describe 'option sha256', ->
    
    they 'validate hash', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}/a_file"
        sha256: 'toto'
        relax: true
      , (err) ->
        err.message.should.eql "Target does not exists: #{scratch}/a_file"
      .file
        target: "#{scratch}/a_file"
        content: "are u here"
      .file.assert
        target: "#{scratch}/a_file"
        sha256: "invalidsignature"
        relax: true
      , (err) ->
        err.message.should.eql "Invalid sha256 signature: expect \"invalidsignature\" and got \"c98fbf6b29ab2b709b642997930f3679eedd1f5f33078bc527f770c088f0463c\""
      .file.assert
        target: "#{scratch}/a_file"
        sha256: "c98fbf6b29ab2b709b642997930f3679eedd1f5f33078bc527f770c088f0463c"
      .promise()

  describe 'option mode', ->
    
    they 'detect if file does not exists', (ssh) ->
      nikita
        ssh: ssh
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o755
        relax: true
      , (err) ->
        err.message.should.eql "Target does not exists: #{scratch}/a_file"
      .promise()
          
    they 'on file', (ssh) ->
      nikita
        ssh: ssh
      .file.touch
        target: "#{scratch}/a_file"
        mode: 0o0755
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0644
        relax: true
      , (err) ->
        err.message.should.eql "Invalid mode: expect 0644 and got 0755"
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0755
      .promise()

    they 'on directory', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/a_file"
        content: "are u here"
        mode: 0o0755
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0644
        relax: true
      , (err) ->
        err.message.should.eql "Invalid mode: expect 0644 and got 0755"
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0755
      .promise()

    they 'with option not', (ssh) ->
      nikita
        ssh: ssh
      .file.touch
        target: "#{scratch}/a_file"
        mode: 0o0755
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0644
        not: true
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0755
        not: true
        relax: true
      , (err) ->
        err.message.should.eql "Unexpected valid mode: 0755"
      .promise()

    they 'send custom error message', (ssh) ->
      nikita
        ssh: ssh
      .file.touch
        target: "#{scratch}/a_file"
        mode: 0o0755
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0644
        error: 'Got it'
        relax: true
      , (err) ->
        err.message.should.eql 'Got it'
      .promise()

  describe 'options uid & gid', ->
    
    they 'detect root ownerships', (ssh) ->
      return unless process.getuid() is 0
      nikita
        ssh: ssh
      .file.touch "#{scratch}/a_file"
      .file.assert "#{scratch}/a_file",
        uid: 0
        gid: 0
      .file.assert "#{scratch}/a_file",
        uid: 1
        gid: 0
        relax: true
      , (err) ->
        err.message.should.eql "Unexpected uid: expected \"1\" and got \"0\""
      .file.assert "#{scratch}/a_file",
        uid: 0
        gid: 1
        relax: true
      , (err) ->
        err.message.should.eql "Unexpected gid: expected \"1\" and got \"0\""
      .promise()
      
    
