
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.types.locale_gen', ->

  scratch = test.scratch @

  they 'activate locales', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/locale.gen"
      content: """
      #  en_US.UTF-8 UTF-8
      #en_US.UTF-8 UTF-8
      #en_US ISO-8859-1
      #fr_FR.UTF-8 UTF-8
      #fr_FR ISO-8859-1
      #es_ES.UTF-8 UTF-8
      """
    .file.types.locale_gen
      target: "#{scratch}/etc/locale.gen"
      locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
      locale: ['en_US.UTF-8']
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/etc/locale.gen"
      content: """
      #  en_US.UTF-8 UTF-8
      en_US.UTF-8 UTF-8
      #en_US ISO-8859-1
      fr_FR.UTF-8 UTF-8
      #fr_FR ISO-8859-1
      #es_ES.UTF-8 UTF-8
      """
    .promise()

  they 'desactivate locales', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/locale.gen"
      content: """
      #  en_US.UTF-8 UTF-8
      en_US.UTF-8 UTF-8
      en_US ISO-8859-1
      fr_FR.UTF-8 UTF-8
      fr_FR ISO-8859-1
      es_ES.UTF-8 UTF-8
      """
    .file.types.locale_gen
      target: "#{scratch}/etc/locale.gen"
      locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
      locale: ['en_US.UTF-8']
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/etc/locale.gen"
      content: """
      #  en_US.UTF-8 UTF-8
      en_US.UTF-8 UTF-8
      #en_US ISO-8859-1
      fr_FR.UTF-8 UTF-8
      #fr_FR ISO-8859-1
      #es_ES.UTF-8 UTF-8
      """
    .promise()

  they 'rootdir with default target', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/locale.gen"
      content: "#en_US.UTF-8 UTF-8"
    .file.types.locale_gen
      rootdir: "#{scratch}"
      locales: ['en_US.UTF-8']
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/etc/locale.gen"
      content: "en_US.UTF-8 UTF-8"
    .promise()
