
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'file', ->

  scratch = test.scratch @

  describe 'options content', ->
  
    they 'is a string', (ssh) ->
      nikita
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
      .promise()
  
    they 'is a function', (ssh) ->
      content = 'invalid'
      nikita
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
      .promise()

    they 'status is false is content is the same', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, status) ->
        status.should.be.false() unless err
      .promise()

    they 'with source is a file', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_source"
        content: 'Hello'
      .file
        target: "#{scratch}/a_target"
        source: "#{scratch}/a_source"
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/a_target"
        source: "#{scratch}/a_source"
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/a_source"
        content: 'Hello'
      .file.assert
        target: "#{scratch}/a_target"
        content: 'Hello'
      .promise()

    they 'empty file', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/empty_file"
        content: ''
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/empty_file"
        content: ''
      .promise()

    they 'touch file', (ssh) ->
      nikita
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
      .promise()

    they 'handle integer type', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 123
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_file"
        content: '123'
      .promise()

    they 'create parent directory', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a/missing/dir/a_file"
        content: 'hello'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a/missing/dir/a_file"
        content: 'hello'
      .promise()

  describe 'link', ->

    they 'follow link by default', (ssh) ->
      nikita
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
      .promise()

    they 'throw error if link is a directory', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/target"
      .system.link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
        relax: true
      , (err) ->
        err.code.should.eql 'EISDIR'
      .promise()

    they 'dont follow link if option "unlink"', (ssh) ->
      nikita
        ssh: ssh
      .file
        content: 'ko'
        target: "#{scratch}/a_target"
      .system.link
        source: "#{scratch}/a_target"
        target: "#{scratch}/a_link"
      .file
        content: 'ok'
        target: "#{scratch}/a_link"
        unlink: true
      .file.assert
        target: "#{scratch}/a_target"
        content: 'ko'
      .file.assert
        target: "#{scratch}/a_link"
        content: 'ok'
      .promise()

    they 'dont follow link if option "unlink" and link is directory', (ssh) ->
      nikita
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
      .file.assert
        target: "#{scratch}/link"
        content: 'ok'
        filetype: 'file'
      .file.assert
        target: "#{scratch}/target"
        filetype: 'directory'
      .promise()

  describe 'ownerships and permissions', ->

    they 'set permission', (ssh) ->
      nikita.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0700
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0700
      .file.assert
        target: "#{scratch}"
        mode: [0o0755, 0o0775]
      .promise()

    they 'change permission', (ssh) ->
      nikita
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
      .promise()

    they 'change permission after modification', (ssh) ->
      nikita
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
      .file.assert
        target: "#{scratch}/a_file"
        mode: 0o0755
      .promise()

  describe 'from and to', ->
  
    they 'with from and with to', (ssh) ->
      nikita.file
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
      .promise()

    they 'with from and with to append', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou coquin'
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
      .promise()

    they 'with from and without to', (ssh) ->
      nikita
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
      .promise()

    they 'without from and with to', (ssh) ->
      nikita.file
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
      .promise()

  describe 'replace', ->
  
    they 'without match and place_before a string', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou+coquin'
        replace: 'my friend'
        place_before: 'you+coquin' # Regexp must escape the plus sign
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\nmy friend\nyou+coquin'
      .promise()
  
    they 'without match and place_before a regexp', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou coquin'
        replace: 'my friend'
        place_before: /^you coquin$/m
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\nmy friend\nyou coquin'
      .promise()

  describe 'match & replace', ->
  
    they 'with match a line as a string', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/fromto.md"
        match: 'lets try to replace that one'
        content: 'here we are\nlets try to replace that one\nyou coquin'
        replace: 'my friend'
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/fromto.md"
        match: 'my friend'
        replace: 'my friend'
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/fromto.md"
        content: 'here we are\nmy friend\nyou coquin'
      .promise()
  
    they 'with match a word as a string', (ssh) ->
      nikita
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
      .promise()
  
    they 'with match as a regular expression', (ssh) ->
      # With a match
      nikita
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
      .promise()

    they 'with match as a regular expression and multiple content', (ssh) ->
      nikita
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
      .promise()

    they 'with match with global and multilines', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/replace"
        match: /^property=.*$/mg
        content: '#A config file\n#property=30\nproperty=10\nproperty=20\n#End of Config'
        replace: 'property=50'
      , (err, status) ->
        status.should.be.true() unless err
      .file
        target: "#{scratch}/replace"
        match: /^property=50$/mg
        replace: 'property=50'
      , (err, status) ->
        status.should.be.false() unless err
      .file.assert
        target: "#{scratch}/replace"
        content: '#A config file\n#property=30\nproperty=50\nproperty=50\n#End of Config'
      .promise()

    they 'will replace target if source or content does not exists', (ssh) ->
      nikita
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
      .promise()

  describe 'place_before', ->

    they 'append content to missing file', (ssh) ->
      # File does not exist, it create it with the content
      nikita.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'hello'
        append: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'hello'
      .promise()

    they 'is true, prepend the content', (ssh) ->
      # File doesnt exists, creates one
      nikita
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
      .promise()

  describe 'append', ->

    they 'append content to missing file', (ssh) ->
      # File does not exist, it create it with the content
      nikita.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 'hello'
        append: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'hello'
      .promise()

    they 'append content to existing file', (ssh) ->
      # File does not exists, it create one
      nikita
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
      .promise()

  describe 'match & append or place_before', ->

    describe 'will not prepend/append if match', ->

      they 'place_before true, replace a string, match a regexp', (ssh) ->
        # Prepare by creating a file with content
        nikita
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
        .promise()

      they 'place_before true, replace a string, match a string', (ssh) ->
        nikita
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
        .promise()

      they 'place_after', (ssh) ->
        # Prepare by creating a file with content
        nikita
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
        .promise()

    they 'will append if no match', (ssh) ->
      # Prepare by creating a file with content
      nikita
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
      .promise()

    describe 'place_before/place_after a match if it is a regexp', ->

      they 'place_before', (ssh) ->
        # Prepare by creating a file with content
        nikita
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
        .promise()

      they 'place_after', (ssh) ->
        # Prepare by creating a file with content
        nikita
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
        .promise()

    describe 'place_before/place_after multiple times if regexp with global flag', ->

      they 'place_before', (ssh) ->
        nikita
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
        .promise()

      they 'place_after', (ssh) ->
        # Prepare by creating a file with content
        nikita
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
        .promise()

    they 'will append place_after a match if append is a string', (ssh) ->
      nikita
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
      .promise()

    describe 'will detect new line if no match', ->

      they 'place_before', (ssh) ->
        nikita
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
        .promise()

      they 'place_after', (ssh) ->
        nikita
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
        .promise()

    describe 'create file if not exists', ->

      they 'place_before', (ssh) ->
        nikita
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
        .promise()

      they 'place_after', (ssh) ->
        nikita
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
        .promise()

    they 'match is optional', (ssh) ->
      nikita
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
      .promise()

  describe 'backup', ->
  
    they 'create a file', (ssh) ->
      # First we create a file
      nikita
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
      .file.assert
        target: "#{scratch}/file.bck"
        not: true
      .file
        target: "#{scratch}/file"
        content: 'Hello Node'
        backup: '.bck'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/file.bck"
        content: 'Hello'
      .promise()
  
    they 'a non-existing file', (ssh) ->
      nikita.file
        ssh: ssh
        target: "#{scratch}/new_file"
        content: 'Hello'
        backup: true
      , (err, status) ->
        status.should.be.true() unless err
      .promise()

    they 'with specific permissions', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/new_file_perm"
        content: 'Hello World'
      .file
        target: "#{scratch}/new_file_perm"
        content: 'Hello'
        mode: 0o0644
        backup: '.bck1'
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/new_file_perm.bck1"
        content: 'Hello World'
        mode: 0o0400
      .file
        target: "#{scratch}/new_file_perm"
        content: 'Hello World'
        backup: '.bck2'
        mode: 0o0644
        backup_mode: 0o0640
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/new_file_perm.bck2"
        content: 'Hello'
        mode: 0o0640
      .promise()

  describe 'write', ->
  
    they 'do multiple replace', (ssh) ->
      nikita
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
      .promise()
  
    they 'use append', (ssh) ->
      nikita
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
      .promise()
  
    they 'handle partial match', (ssh) ->
      # First we create a file
      nikita
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
      .promise()

  describe 'error', ->

    they 'can not define source and content', (ssh) ->
      nikita.file
        ssh: ssh
        target: 'abc'
        source: 'abc'
        content: 'abc'
        relax: true
      , (err) ->
        err.message.should.eql 'Define either source or content'
      .promise()

    they 'if source doesn\'t exists', (ssh) ->
      nikita.file
        ssh: ssh
        target: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
        relax: true
      , (err) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
      .promise()

    they 'if local source doesn\'t exists', (ssh) ->
      nikita.file
        ssh: ssh
        target: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
        local: true
        relax: true
      , (err) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
      .promise()

  describe 'eof', ->

    they 'auto-detected', (ssh) ->
      nikita
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
      .promise()

    they 'not detected', (ssh) ->
      nikita
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
      .promise()
