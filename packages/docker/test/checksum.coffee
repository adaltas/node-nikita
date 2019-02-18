
nikita = require '@nikitajs/core'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.docker

describe 'docker.checksum', ->

  they 'checksum on existing repository', ({ssh}) ->
    image_id = null
    nikita
      ssh: ssh
      docker: docker
    .docker.rmi
      image: 'nikita/checksum'
    .docker.build
      image: 'nikita/checksum'
      content: "FROM scratch\nCMD ['echo \"hello build from text #{Date.now()}\"']"
    , (err, {image}) ->
      image_id = image unless err
    .docker.checksum
      image: 'nikita/checksum'
      tag: 'latest'
    , (err, {checksum}) ->
      checksum.should.startWith "sha256:#{image_id}" unless err
    .docker.rmi
      image: 'nikita/checksum'
    .promise()

  they 'checksum on not existing repository', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.checksum
      image: 'nikita/invalid_checksum'
      tag: 'latest'
    , (err, {checksum}) ->
      (checksum is undefined).should.be.true() unless err
    .promise()
