
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.ini', ->

  they 'stringify an object', ({ssh}) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor = rouge\n'
    .promise()

  they 'merge an object', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: 'violet'
      target: "#{scratch}/user.ini"
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = violet\n'
    .promise()

  they 'discard undefined and null', ({ssh}) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'violet', age: undefined, gender: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor = violet\n'
    .promise()

  they 'remove null within merge', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .promise()

  they 'disregard undefined within merge', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: undefined
      target: "#{scratch}/user.ini"
      merge: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'use default source file', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: false
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = node\n'
    .promise()

  they 'options source file + content', ({ssh}) ->
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
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = node\nremember = me\n'
    .promise()

  they 'options missing source file + content', ({ssh}) ->
    nikita
      ssh: ssh
    .file.ini
      source: "#{scratch}/does_not_exist.ini"
      target: "#{scratch}/test.ini"
      content: user: preference: remember: 'me'
      merge: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nremember = me\n'
    .promise()

  they 'options source file + merge', ({ssh}) ->
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
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      merge: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = node\n'
    .promise()

  they 'use default source file with merge and content', ({ssh}) ->
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
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[user.preference]\nlanguage = c++\n'
    .file.ini
      source: "#{scratch}/user.ini"
      target: "#{scratch}/test.ini"
      content: user: preference: language: 'c++'
      merge: true
    , (err, status) ->
      {status}.sh
    .promise()

  they 'generate from content object with escape', ({ssh}) ->
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
    , (err, {status}) ->
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
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  they 'content encode string true correctly', ({ssh}) ->
    nikita
      ssh: ssh
    .file.ini
      target: "#{scratch}/test.ini"
      merge: true
      content: color: ui: 'true'
    .file.assert
      target: "#{scratch}/test.ini"
      content: '[color]\nui = true\n'
    .promise()
