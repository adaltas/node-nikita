
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
connect = require 'superexec/lib/connect'
misc = require '../lib/misc'

describe 'write', ->

  scratch = test.scratch @
  
  it 'should write a file', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      fs.readFile "#{scratch}/file", 'ascii', (err, content) ->
        content.should.eql 'Hello'
        next()
  
  it 'create a backup', (next) ->
    # First we create a file
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
      backup: true
    , (err, written) ->
      return next err if err
      # If nothing has change, there should be no backup
      mecano.write
        content: 'Hello'
        destination: "#{scratch}/file"
        backup: '.bck'
      , (err, written) ->
        return next err if err
        written.should.eql 0
        misc.file.exists null, "#{scratch}/file.bck", (err, exists) ->
          exists.should.be.false
          # If content is different, check the backup
          mecano.write
            content: 'Hello Node'
            destination: "#{scratch}/file"
            backup: '.bck'
          , (err, written) ->
            return next err if err
            fs.readFile "#{scratch}/file.bck", 'ascii', (err, content) ->
              content.should.eql 'Hello Node'
              next()
  
  it 'doesnt increment if destination is same than generated content', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      mecano.write
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        written.should.eql 0
        next()
  
  it 'doesnt increment if destination is same than generated content', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      mecano.write
        source: "#{scratch}/file"
        destination: "#{scratch}/file_copy"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        fs.readFile "#{scratch}/file", 'ascii', (err, content) ->
          content.should.eql 'Hello'
          next()
  
  it 'empty file', (next) ->
    mecano.write
      content: ''
      destination: "#{scratch}/empty_file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/empty_file", (err, content) ->
        return next err if err
        content.should.eql ''
        next()
  
  it 'empty file over ssh', (next) ->
    connect host: 'localhost', (err, ssh) ->
      mecano.write
        ssh: ssh
        content: ''
        destination: "#{scratch}/empty_file"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        misc.file.readFile ssh, "#{scratch}/empty_file", (err, content) ->
          return next err if err
          content.should.eql ''
          next()
  
  it 'with from and with to', (next) ->
    mecano.write
      from: '# from\n'
      to: '# to'
      content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
      replace: 'my friend\n'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/fromto.md", (err, content) ->
        return next err if err
        content.should.eql 'here we are\n# from\nmy friend\n# to\nyou coquin'
        next()
  
  it 'with from and without to', (next) ->
    mecano.write
      from: '# from\n'
      content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
      replace: 'my friend\n'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/fromto.md", (err, content) ->
        return next err if err
        content.should.eql 'here we are\n# from\nmy friend\n'
        next()
  
  it 'without from and with to', (next) ->
    mecano.write
      to: '# to'
      content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
      replace: 'my friend\n'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/fromto.md", (err, content) ->
        return next err if err
        content.should.eql 'my friend\n# to\nyou coquin'
        next()
  
  it 'with match as a string', (next) ->
    mecano.write
      match: 'lets try to replace that one'
      content: 'here we are\nlets try to replace that one\nyou coquin'
      replace: 'my friend'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/fromto.md", (err, content) ->
        return next err if err
        content.should.eql 'here we are\nmy friend\nyou coquin'
        next()
  
  it 'with match as a regular expression', (next) ->
    mecano.write
      match: /(.*try.*)/
      content: 'here we are\nlets try to replace that one\nyou coquin'
      replace: 'my friend'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/fromto.md", (err, content) ->
        return next err if err
        content.should.eql 'here we are\nmy friend\nyou coquin'
        next()
  
  it 'with match as a regular expression and multiple content', (next) ->
    mecano.write
      match: /(.*try) (.*)/
      content: 'here we are\nlets try to replace that one\nyou coquin'
      replace: ['my friend, $1']
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile null, "#{scratch}/fromto.md", (err, content) ->
        return next err if err
        content.should.eql 'here we are\nmy friend, lets try\nyou coquin'
        next()
  
  it 'will replace destination if source or content does not exists', (next) ->
    mecano.write
      content: 'This is\nsome content\nfor testing'
      destination: "#{scratch}/a_file"
    , (err, written) ->
      return next err if err
      mecano.write
        match: /(.*content)/
        replace: 'a text'
        destination: "#{scratch}/a_file"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        mecano.write
          match: /(.*content)/
          replace: 'a text'
          destination: "#{scratch}/a_file"
        , (err, written) ->
          return next err if err
          written.should.eql 0
          misc.file.readFile null, "#{scratch}/a_file", (err, content) ->
            return next err if err
            content.should.eql 'This is\na text\nfor testing'
            next()
  
  it 'over ssh', (next) ->
    connect host: 'localhost', (err, ssh) ->
      mecano.write
        ssh: ssh
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        misc.file.exists ssh, "#{scratch}/file", (err, exists) ->
          exists.should.be.ok
          next()
  
  it 'detect file changes', (next) ->
    connect host: 'localhost', (err, ssh) ->
      mecano.write
        ssh: ssh
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        mecano.write
          ssh: ssh
          content: 'Hello'
          destination: "#{scratch}/file"
        , (err, written) ->
          return next err if err
          written.should.eql 0
          next()

  it 'can not defined source and content', (next) ->
    mecano.write
      source: 'abc'
      content: 'abc'
      destination: 'abc'
    , (err) ->
      err.message.should.eql 'Define either source or content'
      next()

  it 'append content', (next) ->
    # File does not exists, it create one
    mecano.write
      content: 'hello'
      destination: "#{scratch}/file"
      append: true
    , (err) ->
      return next err if err
      # File exists, it append to it
      mecano.write
        content: 'world'
        destination: "#{scratch}/file"
        append: true
      , (err) ->
        return next err if err
        # Check file content
        misc.file.readFile null, "#{scratch}/file", (err, content) ->
          return next err if err
          content.should.eql 'helloworld'
          next()


