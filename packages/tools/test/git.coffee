
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)
__dirname = new URL( '.', import.meta.url).pathname

describe 'tools.git', ->
  return unless test.tags.posix

  they 'clones repo into new dir', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      $status.should.be.true()
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      $status.should.be.false()

  they 'honores revision', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
        revision: 'v0.0.1'
      $status.should.be.true()
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
        revision: 'v0.0.1'
      $status.should.be.false()

  they 'preserves existing directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      await @fs.mkdir
        target: "#{tmpdir}/my_repo"
      await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      .should.be.rejectedWith
        message: 'Not a git repository'
