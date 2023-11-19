
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.compose', ->
  return unless test.tags.docker

  @timeout 90000

  they 'up from content', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_docker_compose_up_content'
        force: true
      {$status} = await @docker.compose.up
        content:
          services:
            content:
              image: 'httpd'
              container_name: 'nikita_docker_compose_up_content'
              ports: ['12300:80']
      $status.should.be.true()
      {$status} = await @execute
        command: 'ping dind -c 1'
        code: [0, [2,68]]
      await @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 12300
      await @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 12300
      await @docker.rm
        container: 'nikita_docker_compose_up_content'
        force: true
  
  they 'up from content to file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm
        container: 'nikita_docker_docker_compose_up_content_to_file'
        force: true
      {$status} = await @docker.compose
        content:
          services:
            content_to_file:
              image: 'httpd'
              container_name: 'nikita_docker_docker_compose_up_content_to_file'
              ports: ['12301:80']
        target: "#{tmpdir}/docker_compose_up_content_to_file/docker-compose.yml"
      $status.should.be.true()
      {$status} = await @execute
        command: 'ping dind -c 1'
        code: [0, [2,68]]
      await @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 12301
      await @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 12301
      await @docker.rm
        container: 'nikita_docker_docker_compose_up_content_to_file'
        force: true

  they 'up from file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm
        container: 'nikita_docker_compose_up_file'
        force: true
      await @file.yaml
        content:
          services:
            up_from_file:
              image: 'httpd'
              container_name: 'nikita_docker_compose_up_file'
              ports: ['12302:80']
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      await @docker.compose
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      {$status} = await @execute
        command: 'ping dind -c 1'
        code: [0, [2,68]]
      await @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 12302
      await @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 12302
      await @docker.rm
        container: 'nikita_docker_compose_up_file'
        force: true
  
  they 'up with service name', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm
        container: 'nikita_docker_compose_up_service'
        force: true
      await @file.yaml
        content:
          services:
            up_with_service_name:
              image: 'httpd'
              container_name: 'nikita_docker_compose_up_service'
              ports: ['12303:80']
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      await @docker.compose
        service: 'compose'
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      {$status} = await @execute
        command: 'ping dind -c 1'
        code: [0, [2,68]]
      await @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 12303
      await @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 12303
      await @docker.rm
        container: 'nikita_docker_compose_up_service'
        force: true
  
  they 'status not modified', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rm
        container: 'nikita_docker_compose_idem'
        force: true
      await @file.yaml
        content:
          services:
            status_not_modified:
              image: 'httpd'
              container_name: 'nikita_docker_compose_idem'
              ports: ['12304:80']
        target: "#{tmpdir}/nikita_docker_compose_idem/docker-compose.yml"
      await @docker.compose
        target: "#{tmpdir}/nikita_docker_compose_idem/docker-compose.yml"
      await @network.tcp.wait
        host: 'dind'
        port: 12304
      {$status} = await @docker.compose
        target: "#{tmpdir}/nikita_docker_compose_idem/docker-compose.yml"
      $status.should.be.false()
      await @docker.rm
        container: 'nikita_docker_compose_idem'
        force: true
