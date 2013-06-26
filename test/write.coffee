
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
they = require 'superexec/lib/they'
misc = require '../lib/misc'

describe 'write', ->

  scratch = test.scratch @
  
  they 'should write a file', (ssh, next) ->
    # Write the content
    mecano.write
      ssh: ssh
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      # File has been created
      written.should.eql 1
      # Write the same content
      mecano.write
        ssh: ssh
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        # Content has change
        written.should.eql 0
        misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          content.should.eql 'Hello'
          next()
  
  they 'doesnt increment if destination is same than generated content', (ssh, next) ->
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
  
  they 'doesnt increment if destination is same than generated content', (ssh, next) ->
    mecano.write
      ssh: ssh
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      mecano.write
        ssh: ssh
        source: "#{scratch}/file"
        destination: "#{scratch}/file_copy"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          content.should.eql 'Hello'
          next()
  
  they 'empty file', (ssh, next) ->
    mecano.write
      ssh: ssh
      content: ''
      destination: "#{scratch}/empty_file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
        return next err if err
        content.should.eql ''
        next()
  
  they 'create parent directory', (ssh, next) ->
    mecano.write
      ssh: ssh
      content: 'hello'
      destination: "#{scratch}/a/missing/dir/a_file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/a/missing/dir/a_file", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'hello'
        next()
  
  they 'with from and with to', (ssh, next) ->
    mecano.write
      ssh: ssh
      from: '# from\n'
      to: '# to'
      content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
      replace: 'my friend\n'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'here we are\n# from\nmy friend\n# to\nyou coquin'
        next()
  
  they 'with from and without to', (ssh, next) ->
    mecano.write
      ssh: ssh
      from: '# from\n'
      content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
      replace: 'my friend\n'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'here we are\n# from\nmy friend\n'
        next()
  
  they 'without from and with to', (ssh, next) ->
    mecano.write
      ssh: ssh
      to: '# to'
      content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
      replace: 'my friend\n'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'my friend\n# to\nyou coquin'
        next()
  
  they 'with match as a string', (ssh, next) ->
    mecano.write
      ssh: ssh
      match: 'lets try to replace that one'
      content: 'here we are\nlets try to replace that one\nyou coquin'
      replace: 'my friend'
      destination: "#{scratch}/fromto.md"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'here we are\nmy friend\nyou coquin'
        next()
  
  they 'with match as a regular expression', (ssh, next) ->
    mecano.write
      ssh: ssh
      content: 'email=david(at)adaltas(dot)com\nusername=root'
      match: /(username)=(.*)/
      replace: '$1=david (was $2)'
      destination: "#{scratch}/replace"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'email=david(at)adaltas(dot)com\nusername=david (was root)'
        next()
  
  they 'with match as a regular expression and multiple content', (ssh, next) ->
    mecano.write
      ssh: ssh
      match: /(.*try) (.*)/
      content: 'here we are\nlets try to replace that one\nyou coquin'
      replace: ['my friend, $1']
      destination: "#{scratch}/replace"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'here we are\nmy friend, lets try\nyou coquin'
        next()
  
  they 'with match with global and multilines', (ssh, next) ->
    mecano.write
      ssh: ssh
      match: /^property=.*$/mg
      content: '#A config file\n#property=30\nproperty=10\nproperty=20\n#End of Config'
      replace: 'property=50'
      destination: "#{scratch}/replace"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
        return next err if err
        content.should.eql '#A config file\n#property=30\nproperty=50\nproperty=50\n#End of Config'
        next()
  
  they 'will replace destination if source or content does not exists', (ssh, next) ->
    mecano.write
      ssh: ssh
      content: 'This is\nsome content\nfor testing'
      destination: "#{scratch}/a_file"
    , (err, written) ->
      return next err if err
      mecano.write
        ssh: ssh
        match: /(.*content)/
        replace: 'a text'
        destination: "#{scratch}/a_file"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        mecano.write
          ssh: ssh
          match: /(.*content)/
          replace: 'a text'
          destination: "#{scratch}/a_file"
        , (err, written) ->
          return next err if err
          written.should.eql 0
          misc.file.readFile ssh, "#{scratch}/a_file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'This is\na text\nfor testing'
            next()

  they 'can not defined source and content', (ssh, next) ->
    mecano.write
      ssh: ssh
      source: 'abc'
      content: 'abc'
      destination: 'abc'
    , (err) ->
      err.message.should.eql 'Define either source or content'
      next()

  describe 'append', ->

    they 'append content to existing file', (ssh, next) ->
      # File does not exists, it create one
      mecano.write
        ssh: ssh
        content: 'hello'
        destination: "#{scratch}/file"
        append: true
      , (err) ->
        return next err if err
        # File exists, it append to it
        mecano.write
          ssh: ssh
          content: 'world'
          destination: "#{scratch}/file"
          append: true
        , (err) ->
          return next err if err
          # Check file content
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'helloworld'
            next()

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.write
        ssh: ssh
        content: 'world'
        destination: "#{scratch}/file"
        append: true
      , (err) ->
        return next err if err
        # Check file content
        misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'world'
          next()

  describe 'match & append', ->

    they 'will not append if match', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        content: 'here we are\nyou coquin\n'
        destination: "#{scratch}/file"
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          match: /.*coquin/
          replace: 'new coquin'
          append: true
        , (err, written) ->
          return next err if err
          written.should.eql 1
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nnew coquin\n'
            # Write a second time with same match
            mecano.write
              ssh: ssh
              match: /.*coquin/
              destination: "#{scratch}/file"
              replace: 'new coquin'
              append: true
            , (err, written) ->
              return next err if err
              written.should.eql 0
              # Check file content
              misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
                return next err if err
                content.should.eql 'here we are\nnew coquin\n'
                next()

    they 'will append if no match', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        content: 'here we are\nyou coquin\n'
        destination: "#{scratch}/file"
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          match: /will never work/
          destination: "#{scratch}/file"
          replace: 'Add this line'
          append: true
        , (err, written) ->
          return next err if err
          written.should.eql 1
          # Check file content
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nyou coquin\nAdd this line'
            next()

    they 'append after a match if append is a regexp', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        content: 'here we are\nyou coquin\nshould we\nhave fun'
        destination: "#{scratch}/file"
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          match: /will never work/
          destination: "#{scratch}/file"
          replace: 'Add this line'
          append: /^.*we.*$/m
        , (err, written) ->
          return next err if err
          written.should.eql 1
          # Check file content
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nhave fun'
            next()

    they 'append multiple times after match if append is regexp with global flag', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        content: 'here we are\nyou coquin\nshould we\nhave fun'
        destination: "#{scratch}/file"
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          match: /will never work/
          destination: "#{scratch}/file"
          replace: 'Add this line'
          append: /^.*we.*$/gm
        , (err, written) ->
          return next err if err
          written.should.eql 1
          # Check file content
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
            next()


    they 'will append after a match if append is a string', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        content: 'here we are\nyou coquin\nshould we\nhave fun'
        destination: "#{scratch}/file"
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          match: /will never work/
          destination: "#{scratch}/file"
          replace: 'Add this line'
          append: 'we'
        , (err, written) ->
          return next err if err
          written.should.eql 1
          # Check file content
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
            next()

    they 'will detect new line if no match', (ssh, next) ->
      # Create file for the test
      mecano.write
        ssh: ssh
        content: 'here we are\nyou coquin'
        destination: "#{scratch}/file"
      , (err) ->
        # File exist, append replace string to it and detect missing line break
        mecano.write
          ssh: ssh
          match: /will never be found/
          destination: "#{scratch}/file"
          replace: 'Add this line'
          append: true
        , (err, written) ->
          return next err if err
          written.should.eql 1
          # Check file content
          misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nyou coquin\nAdd this line'
            next()

    they 'create file if not exists', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.write
        ssh: ssh
        match: /will never be found/
        destination: "#{scratch}/file"
        replace: 'Add this line'
        append: true
      , (err, written) ->
        return next err if err
        written.should.eql 1
        # Check file content
        misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'Add this line'
          next()

  describe 'backup', ->
  
    they 'create a file', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        # If nothing has change, there should be no backup
        mecano.write
          ssh: ssh
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
              ssh: ssh
              content: 'Hello Node'
              destination: "#{scratch}/file"
              backup: '.bck'
            , (err, written) ->
              return next err if err
              misc.file.readFile ssh, "#{scratch}/file.bck", 'utf8', (err, content) ->
                content.should.eql 'Hello Node'
                next()

  describe 'write', ->
  
    they 'do multiple replace', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        content: 'username: me\nemail: my@email\nfriends: you'
        destination: "#{scratch}/file"
        # First we create a file
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          write: [
            match: /^(username).*$/m
            replace: "$1: you"
          ,
            match: /^email.*$/m
            replace: ""
          ,
            match: /^(friends).*$/m
            replace: "$1: me"
          ]
          destination: "#{scratch}/file"
        , (err, written) ->
            return next err if err
            written.should.eql 1
            misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: you\n\nfriends: me'
              next()
  
    they 'use append', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        content: 'username: me\nfriends: you'
        destination: "#{scratch}/file"
        # First we create a file
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          write: [
            match: /^(username).*$/m
            replace: "$1: you"
          ,
            match: /^email.*$/m
            replace: "email: your@email"
            append: 'username'
          ,
            match: /^(friends).*$/m
            replace: "$1: me"
          ]
          destination: "#{scratch}/file"
        , (err, written) ->
            return next err if err
            written.should.eql 1
            misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: you\nemail: your@email\nfriends: me'
              next()
  
    they 'handle partial match', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        content: 'username: me\nfriends: none'
        destination: "#{scratch}/file"
        # First we create a file
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          write: [
            match: /^will never match$/m
            replace: "useless"
          ,
            match: /^email.*$/m
            replace: "email: my@email"
            append: 'username'
          ,
            match: /^(friends).*$/m
            replace: "$1: you"
          ]
          destination: "#{scratch}/file"
        , (err, written) ->
            return next err if err
            written.should.eql 1
            misc.file.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: me\nemail: my@email\nfriends: you'
              next()


