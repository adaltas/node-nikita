
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.json', ->
  return unless test.tags.posix

  they 'stringify content to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/target.json"
        content: 'doesnt have to be valid json'
      await @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"user":"usrval"}'

  they 'merge target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/target.json"
        content: '{"target":"tarval","user":"overwrite"}'
      await @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
        merge: true
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"target":"tarval","user":"usrval"}'

  they 'merge source', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/source.json"
        content: '{"source":"srcval","user":"overwrite"}'
      await @file.json
        source: "#{tmpdir}/source.json"
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"source":"srcval","user":"usrval"}'

  they 'merge source and traget', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/source.json"
        content: '{"source":"srcval","target":"overwrite","user":"overwrite"}'
      await @file
        target: "#{tmpdir}/target.json"
        content: '{"target":"tarval","user":"overwrite"}'
      await @file.json
        source: "#{tmpdir}/source.json"
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
        merge: true
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"source":"srcval","target":"tarval","user":"usrval"}'
  
  they 'merge with target not yet created', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
        merge: true
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"user":"usrval"}'
  
  they 'transform', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/target.json"
        content: '{"target":"transform","user":"overwrite"}'
      await @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'transform'
        merge: true
        transform: (json) ->
          json.target = "#{json.target} tarval"
          json.user = "#{json.user} usrval"
          json.transform = "tfmval"
          json
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"target":"transform tarval","user":"transform usrval","transform":"tfmval"}'
  
  they 'pretty', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.json
        target: "#{tmpdir}/pretty.json"
        content: 'user': 'preferences': 'language': 'french'
        pretty: true
      await @fs.assert
        target: "#{tmpdir}/pretty.json"
        content: '{\n  \"user\": {\n    \"preferences\": {\n      \"language\": \"french\"\n    }\n  }\n}'
  
  they 'pretty with user indentation', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.json
        target: "#{tmpdir}/pretty_0.json"
        content: 'user': 'preferences': 'language': 'french'
        pretty: 0
      await @fs.assert
        target: "#{tmpdir}/pretty_0.json"
        content: '{"user":{"preferences":{"language":"french"}}}'
      await @file.json
        target: "#{tmpdir}/pretty_1.json"
        content: 'user': 'preferences': 'language': 'french'
        pretty: 1
      await @fs.assert
        target: "#{tmpdir}/pretty_1.json"
        content: '{\n \"user\": {\n  \"preferences\": {\n   \"language\": \"french\"\n  }\n }\n}'
