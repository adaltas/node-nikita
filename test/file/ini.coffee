
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'file.ini', ->

  scratch = test.scratch @

  they 'stringify an object', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
    , (err, status) ->
      status.should.be.true() unless err
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor = rouge\n'
    .promise()

  they 'stringify an object and with custom separator', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
      separator: ':'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor:rouge\n'
    .promise()

  they 'merge an object', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: 'violet'
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = violet\n'
    .promise()

  they 'discard undefined and null', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'violet', age: undefined, gender: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor = violet\n'
    .promise()

  they 'remove null within merge', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .promise()

  they 'disregard undefined within merge', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: undefined
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'stringify write only key on props', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      content:
        'user':
          'name': 'toto'
          '--hasACar': ''
      target: "#{scratch}/user.ini"
      merge: false
      stringify: misc.ini.stringify_single_key
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user]\nname = toto\n--hasACar\n'
    .promise()

  they 'merge ini containing single key lines', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor\n'
    .file.ini
      content: user: preference: {language: 'c++', color: ''}
      stringify: misc.ini.stringify_single_key
      target: "#{scratch}/user.ini"
      merge: false
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = c++\ncolor\n'
    .promise()

  they 'use default source file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: false
    , (err, written) ->
      written.should.be.true() unless err
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: false
    , (err, written) ->
      written.should.be.false() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = node\n'
    .promise()

  they 'options source file + content', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      content: user: preference: remember: 'me'
      merge: false
    , (err, written) ->
      written.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = node\nremember = me\n'
    .promise()

  they 'options missing source file + content', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      source: "#{scratch}/does_not_exist.ini"
      target: "#{scratch}/test.ini"
      content: user: preference: remember: 'me'
      merge: false
    , (err, written) ->
      written.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nremember = me\n'
    .promise()

  they 'options source file + merge', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .file
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = c++\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: true
    , (err, written) ->
      written.should.be.true() unless err
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: true
    , (err, written) ->
      written.should.be.false() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = node\n'
    .promise()

  they 'use default source file with merge and content', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .file
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = java\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      content: user: preference: language: 'c++'
      merge: true
    , (err, written) ->
      written.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = c++\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      content: user: preference: language: 'c++'
      merge: true
    , (err, written) ->
      written.sh
    .promise()

  they 'generate from content object with escape', (ssh) ->
    nikita
      ssh: ssh
    .file.ini
      target: "#{scratch}/test.ini"
      escape: false
      content:
        "test-repo-0.0.1":
          'name': 'CentOS-$releasever - Base'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck': '1'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
    , (err, status) ->
      status.should.be.true() unless err
    .file.ini
      target: "#{scratch}/test.ini"
      escape: false
      content:
        "test-repo-0.0.1":
          'name': 'CentOS-$releasever - Base'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck': '1'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
  
  describe 'stringify_square_then_curly', ->

    they 'call stringify udf', (ssh) ->
      nikita
        ssh: ssh
      .file.ini
        stringify: misc.ini.stringify_square_then_curly
        target: "#{scratch}/user.ini"
        content: user: preference: color: true
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/user.ini"
        content: '[user]\n preference = {\n  color = true\n }\n\n'
      .promise()

    they 'convert array to multiple keys', (ssh) ->
      nikita
        ssh: ssh
      # Create a new file
      .file.ini
        stringify: misc.ini.stringify_square_then_curly
        target: "#{scratch}/user.ini"
        content: user: preference: language: ['c', 'c++', 'ada']
      , (err, written) ->
        written.should.be.true() unless err
      .file.assert
        target: "#{scratch}/user.ini"
        content: '[user]\n preference = {\n  language = c\n  language = c++\n  language = ada\n }\n\n'
      # Modify an existing file
      # TODO: merge is not supported
      .promise()
