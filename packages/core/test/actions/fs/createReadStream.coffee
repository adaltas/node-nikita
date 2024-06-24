
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.createReadStream', ->
  return unless test.tags.posix

  they 'option on_readable', ({ssh}) ->
    buffers = []
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      await @fs.createReadStream
        target: "{{parent.metadata.tmpdir}}/a_file"
        on_readable: (rs) ->
          while buffer = rs.read()
            buffers.push buffer
      Buffer.concat(buffers).toString().should.eql 'hello'

  they 'option stream', ({ssh}) ->
    buffers = []
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      @fs.createReadStream
        target: "{{parent.metadata.tmpdir}}/a_file"
        stream: (rs) ->
          rs.on 'readable', ->
            while buffer = rs.read()
              buffers.push buffer
      .then ->
        Buffer.concat(buffers).toString().should.eql 'hello'
      
  describe 'errors', ->

    they 'schema', ({ssh}) ->
      # Note, we encountered a weird behavior
      # after introducing the schema definition `config.properties.sudo.$ref`
      # the error message is altered:
      # before, `#/definitions/config/required config must have required property 'target'`
      # after, `#/required config must have required property 'target'`
      # Note, switching from a ref to a hard-coded definition revert the error message
      nikita
        $ssh: ssh
      , ->
        @fs.createReadStream
          stream: (->)
        .should.be.rejectedWith
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'one error was found in the configuration of action `fs.createReadStream`:'
            # '#/definitions/config/required'
            '#/required'
            'config must have required property \'target\'.'
          ].join ' '
    
    they 'NIKITA_FS_CRS_TARGET_ENOENT if file does not exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.createReadStream
          target: "#{tmpdir}/a_file"
          stream: (rs) ->
            rs.on 'readable', ->
              while buffer = rs.read()
                buffers.push buffer
        .should.be.rejectedWith
          message: "NIKITA_FS_CRS_TARGET_ENOENT: fail to read a file because it does not exist, location is \"#{tmpdir}/a_file\"."
          errno: -2
          code: 'NIKITA_FS_CRS_TARGET_ENOENT'
          syscall: 'open'
          path: "#{tmpdir}/a_file"
  
    they 'NIKITA_FS_CRS_TARGET_EISDIR if file is a directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.createReadStream
          target: "#{tmpdir}"
          on_readable: (rs) ->
            while buffer = rs.read()
              buffers.push buffer
        .should.be.rejectedWith
          message: "NIKITA_FS_CRS_TARGET_EISDIR: fail to read a file because it is a directory, location is \"#{tmpdir}\"."
          errno: -21
          code: 'NIKITA_FS_CRS_TARGET_EISDIR'
          syscall: 'read'
          path: "#{tmpdir}"
      
    
  
