
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.chown

describe 'actions.fs.chown', ->

  they 'throw error if target does not exists', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.chown "#{tmpdir}/a_file", uid: 1234, gid: 1234
      .should.be.rejectedWith
        message: "NIKITA_FS_STAT_TARGET_ENOENT: failed to stat the target, no file exists for target, got \"#{tmpdir}/a_file\""

  they 'use stat shortcircuit', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}, log, operations: {events}}) ->
      await @execute """
      echo '' > '#{tmpdir}/a_file'
      userdel 'toto'; groupdel 'toto'
      groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
      """
      logs = []
      events.on 'text', (log) -> logs.push log
      {stats} = await @fs.base.stat "#{tmpdir}/a_file"
      await @fs.chown "#{tmpdir}/a_file", uid: 1234, gid: 5678, stats: stats
      logs
      .map( (log) -> log.message )
      .some (log) -> log is 'Stat short-circuit'
      .should.be.true()

  they 'change both uid and gid', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}, log, operations: {events}}) ->
      await @execute """
      echo '' > '#{tmpdir}/a_file'
      userdel 'toto'; groupdel 'toto'
      groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
      """
      logs = []
      events.on 'text', (log) -> logs.push log
      await @fs.chown "#{tmpdir}/a_file", uid: 1234, gid: 5678
      logs.map( (log) -> log.message ).should.eql [
        'change uid from 0 to 1234'
        'change gid from 0 to 5678'
      ]

  they 'change only uid', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}, log, operations: {events}}) ->
      await @execute """
      echo '' > '#{tmpdir}/a_file'
      userdel 'toto'; groupdel 'toto'
      groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
      """
      logs = []
      events.on 'text', (log) -> logs.push log
      await @fs.chown "#{tmpdir}/a_file", uid: 1234
      logs.map( (log) -> log.message ).should.eql [
        'change uid from 0 to 1234'
      ]

  they 'change only gid', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}, log, operations: {events}}) ->
      await @execute """
      echo '' > '#{tmpdir}/a_file'
      userdel 'toto'; groupdel 'toto'
      groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
      """
      logs = []
      events.on 'text', (log) -> logs.push log
      await @fs.chown "#{tmpdir}/a_file", gid: 5678
      logs.map( (log) -> log.message ).should.eql [
        'change gid from 0 to 5678'
      ]

  they 'detect status with uid', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @execute """
      echo '' > '#{tmpdir}/a_file'
      userdel 'toto'; groupdel 'toto'
      groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
      """
      @fs.chown "#{tmpdir}/a_file", uid: 1234
      .should.finally.containEql status: true
      @fs.chown "#{tmpdir}/a_file", uid: 1234
      .should.finally.containEql status: false
