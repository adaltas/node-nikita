
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.json', ->

  they 'stringify content to target', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: 'doent have to be valid json'
    .file.json
      target: "#{scratch}/target.json"
      content: user: 'usrval'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"user":"usrval"}'
    .promise()

  they 'merge target', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"overwrite"}'
    .file.json
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"usrval"}'
    .promise()

  they 'merge source', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/source.json"
      content: '{"source":"srcval","user":"overwrite"}'
    .file.json
      source: "#{scratch}/source.json"
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"source":"srcval","user":"usrval"}'
    .promise()

  they 'merge source and traget', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/source.json"
      content: '{"source":"srcval","target":"overwrite","user":"overwrite"}'
    .file
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"overwrite"}'
    .file.json
      source: "#{scratch}/source.json"
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"source":"srcval","target":"tarval","user":"usrval"}'
    .promise()
  
  they 'merge with target not yet created', ({ssh}) ->
    nikita
      ssh: ssh
    .file.json
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"user":"usrval"}'
    .promise()
  
  they 'transform', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: '{"target":"transform","user":"overwrite"}'
    .file.json
      target: "#{scratch}/target.json"
      content: 'user': 'transform'
      merge: true
      transform: (json) ->
        json.target = "#{json.target} tarval"
        json.user = "#{json.user} usrval"
        json.transform = "tfmval"
        json
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"target":"transform tarval","user":"transform usrval","transform":"tfmval"}'
    .promise()
  
  they 'pretty', ({ssh}) ->
    nikita
      ssh: ssh
    .file.json
      target: "#{scratch}/pretty.json"
      content: 'user': 'preferences': 'language': 'french'
      pretty: true
    .file.assert
      target: "#{scratch}/pretty.json"
      content: '{\n  \"user\": {\n    \"preferences\": {\n      \"language\": \"french\"\n    }\n  }\n}'
    .promise()
  
  they 'pretty with user indentation', ({ssh}) ->
    nikita
      ssh: ssh
    .file.json
      target: "#{scratch}/pretty_0.json"
      content: 'user': 'preferences': 'language': 'french'
      pretty: 0
    .file.assert
      target: "#{scratch}/pretty_0.json"
      content: '{"user":{"preferences":{"language":"french"}}}'
    .file.json
      target: "#{scratch}/pretty_1.json"
      content: 'user': 'preferences': 'language': 'french'
      pretty: 1
    .file.assert
      target: "#{scratch}/pretty_1.json"
      content: '{\n \"user\": {\n  \"preferences\": {\n   \"language\": \"french\"\n  }\n }\n}'
    .promise()
