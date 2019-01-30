
nikita = require '@nikitajs/core'
path = require 'path'
{tags, ssh, scratch, docker} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.cp', ->

  @timeout 20000
  
  they 'a remote file to a local file', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_extract'
    .docker.run
      name: 'nikita_extract'
      image: 'alpine'
      cmd: "whoami"
      rm: false
    .docker.cp
      source: 'nikita_extract:/etc/apk/repositories'
      target: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/a_file"
    .docker.rm
      container: 'nikita_extract'
    .promise()

  they 'a remote file to a local directory', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm container: 'nikita_extract'
    .docker.run
      name: 'nikita_extract'
      image: 'alpine'
      cmd: "whoami"
      rm: false
    .docker.cp
      source: 'nikita_extract:/etc/apk/repositories'
      target: "#{scratch}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/repositories"
    .docker.rm container: 'nikita_extract'
    .promise()

  they 'a local file to a remote file', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm container: 'nikita_extract'
    .docker.run
      name: 'nikita_extract'
      image: 'alpine'
      volume: "#{scratch}:/root"
      cmd: "whoami"
      rm: false
    .docker.cp
      source: "#{__filename}"
      target: "nikita_extract:/root/a_file"
    , (err, {status}) ->
      status.should.be.true() unless err
    .docker.cp
      source: 'nikita_extract:/root/a_file'
      target: "#{scratch}"
    .file.assert
      target: "#{scratch}/a_file"
    .docker.rm container: 'nikita_extract'
    .promise()

  they 'a local file to a remote directory', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm container: 'nikita_extract'
    .docker.run
      name: 'nikita_extract'
      image: 'alpine'
      volume: "#{scratch}:/root"
      cmd: "whoami"
      rm: false
    .docker.cp
      source: "#{__filename}"
      target: "nikita_extract:/root"
    , (err, {status}) ->
      status.should.be.true() unless err
    .docker.cp
      source: "nikita_extract:/root/#{path.basename __filename}"
      target: "#{scratch}"
    .file.assert
      target: "#{scratch}/#{path.basename __filename}"
    .docker.rm container: 'nikita_extract'
    .promise()
