
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.base.chmod', ->
  
  describe 'schema', ->
    return unless test.tags.api
    
    it 'absolute mode', ->
      nikita.fs.base.chmod
        mode: 0o1744
        target: '/tmp/file'
      , ({config}) ->
        config.mode.should.eql 0o1744
    
    it 'symbolic mode', ->
      nikita.fs.base.chmod
        mode: 'u=rwx'
        target: '/tmp/file'
      , ({config}) ->
        config.mode.should.eql 'u=rwx'
        
    it 'disable coersion from string to absolute mode', ->
      nikita.fs.base.chmod
        mode: '744'
        target: '/tmp/file'
      , ({config}) ->
        config.mode.should.eql 0o0744
  
  describe 'usage', ->
    return unless test.tags.posix

    they 'create', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ->
        await @fs.writeFile
          target: "{{parent.metadata.tmpdir}}/a_target"
          content: 'hello'
        await @fs.base.chmod
          mode: 0o600
          target: "{{parent.metadata.tmpdir}}/a_target"
        {stats} = await @fs.stat
          target: "{{parent.metadata.tmpdir}}/a_target"
        (stats.mode & 0o777).toString(8).should.eql '600'
