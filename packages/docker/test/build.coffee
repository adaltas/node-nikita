
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.build', ->
  return unless test.tags.docker

  @timeout 60000

  describe 'errors', ->

    they 'fail with missing image parameter', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      .docker.build
        file: "/a_dir/Dockerfile"
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `docker.build`:'
          '#/required config must have required property \'image\'.'
        ].join ' '

    they 'fail with exclusive parameters', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      .docker.build
        image: 'nikita/should_not_exists_1'
        file: "/a_dir/Dockerfile"
        content: "FROM scratch \ CMD ['echo \"hello world\"']"
      .should.be.rejectedWith
        code: 'NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED'
        message: 'NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED: could not build the container, one of the `content` or `file` config property must be provided'


  describe 'usage', ->
    
    they 'from text', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      , ->
        await @docker.rmi 'nikita/should_exists_1'
        {$status, image_id, stdout, stderr} = await @docker.build
          image: 'nikita/should_exists_1'
          content: """
          FROM scratch
          CMD echo hello 1
          """
        $status.should.be.true()
        image_id.should.match /^\w{12}$/
        stdout.should.be.a.String()
        stderr.should.be.a.String()
        await @docker.rmi 'nikita/should_exists_1'

    they 'from cwd',  ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @docker.rmi 'nikita/should_exists_2'
        await @file
          target: "#{tmpdir}/Dockerfile"
          content: """
          FROM scratch
          CMD echo hello 2
          """
        {$status, image_id} = await @docker.build
          image: 'nikita/should_exists_2'
          cwd: tmpdir
        $status.should.be.true()
        image_id.should.match /^\w{12}$/
        await @docker.rmi 'nikita/should_exists_2'

    they 'from Dockerfile (exist)', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @docker.rmi 'nikita/should_exists_3'
        await @file
          content: """
          FROM scratch
          CMD ['echo "hello build from Dockerfile #{Date.now()}"']
          """
          target: "#{tmpdir}/nikita_Dockerfile"
        {$status, image_id} = await @docker.build
          image: 'nikita/should_exists_3'
          file: "#{tmpdir}/nikita_Dockerfile"
        $status.should.be.true()
        image_id.should.match /^\w{12}$/
        await @docker.rmi 'nikita/should_exists_3'

    they 'from Dockerfile (not exist)', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @docker.build
          image: 'nikita/should_not_exists_4'
          file: "#{tmpdir}/file/does/not/exist"
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_FILE_MISSING'

    they 'status not modified', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @docker.rmi 'nikita/should_exists_5'
        await @file
          target: "#{tmpdir}/nikita_Dockerfile"
          content: """
          FROM scratch
          CMD echo hello 5
          """
        {$logs: logs_status_true, $status} = await @docker.build
          image: 'nikita/should_exists_5'
          file: "#{tmpdir}/nikita_Dockerfile"
        $status.should.be.true()
        {$logs: logs_status_false, $status} = await @docker.build
          image: 'nikita/should_exists_5'
          file: "#{tmpdir}/nikita_Dockerfile"
        $status.should.be.false()
        await @docker.rmi 'nikita/should_exists_5'
        await @call ->
          logs_status_true.filter( (s) -> /^New image id/.test s?.message ).length.should.eql 1
          logs_status_false.filter( (s) -> /^Identical image id/.test s?.message ).length.should.eql 1
