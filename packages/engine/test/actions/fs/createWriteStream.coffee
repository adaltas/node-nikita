
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.createWriteStream', ->

  they 'write a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.createWriteStream
        target: "{{parent.metadata.tmpdir}}/a_file"
        stream: (ws) ->
          ws.write 'hello'
          ws.end()
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith 'hello'

  they 'argument `target`', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.createWriteStream "{{parent.metadata.tmpdir}}/a_file",
        stream: (ws) ->
          ws.write 'hello'
          ws.end()
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith 'hello'
  
  they.skip 'option flags a', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.createWriteStream
        target: "{{parent.metadata.tmpdir}}/a_file"
        stream: (ws) ->
          ws.write 'hello'
          ws.end()
      @fs.createWriteStream
        target: "{{parent.metadata.tmpdir}}/a_file"
        flags: 'a'
        stream: (ws) ->
          ws.write ' nikita'
          ws.end()
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith "hello nikita"
  
  describe 'errors', ->
  
    they 'schema', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @fs.createWriteStream
          target: "a_file"
        .should.be.rejectedWith 'NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration: #/required config should have required property \'stream\'.'
        @fs.createWriteStream
          stream: (->)
        .should.be.rejectedWith 'NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration: #/required config should have required property \'target\'.'

    they 'NIKITA_FS_CWS_TARGET_ENOENT if parent direction does not exist', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.createWriteStream
          target: "#{tmpdir}/a_dir/a_file"
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        .should.be.rejectedWith
          message: "NIKITA_FS_CWS_TARGET_ENOENT: fail to write a file, location is \"#{tmpdir}/a_dir/a_file\"."
          errno: -2
          code: 'NIKITA_FS_CWS_TARGET_ENOENT'
          syscall: 'open'
          path: "#{tmpdir}/a_dir/a_file"
    
