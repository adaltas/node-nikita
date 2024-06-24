
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.base.chown', ->
  
  describe 'schema', ->
    return unless test.tags.api
    
    it 'id integers', ->
      nikita.fs.base.chown
        uid: 1234
        gid: 5678
        target: '/tmp/file'
      , ({config}) ->
        config.uid.should.eql 1234
        config.gid.should.eql 5678
        
    it 'id integers', ->
      nikita.fs.base.chown
        uid: 'username'
        gid: 'group'
        target: '/tmp/file'
      , ({config}) ->
        config.uid.should.eql 'username'
        config.gid.should.eql 'group'
        
    it 'coercion', ->
      nikita.fs.base.chown
        uid: '1234'
        gid: '5678'
        target: '/tmp/file'
      , ({config}) ->
        config.uid.should.eql 1234
        config.gid.should.eql 5678
  
  describe 'usage', ->
    return unless test.tags.chown
    
    they 'pass id integers', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        await @fs.base.chown "#{tmpdir}/a_file", uid: 1234, gid: 5678
        {stats} = await @fs.stat "#{tmpdir}/a_file"
        stats.should.match
          uid: 1234
          gid: 5678
    
    they 'pass string names', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        await @fs.base.chown "#{tmpdir}/a_file", uid: 'toto', gid: 'toto'
        {stats} = await @fs.stat "#{tmpdir}/a_file"
        stats.should.match
          uid: 1234
          gid: 5678
