
nikita = require '@nikitajs/core'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.docker

describe 'docker.rmi', ->

  they 'remove image', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.build
      image: 'nikita/rmi_test'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
    .docker.rmi
      image: 'nikita/rmi_test'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'status unmodifed', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.build
      image: 'nikita/rmi_test:latest'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
    .docker.rmi
      image: 'nikita/rmi_test'
    .docker.rmi
      image: 'nikita/rmi_test'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
