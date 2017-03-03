
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.json', ->

  scratch = test.scratch @

  they 'stringify content to target', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: 'doent have to be valid json'
    .file.json
      target: "#{scratch}/target.json"
      content: user: 'usrval'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"user":"usrval"}'
    .then next

  they 'merge target', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"overwrite"}'
    .file.json
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"usrval"}'
    .then next

  they 'merge source', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/source.json"
      content: '{"source":"srcval","user":"overwrite"}'
    .file.json
      source: "#{scratch}/source.json"
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"source":"srcval","user":"usrval"}'
    .then next

  they 'merge source and traget', (ssh, next) ->
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
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"source":"srcval","target":"tarval","user":"usrval"}'
    .then next
  
  they 'merge with target not yet created', (ssh, next) ->
    nikita
      ssh: ssh
    .file.json
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"user":"usrval"}'
    .then next
  
  they 'transform', (ssh, next) ->
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
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"target":"transform tarval","user":"transform usrval","transform":"tfmval"}'
    .then next
  
  they 'pretty', (ssh, next) ->
    nikita
      ssh: ssh
    .file.json
      target: "#{scratch}/pretty.json"
      content: 'user': 'preferences': 'language': 'french'
      pretty: true
    .file.assert
      target: "#{scratch}/pretty.json"
      content: '{\n  \"user\": {\n    \"preferences\": {\n      \"language\": \"french\"\n    }\n  }\n}'
    .then next
  
  they 'pretty with user indentation', (ssh, next) ->
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
    .then next
    
