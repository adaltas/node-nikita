
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'file.types.hfile', ->

  they 'without properties', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      content: {}
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      content: {}
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/empty.xml"
      content: """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <configuration/>
      """.trim()
    .promise()

  they 'with properties', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      properties: a_key: 'a value'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      properties: a_key: 'a value'
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/empty.xml"
      content: """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <configuration>
        <property>
          <name>a_key</name>
          <value>a value</value>
        </property>
      </configuration>
      """.trim()
    .promise()

  they 'with source', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/empty.xml"
      content: """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <configuration>
        <property>
          <name>a_key</name>
          <value>a value</value>
        </property>
      </configuration>
      """.trim()
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      properties: a_key: 'a value'
      source: "#{scratch}/empty.xml"
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      properties: a_key: 'a new value'
      source: "#{scratch}/empty.xml"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      properties: a_new_key: 'a value'
      source: "#{scratch}/empty.xml"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'transform', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/empty.xml"
      content: """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <configuration>
        <property>
          <name>key_1</name>
          <value>value 1</value>
        </property>
      </configuration>
      """.trim()
    .file.types.hfile
      target: "#{scratch}/empty.xml"
      merge: true
      properties: key_2: 'value 2'
      transform: (props) ->
        newprops = {}
        for k, v of props
          newprops[k.toUpperCase()] = v
        newprops
    .file.assert
      target: "#{scratch}/empty.xml"
      content: """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <configuration>
        <property>
          <name>KEY_1</name>
          <value>value 1</value>
        </property>
        <property>
          <name>KEY_2</name>
          <value>value 2</value>
        </property>
      </configuration>
      """.trim()
    .promise()
