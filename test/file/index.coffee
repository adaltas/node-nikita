
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file', ->

  scratch = test.scratch @

  describe 'options content', ->
  
    they 'is a string', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'Hello'
      .then next
          
    they 'is a function', (ssh, next) ->
      content = 'invalid'
      mecano
        ssh: ssh
      .call ->
        content = 'valid'
      .file
        target: "#{scratch}/file"
        trigger: true
        content: (options) -> content if options.trigger
      .file.assert
        target: "#{scratch}/file"
        content: 'valid'
      .then next
    
    they 'doesnt increment if target is same than generated content', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, status) ->
        status.should.be.false() unless err
      .then next
    
    they 'doesnt increment if target is same than generated content', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      .file
        target: "#{scratch}/file_copy"
        source: "#{scratch}/file"
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'Hello'
      .then next
    
    they 'empty file', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/empty_file"
        content: ''
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/empty_file"
        content: ''
      .then next

    they 'touch file', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/empty_file"
        content: ''
        unless_exists: true
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/empty_file"
        content: ''
      .file
        target: "#{scratch}/empty_file"
        content: 'toto'
      .file
        target: "#{scratch}/empty_file"
        content: ''
        unless_exists: true
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/empty_file"
        content: 'toto'
      .then next

    they 'handle integer type', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 123
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_file"
        content: '123'
      .then next
    
    they 'create parent directory', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a/missing/dir/a_file"
        content: 'hello'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a/missing/dir/a_file"
        content: 'hello'
      .then next

  describe 'link', ->

    they 'follow link by default', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'ko'
        target: "#{scratch}/target"
      .system.link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
      .file.assert
        target: "#{scratch}/target"
        content: 'ok'
      .file.assert
        target: "#{scratch}/link"
        content: 'ok'
      .then next

    they 'throw error if link is a directory', (ssh, next) ->
      mecano
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/target"
      .system.link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
      , (err) ->
        err.code.should.eql 'EISDIR'
        next()

    they 'dont follow link if option "unlink"', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'ko'
        target: "#{scratch}/target"
      .system.link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
        unlink: true
      .file.assert
        target: "#{scratch}/target"
        content: 'ko'
      .file.assert
        target: "#{scratch}/link"
        content: 'ok'
      .then next

    they 'dont follow link if option "unlink" and link is directory', (ssh, next) ->
      mecano
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/target"
      .system.link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
        unlink: true
      .call (_, callback) ->
        fs.readFile ssh, "#{scratch}/link", 'ascii', (err, data) ->
          data.should.eql 'ok'
          fs.stat ssh, "#{scratch}/target",  (err, stat) ->
            stat.isDirectory().should.be.true()
            callback()
      .then next

  describe 'ownerships and permissions', ->

    they 'set permission', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0700
      , (err, status) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
          return next err if err
          misc.mode.compare(stat.mode, 0o0700).should.True
          fs.stat ssh, "#{scratch}", (err, stat) ->
            return next err if err
            misc.mode.compare(stat.mode, 0o0700).should.be.false()
            next()

    they 'change permission', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0700
      .file
        target: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0705
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0705
      , (err, status) ->
        status.should.be.false() unless err
      .then next

    they 'change permission after modification', (ssh, next) ->
      mecano
      .file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'Hello'
        mode: 0o0700
      .file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'World'
        mode: 0o0755
      , (err, status) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
          return next err if err
          misc.mode.compare(stat.mode, 0o0755).should.be.true()
          next()

  describe 'from and to', ->
  
    they 'with from and with to', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        from: '# from'
        to: '# to'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\n# from\nmy friend\n# to\nyou coquin'
      .then next
  
    they 'with from and with to append', (ssh, next) ->
      fs.writeFile ssh, "#{scratch}/fromto.md", 'here we are\nyou coquin', (err) ->
        return next err if err
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/fromto.md"
          from: '# from'
          to: '# to'
          append: true
          replace: 'my friend'
        , (err, status) ->
          status.should.be.true()
        .file.assert
          target: "#{scratch}/fromto.md"
          content: 'here we are\nyou coquin\n# from\nmy friend\n# to'
        .file
          target: "#{scratch}/fromto.md"
          from: '# from'
          to: '# to'
          append: true
          replace: 'my best friend'
          eof: true
        , (err, status) ->
          status.should.be.true()
        .file.assert
          target: "#{scratch}/fromto.md"
          content: 'here we are\nyou coquin\n# from\nmy best friend\n# to\n'
        .then next
    
    they 'with from and without to', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        from: '# from'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\n# from\nmy friend'
      .then next
    
    they 'without from and with to', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        to: '# to'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'my friend\n# to\nyou coquin'
      .then next

  describe 'replace', ->
  
    they 'without match and place_before a string', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou+coquin'
        replace: 'my friend'
        place_before: 'you+coquin' # Regexp must escape the plus sign
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\nmy friend\nyou+coquin'
      .then next
  
    they 'without match and place_before a regexp', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou coquin'
        replace: 'my friend'
        place_before: /^you coquin$/m
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\nmy friend\nyou coquin'
      .then next

  describe 'match & replace', ->
  
    they 'with match a line as a string', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        match: 'lets try to replace that one'
        content: 'here we are\nlets try to replace that one\nyou coquin'
        replace: 'my friend'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\nmy friend\nyou coquin'
      .then next
  
    they 'with match a word as a string', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        match: 'replace'
        content: 'replace that one\nand\nreplace this one\nand not this one'
        replace: 'switch'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'switch that one\nand\nswitch this one\nand not this one'
      .then next
  
    they 'with match as a regular expression', (ssh, next) ->
      # With a match
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/replace"
        content: 'email=david(at)adaltas(dot)com\nusername=root'
        match: /(username)=(.*)/
        replace: '$1=david (was $2)'
      , (err, status) ->
        status.should.be.true() unless err
      .file # Without a match
        target: "#{scratch}/replace"
        match: /this wont work/
        replace: '$1=david (was $2)'
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/replace"
        content: 'email=david(at)adaltas(dot)com\nusername=david (was root)'
      .then next
    
    they 'with match as a regular expression and multiple content', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        match: /(.*try) (.*)/
        content: 'here we are\nlets try to replace that one\nyou coquin'
        replace: ['my friend, $1']
        target: "#{scratch}/replace"
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/replace"
        content: 'here we are\nmy friend, lets try\nyou coquin'
      .then next
    
    they 'with match with global and multilines', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/replace"
        match: /^property=.*$/mg
        content: '#A config file\n#property=30\nproperty=10\nproperty=20\n#End of Config'
        replace: 'property=50'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/replace"
        content: '#A config file\n#property=30\nproperty=50\nproperty=50\n#End of Config'
      .then next
    
    they 'will replace target if source or content does not exists', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'This is\nsome content\nfor testing'
      .file
        target: "#{scratch}/a_file"
        match: /(.*content)/
        replace: 'a text'
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/a_file"
        match: /(.*content)/
        replace: 'a text'
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/a_file"
        content: 'This is\na text\nfor testing'
      .then next

  describe 'place_before', ->

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'hello'
        append: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'hello'
      .then next

    they 'is true, prepend the content', (ssh, next) ->
      # File doesnt exists, creates one
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'world'
        place_before: true
      .file # File exists, prepends to it
        target: "#{scratch}/a_file"
        replace: 'hello'
        place_before: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'hello\nworld'
      .then next

  describe 'append', ->

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'hello'
        append: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'hello'
      .then next

    they 'append content to existing file', (ssh, next) ->
      # File does not exists, it create one
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'hello'
        append: true
      .file # File exists, it append to it
        target: "#{scratch}/a_file"
        content: 'world'
        append: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'helloworld'
      .then next

  describe 'match & append or place_before', ->

    describe 'will not prepend/append if match', ->

      they 'place_before true, replace a string, match a regexp', (ssh, next) ->
        # Prepare by creating a file with content
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'you coquin\nhere we are\n'
        .file
          target: "#{scratch}/file"
          match: /.*coquin/
          replace: 'new coquin'
          place_before: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'new coquin\nhere we are\n'
        # Write a second time with same match
        .file
          target: "#{scratch}/file"
          match: /.*coquin/
          replace: 'new coquin'
          place_before: true
        , (err, status) ->
          status.should.be.false() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'new coquin\nhere we are\n'
        .then next

      they 'place_before true, replace a string, match a string', (ssh, next) ->
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'you coquin\nhere we are\n'
        .file
          target: "#{scratch}/file"
          match: "you coquin"
          replace: 'new coquin'
          place_before: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'new coquin\nhere we are\n'
        # Write a second time with same match
        .file
          target: "#{scratch}/file"
          match: "new coquin"
          replace: 'new coquin'
          place_before: true
        , (err, status) ->
          status.should.be.false() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'new coquin\nhere we are\n'
        .then next

      they 'place_after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\n'
        .file
          target: "#{scratch}/file"
          match: /.*coquin/
          replace: 'new coquin'
          append: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'here we are\nnew coquin\n'
        # Write a second time with same match
        .file
          target: "#{scratch}/file"
          match: /.*coquin/
          replace: 'new coquin'
          append: true
        , (err, status) ->
          status.should.be.false() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'here we are\nnew coquin\n'
        .then next

    they 'will append if no match', (ssh, next) ->
      # Prepare by creating a file with content
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'here we are\nyou coquin\n'
      .file
        target: "#{scratch}/file"
        match: /will never work/
        replace: 'Add this line'
        append: true
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'here we are\nyou coquin\nAdd this line'
      .then next

    describe 'place_before/place_after a match if it is a regexp', ->

      they 'place_before', (ssh, next) ->
        # Prepare by creating a file with content
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        .file
          target: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          place_before: /^.*we.*$/m
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'Add this line\nhere we are\nyou coquin\nshould we\nhave fun'
        .then next

      they 'place_after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        .file
          target: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          append: /^.*we.*$/m
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'here we are\nAdd this line\nyou coquin\nshould we\nhave fun'
        .then next

    describe 'place_before/place_after multiple times if regexp with global flag', ->

      they 'place_before', (ssh, next) ->
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        .file
          target: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          place_before: /^.*we.*$/gm
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'Add this line\nhere we are\nyou coquin\nAdd this line\nshould we\nhave fun'
        .then next

      they 'place_after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        .file
          target: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          append: /^.*we.*$/gm
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
        .then next


    they 'will append place_after a match if append is a string', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'here we are\nyou coquin\nshould we\nhave fun'
      .file
        target: "#{scratch}/file"
        match: /will never work/
        replace: 'Add this line'
        append: 'we'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
      .then next

    describe 'will detect new line if no match', ->

      they 'place_before', (ssh, next) ->
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin'
        .file
          target: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          place_before: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'Add this line\nhere we are\nyou coquin'
        .then next

      they 'place_after', (ssh, next) ->
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin'
        .file
          target: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          append: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nAdd this line'
        .then next

    describe 'create file if not exists', ->

      they 'place_before', (ssh, next) ->
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          place_before: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'Add this line'
        .then next

      they 'place_after', (ssh, next) ->
        mecano
          ssh: ssh
        .file
          target: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          append: true
        , (err, status) ->
          status.should.be.true() unless err
        .file.assert
          target: "#{scratch}/file"
          content: 'Add this line'
        .then next
    
    they 'match is optional', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'Here we are\nyou coquin'
      .file
        target: "#{scratch}/a_file"
        replace: 'Add this line'
        append: true
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/a_file"
        replace: 'Add this line'
        append: true
      , (err, status) ->
        status.should.be.false() unless err
      .file
        target: "#{scratch}/a_file"
        write: [
          replace: 'Add this line'
          append: true
        ]
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/a_file"
        content: 'Here we are\nyou coquin\nAdd this line'
      .then next

  describe 'backup', ->
  
    they 'create a file', (ssh, next) ->
      # First we create a file
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      .file
        target: "#{scratch}/file"
        content: 'Hello'
        backup: '.bck'
      , (err, status) ->
        status.should.be.false() unless err
      .call (_, callback) ->
        fs.exists ssh, "#{scratch}/file.bck", (err, exists) ->
          exists.should.be.false() unless err
          callback err
      .file
        target: "#{scratch}/file"
        content: 'Hello Node'
        backup: '.bck'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file.bck"
        content: 'Hello'
      .then next
  
    they 'a non-existing file', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/new_file"
        content: 'Hello'
        backup: true
      , (err, status) ->
        status.should.be.true() unless err
      .then next

  describe 'write', ->
  
    they 'do multiple replace', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'username: me\nemail: my@email\nfriends: you'
      .file
        target: "#{scratch}/file"
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
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'username: you\n\nfriends: me'
      .then next
  
    they 'use append', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'username: me\nfriends: you'
      .file
        target: "#{scratch}/file"
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
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'username: you\nemail: your@email\nfriends: me'
      .then next
  
    they 'handle partial match', (ssh, next) ->
      # First we create a file
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'username: me\nfriends: none'
      .file
        target: "#{scratch}/file"
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
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'username: me\nemail: my@email\nfriends: you'
      .then next

  describe 'error', ->

    they 'can not define source and content', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: 'abc'
        source: 'abc'
        content: 'abc'
      , (err) ->
        err.message.should.eql 'Define either source or content'
        next()

    they 'if source doesn\'t exists', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
      , (err) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
        next()

    they 'if local source doesn\'t exists', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
        local: true
      , (err) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
        next()

  describe 'eof', ->

    they 'auto-detected', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'this is\r\nsome content'
        eof: true
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'this is\r\nsome content\r\n'
      .then next

    they 'not detected', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'this is some content'
        eof: true
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file"
        content: 'this is some content\n'
      .then next
