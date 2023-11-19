
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.types.my_cnf', ->
  return unless test.tags.posix

  they 'generate from content', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.my_cnf
        target: "#{tmpdir}/my.cnf"
        content:
          'client':
            'socket': '/var/lib/mysql/mysql.sock'
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/my.cnf"
        content: """
        [client]
        socket = /var/lib/mysql/mysql.sock
        """
        trim: true
