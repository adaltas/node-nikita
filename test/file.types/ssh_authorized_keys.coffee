
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.types.yum_repo', ->

  scratch = test.scratch @

  they 'overwrite file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/authorized_keys"
      content: "# Some Comment"
    .file.types.ssh_authorized_keys
      target: "#{scratch}/authorized_keys"
      keys: [
        'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description'
      ]
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/authorized_keys"
      content: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description\n"
    .promise()

  they 'merge file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/authorized_keys"
      content: "# Some Comment"
    .file.types.ssh_authorized_keys
      target: "#{scratch}/authorized_keys"
      keys: [
        'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description'
      ]
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/authorized_keys"
      content: """
      # Some Comment
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description\n
      """
    .promise()
