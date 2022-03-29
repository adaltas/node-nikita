
path = require 'path'
os = require 'os'
fs = require 'ssh2-fs'
{tags, config} = require '../../test'
nikita = require '../../../src'
they = require('mocha-they')(config)

describe 'plugins.metadata.tmpdir', ->
  return unless tags.api
  
  describe 'validation', ->

    # Schema validation doesn't seem to works, leave it here for later
    they.skip 'invalid value (schema)', ({ssh}) ->
      await nikita
        $ssh: ssh
        $tmpdir: {'oh': 'no'}
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/tmpdir/oneOf'
        'metadata/tmpdir must match exactly one schema in oneOf,'
        'passingSchemas is [0,1].'
      ].join ' '

    they 'invalid value (hardcoded, to be replaced by schema)', ({ssh}) ->
      nikita.call $ssh: ssh, $tmpdir: null, (->)
      .should.be.rejectedWith
        code: 'METADATA_TMPDIR_INVALID'
        message: [
          'METADATA_TMPDIR_INVALID:'
          'the "tmpdir" metadata value must be a boolean, a function, an object or a string,'
          "got null"
        ].join ' '
  
  describe 'accepted values', ->

    they 'is a boolean', ({ssh}) ->
      nikita
        $ssh: ssh
      .call $tmpdir: true, ({metadata: {tmpdir}, ssh}) ->
        await fs.exists(ssh, tmpdir).should.be.resolvedWith true
        tmpdir
      .then (tmpdir) ->
        path.parse(tmpdir).name.should.match /^nikita-\w{32}$/

    they 'is a relative path', ({ssh}) ->
      target = "./nikita-#{Math.random().toString(36).replace(/[^a-z]+/g, '')}"
      nikita
        $ssh: ssh
      .call $tmpdir: target, ({metadata: {tmpdir}, ssh}) ->
        await fs.exists(ssh, tmpdir).should.be.resolvedWith true
        tmpdir
      .then (tmpdir) ->
        tmpdir.should.eql unless ssh
        then path.resolve os.tmpdir(), target
        else path.posix.resolve '/tmp', target
          
    they 'is an absolute path', ({ssh}) ->
      target = "./nikita-#{Math.random().toString(36).replace(/[^a-z]+/g, '')}"
      target = unless ssh
      then path.resolve os.tmpdir(), target
      else path.posix.resolve '/tmp', target
      nikita
        $ssh: ssh
      .call $tmpdir: target, ({metadata: {tmpdir}, ssh}) ->
        await fs.exists(ssh, tmpdir).should.be.resolvedWith true
        tmpdir
      .then (tmpdir) ->
        tmpdir.should.eql target
    
    they 'is a function', ({ssh}) ->
      nikita
        $ssh: ssh
      .call
        $tmpdir: ({action, os_tmpdir, tmpdir}) ->
          os_tmpdir.should.eql unless ssh
          then os.tmpdir()
          else '/tmp'
          tmpdir.should.match /^nikita-.*/
          # Test action arg and return
          target: action.tools.path.join os_tmpdir, "#{tmpdir}-ok"
      , ({metadata: {tmpdir}, ssh}) ->
        await fs.exists(ssh, tmpdir).should.be.resolvedWith true
        tmpdir
      .then (tmpdir) ->
        tmpdir.should.match /ok$/
    
  describe 'disposal', ->

    they 'remove directory', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({ssh}) ->
        tmpdir = await @call
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          tmpdir
        fs.exists(ssh, tmpdir).should.be.resolvedWith false

    they 'remove directory with files and folders inside', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({ssh}) ->
        tmpdir = await @call
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          await fs.mkdir ssh, "#{tmpdir}/a_dir"
          await fs.writeFile ssh, "#{tmpdir}/a_dir/a_file", ''
          tmpdir
        fs.exists(ssh, tmpdir).should.be.resolvedWith false
  
  describe 'cascade', ->

    they 'not available in children', ({ssh}) ->
      nikita.call $ssh: ssh, $tmpdir: true, ->
        @call -> @call ({metadata: {tmpdir}}) ->
          should(tmpdir).be.undefined()

    they 'several true dont change value', ({ssh}) ->
      nikita.call
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir: tmpdir1}}) ->
        @call
          $tmpdir: true
        , ({metadata: {tmpdir: tmpdir2}}) ->
          @call
            $tmpdir: true
          , ({metadata: {tmpdir: tmpdir3}}) ->
            tmpdir1.should.eql tmpdir2
            tmpdir1.should.eql tmpdir3

    they 'recreated with new ssh connection', ({ssh}) ->
      return unless ssh
      {ssh} = await nikita.ssh.open ssh
      # console.log '>>> 1 start'
      tmpdir3 = await nikita.call
        $tmpdir: true
      , ({metadata: {tmpdir: tmpdir1}}) ->
        # console.log '>>> 2 start'
        tmpdir3 = await @call
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir: tmpdir2}}) ->
          # console.log '>>> 3 start'
          tmpdir3 = await @call
            $ssh: false
            $tmpdir: true
          , ({metadata: {tmpdir: tmpdir3}}) ->
            # console.log 'tmpdir1', tmpdir1
            # console.log 'tmpdir2', tmpdir2
            # console.log 'tmpdir3', tmpdir3
            tmpdir1.should.not.eql tmpdir2
            tmpdir1.should.eql tmpdir3
            tmpdir3
          # console.log '<<< 3 end'
          await @fs.assert tmpdir3
          tmpdir3
        # console.log '<<< 2 end'
        await @fs.assert tmpdir3
        tmpdir3
      # console.log '<<< 1 end'
      await nikita.fs.assert target: tmpdir3, not: true
      await nikita.ssh.close ssh: ssh
  
  describe 'metadata', ->
          
    they 'with ssh in same child action', -> ({ssh}) ->
      # Fix bug where the ssh connection was not discoved when
      # ssh was created in the same child and tmpdir
      nikita.call $ssh: ssh, $tmpdir: true, (->)
      .should.be.resolved()

    they 'with templated', ({ssh}) ->
      target = "./nikita-#{Math.random().toString(36).replace(/[^a-z]+/g, '')}"
      target = unless ssh
      then path.resolve os.tmpdir(), target
      else path.posix.resolve '/tmp', target
      nikita
        $ssh: ssh
      .call
        $tmpdir: target
        $templated: true
        target: "a value with {{metadata.tmpdir}}"
      , ({config}) ->
        config.target.should.eql "a value with #{target}"
  
  describe 'config.dirty', ->

    they 'is true', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
      , ->
        try
          @call $tmpdir: true, $dirty: true, (->)
          {exists} = await @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
          exists.should.be.true()
        finally
          @fs.base.rmdir '{{siblings.0.metadata.tmpdir}}'

    they 'is false', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
      , ->
        @call $tmpdir: true, $dirty: false, (->)
        @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
        .should.finally.match exists: false
