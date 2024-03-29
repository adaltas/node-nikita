
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.wait', ->
  return unless test.tags.posix
  
  describe 'schema', ->
  
    it 'string argument converted to target', ->
      nikita.fs.wait '/path/to/file', ({config}) ->
        config.target.should.eql ['/path/to/file']
  
    it 'coercion', ->
      nikita.fs.wait
        interval: '1000'
        target: 'fake'
      , ({config}) ->
        config.interval.should.eql 1000
  
  describe 'usage', ->

    they 'status false if already exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @fs.wait
          target: "#{tmpdir}"
        $status.should.be.false()

    they 'status true if created', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        setTimeout ->
          nikita($ssh: ssh).fs.mkdir "#{tmpdir}/a_dir"
        , 200
        {$status} = await @fs.wait
          target: "#{tmpdir}/a_dir"
          interval: 50
        $status.should.be.true()
