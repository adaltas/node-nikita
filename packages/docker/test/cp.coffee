
import nikita from '@nikitajs/core'
import path from 'node:path'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.cp', ->
  return unless test.tags.docker

  @timeout 20000
  
  they 'a remote file to a local file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm
        container: 'nikita_extract'
      await @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: 'nikita_extract:/etc/apk/repositories'
        target: "#{tmpdir}/a_file"
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/a_file"
      await @docker.rm
        container: 'nikita_extract'

  they 'a remote file to a local directory', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm container: 'nikita_extract'
      await @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: 'nikita_extract:/etc/apk/repositories'
        target: "#{tmpdir}"
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/repositories"
      await @docker.rm container: 'nikita_extract'

  they 'a local file to a remote file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm container: 'nikita_extract'
      await @file
        content: "Hello"
        target: "#{tmpdir}/source/a_file"
      await @fs.mkdir "#{tmpdir}/target"
      await @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        volume: "#{tmpdir}:/root"
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: "#{tmpdir}/source/a_file"
        target: "nikita_extract:/root/a_file"
      $status.should.be.true()
      await @docker.cp
        source: 'nikita_extract:/root/a_file'
        target: "#{tmpdir}/target"
      await @fs.assert
        target: "#{tmpdir}/target/a_file"
      await @docker.rm container: 'nikita_extract'

  they 'a local file to a remote directory', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm container: 'nikita_extract'
      await @file
        content: "Hello"
        target: "#{tmpdir}/source/a_file"
      await @fs.mkdir "#{tmpdir}/target"
      await @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        volume: "#{tmpdir}:/root"
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: "#{tmpdir}/source/a_file"
        target: "nikita_extract:/root"
      $status.should.be.true()
      await @docker.cp
        source: "nikita_extract:/root/a_file"
        target: "#{tmpdir}/target"
      await @fs.assert
        target: "#{tmpdir}/target/a_file"
      await @docker.rm container: 'nikita_extract'
