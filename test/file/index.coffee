
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file', ->

  scratch = test.scratch @

  describe 'content', ->
  
    they 'write a string', (ssh, next) ->
      # Write the content
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        written.should.be.true()
      .file # Write the same content
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        return next err if err
        # Content has change
        written.should.be.false()
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          content.should.eql 'Hello'
          next()
    
    they 'doesnt increment if target is same than generated content', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        written.should.be.true()
      .file
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        written.should.be.false()
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
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          content.should.eql 'Hello'
          next()
    
    they 'empty file', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/empty_file"
        content: ''
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql ''
          next()

    they 'touch file', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/empty_file"
        content: ''
        unless_exists: true
      , (err, written) ->
        written.should.be.true()
      .call (options, next) ->
        fs.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql ''
          next()
      .file
        target: "#{scratch}/empty_file"
        content: 'toto'
      .file
        target: "#{scratch}/empty_file"
        content: ''
        unless_exists: true
      , (err, written) ->
        written.should.be.false()
      .call (options, next) ->
        fs.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'toto'
          next()
      .then next

    they 'handle integer type', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/a_file"
        content: 123
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/a_file", 'ascii', (err, content) ->
          return next err if err
          content.should.eql '123'
          next()
    
    they 'create parent directory', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/a/missing/dir/a_file"
        content: 'hello'
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/a/missing/dir/a_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()

  describe 'link', ->

    they 'follow link by default', (ssh, next) ->
      mecano
        ssh: ssh
      .file
        content: 'ko'
        target: "#{scratch}/target"
      .link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
      .call (_, callback) ->
        fs.readFile ssh, "#{scratch}/link", 'ascii', (err, data) ->
          data.should.eql 'ok'
          fs.readFile ssh, "#{scratch}/target", 'ascii', (err, data) ->
            data.should.eql 'ok'
            callback()
      .then next

    they 'throw error if link is a directory', (ssh, next) ->
      mecano
        ssh: ssh
      .mkdir
        target: "#{scratch}/target"
      .link
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
      .link
        source: "#{scratch}/target"
        target: "#{scratch}/link"
      .file
        content: 'ok'
        target: "#{scratch}/link"
        unlink: true
      .call (_, callback) ->
        fs.readFile ssh, "#{scratch}/link", 'ascii', (err, data) ->
          data.should.eql 'ok'
          fs.readFile ssh, "#{scratch}/target", 'ascii', (err, data) ->
            data.should.eql 'ko'
            callback()
      .then next

    they 'dont follow link if option "unlink" and link is directory', (ssh, next) ->
      mecano
        ssh: ssh
      .mkdir
        target: "#{scratch}/target"
      .link
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
      , (err, written) ->
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
      , (err, written) ->
        written.should.be.true()
      .file
        target: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0705
      , (err, written) ->
        written.should.be.false()
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
      , (err, written) ->
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
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\n# from\nmy friend\n# to\nyou coquin'
          next()
  
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
        , (err, written) ->
          written.should.be.true()
        .call (options, next) ->
          fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
            content.should.eql 'here we are\nyou coquin\n# from\nmy friend\n# to'
            next()
        .file
          target: "#{scratch}/fromto.md"
          from: '# from'
          to: '# to'
          append: true
          replace: 'my best friend'
          eof: true
        , (err, written) ->
          written.should.be.true()
        .call (options, next) ->
          fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
            content.should.eql 'here we are\nyou coquin\n# from\nmy best friend\n# to\n'
            next()
        .then next
    
    they 'with from and without to', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        from: '# from'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\n# from\nmy friend'
          next()
    
    they 'without from and with to', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        to: '# to'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'my friend\n# to\nyou coquin'
          next()


  describe 'replace', ->
  
    they 'without match and place_before a string', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou+coquin'
        replace: 'my friend'
        place_before: 'you+coquin' # Regexp must escape the plus sign
      , (err, written) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nmy friend\nyou+coquin'
          next()
  
    they 'without match and place_before a regexp', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        content: 'here we are\nyou coquin'
        replace: 'my friend'
        place_before: /^you coquin$/m
      , (err, written) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nmy friend\nyou coquin'
          next()

  describe 'match & replace', ->
  
    they 'with match a line as a string', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        match: 'lets try to replace that one'
        content: 'here we are\nlets try to replace that one\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nmy friend\nyou coquin'
          next()
  
    they 'with match a word as a string', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/fromto.md"
        match: 'replace'
        content: 'replace that one\nand\nreplace this one\nand not this one'
        replace: 'switch'
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'switch that one\nand\nswitch this one\nand not this one'
          next()
  
    they 'with match as a regular expression', (ssh, next) ->
      # With a match
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/replace"
        content: 'email=david(at)adaltas(dot)com\nusername=root'
        match: /(username)=(.*)/
        replace: '$1=david (was $2)'
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .file # Without a match
        target: "#{scratch}/replace"
        match: /this wont work/
        replace: '$1=david (was $2)'
      , (err, written) ->
        return next err if err
        written.should.be.false()
        fs.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'email=david(at)adaltas(dot)com\nusername=david (was root)'
          next()
    
    they 'with match as a regular expression and multiple content', (ssh, next) ->
      mecano.file
        ssh: ssh
        match: /(.*try) (.*)/
        content: 'here we are\nlets try to replace that one\nyou coquin'
        replace: ['my friend, $1']
        target: "#{scratch}/replace"
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nmy friend, lets try\nyou coquin'
          next()
    
    they 'with match with global and multilines', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/replace"
        match: /^property=.*$/mg
        content: '#A config file\n#property=30\nproperty=10\nproperty=20\n#End of Config'
        replace: 'property=50'
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
          return next err if err
          content.should.eql '#A config file\n#property=30\nproperty=50\nproperty=50\n#End of Config'
          next()
    
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
      , (err, written) ->
        written.should.be.true()
      .file
        target: "#{scratch}/a_file"
        match: /(.*content)/
        replace: 'a text'
      , (err, written) ->
        written.should.be.false()
      .then (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/a_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'This is\na text\nfor testing'
          next()

  describe 'place_before', ->

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'hello'
        append: true
      , (err) ->
        return next err if err
        # Check file content
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()

    they 'is true, prepend the content', (ssh, next) ->
      # File doesnt exists, creates one
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'world'
        place_before: true
      .file # File exists, prepends to it
        target: "#{scratch}/file"
        replace: 'hello'
        place_before: true
      .then (err) ->
        return next err if err
        # Check file content
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'hello\nworld'
          next()

  describe 'append', ->

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'hello'
        append: true
      , (err) ->
        return next err if err
        # Check file content
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()

    they 'append content to existing file', (ssh, next) ->
      # File does not exists, it create one
      mecano
        ssh: ssh
      .file
        target: "#{scratch}/file"
        content: 'hello'
        append: true
      .file # File exists, it append to it
        target: "#{scratch}/file"
        content: 'world'
        append: true
      .then (err) ->
        return next err if err
        # Check file content
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'helloworld'
          next()

  describe 'match & append or place_before', ->

    describe 'will not prepend/append if match', ->

      they 'place_before true, replace a string, match a regexp', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'you coquin\nhere we are\n'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /.*coquin/
            replace: 'new coquin'
            place_before: true
          , (err, written) ->
            return next err if err
            written.should.be.true()
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'new coquin\nhere we are\n'
              # Write a second time with same match
              mecano.file
                ssh: ssh
                target: "#{scratch}/file"
                match: /.*coquin/
                replace: 'new coquin'
                place_before: true
              , (err, written) ->
                return next err if err
                written.should.be.false()
                # Check file content
                fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
                  return next err if err
                  content.should.eql 'new coquin\nhere we are\n'
                  next()

      they 'place_before true, replace a string, match a string', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'you coquin\nhere we are\n'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: "you coquin"
            replace: 'new coquin'
            place_before: true
          , (err, written) ->
            return next err if err
            written.should.be.true()
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'new coquin\nhere we are\n'
              # Write a second time with same match
              mecano.file
                ssh: ssh
                target: "#{scratch}/file"
                match: "new coquin"
                replace: 'new coquin'
                place_before: true
              , (err, written) ->
                return next err if err
                written.should.be.false()
                # Check file content
                fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
                  return next err if err
                  content.should.eql 'new coquin\nhere we are\n'
                  next()

      they 'place_after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\n'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /.*coquin/
            replace: 'new coquin'
            append: true
          , (err, written) ->
            return next err if err
            written.should.be.true()
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nnew coquin\n'
              # Write a second time with same match
              mecano.file
                ssh: ssh
                target: "#{scratch}/file"
                match: /.*coquin/
                replace: 'new coquin'
                append: true
              , (err, written) ->
                return next err if err
                written.should.be.false()
                # Check file content
                fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
                  return next err if err
                  content.should.eql 'here we are\nnew coquin\n'
                  next()

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
      , (err, written) ->
        return next err if err
        written.should.be.true()
        # Check file content
        fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nyou coquin\nAdd this line'
          next()

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
        , (err, written) ->
          return next err if err
          written.should.be.true()
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'Add this line\nhere we are\nyou coquin\nshould we\nhave fun'
            next()

      they 'place_after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it creates it with the content
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            append: /^.*we.*$/m
          , (err, written) ->
            return next err if err
            written.should.be.true()
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nhave fun'
              next()

    describe 'place_before/place_after multiple times if regexp with global flag', ->

      they 'place_before', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            place_before: /^.*we.*$/gm
          , (err, written) ->
            return next err if err
            written.should.be.true()
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'Add this line\nhere we are\nyou coquin\nAdd this line\nshould we\nhave fun'
              next()

      they 'place_after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            append: /^.*we.*$/gm
          , (err, written) ->
            return next err if err
            written.should.be.true()
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
              next()


    they 'will append place_after a match if append is a string', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'here we are\nyou coquin\nshould we\nhave fun'
      , (err) ->
        # File does not exist, it create it with the content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          append: 'we'
        , (err, written) ->
          return next err if err
          written.should.be.true()
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
            next()

    describe 'will detect new line if no match', ->

      they 'place_before', (ssh, next) ->
        # Create file for the test
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin'
        , (err) ->
          # File exist, append replace string to it and detect missing line break
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /will never be found/
            replace: 'Add this line'
            place_before: true
          , (err, written) ->
            return next err if err
            written.should.be.true()
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'Add this line\nhere we are\nyou coquin'
              next()

      they 'place_after', (ssh, next) ->
        # Create file for the test
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'here we are\nyou coquin'
        , (err) ->
          # File exist, append replace string to it and detect missing line break
          mecano.file
            ssh: ssh
            target: "#{scratch}/file"
            match: /will never be found/
            replace: 'Add this line'
            append: true
          , (err, written) ->
            return next err if err
            written.should.be.true()
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nyou coquin\nAdd this line'
              next()

    describe 'create file if not exists', ->

      they 'place_before', (ssh, next) ->
        # File does not exist, it create it with the content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          place_before: true
        , (err, written) ->
          return next err if err
          written.should.be.true()
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'Add this line'
            next()

      they 'place_after', (ssh, next) ->
        # File does not exist, it create it with the content
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          append: true
        , (err, written) ->
          return next err if err
          written.should.be.true()
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'Add this line'
            next()
    
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
      , (err, written) ->
        written.should.be.true()
      .file
        target: "#{scratch}/a_file"
        replace: 'Add this line'
        append: true
      , (err, written) ->
        written.should.be.false()
      .file
        target: "#{scratch}/a_file"
        write: [
          replace: 'Add this line'
          append: true
        ]
      , (err, written) ->
        written.should.be.false()
      .call (options, next) ->
        fs.readFile ssh, "#{scratch}/a_file", 'utf8', (err, content) ->
          content.should.eql 'Here we are\nyou coquin\nAdd this line'
          next()
      .then next

  describe 'backup', ->
  
    they 'create a file', (ssh, next) ->
      # First we create a file
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        return next err if err
        # If nothing has change, there should be no backup
        mecano.file
          ssh: ssh
          target: "#{scratch}/file"
          content: 'Hello'
          backup: '.bck'
        , (err, written) ->
          return next err if err
          written.should.be.false()
          fs.exists ssh, "#{scratch}/file.bck", (err, exists) ->
            exists.should.be.false()
            # If content is different, check the backup
            mecano.file
              ssh: ssh
              target: "#{scratch}/file"
              content: 'Hello Node'
              backup: '.bck'
            , (err, written) ->
              return next err if err
              written.should.be.true()
              fs.readFile ssh, "#{scratch}/file.bck", 'utf8', (err, content) ->
                content.should.eql 'Hello'
                next()
  
    they 'a non-existing file', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/new_file"
        content: 'Hello'
        backup: true
      , (err, written) ->
        written.should.be.true() unless err
        next err


  describe 'write', ->
  
    they 'do multiple replace', (ssh, next) ->
      # First we create a file
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'username: me\nemail: my@email\nfriends: you'
      , (err, written) ->
        return next err if err
        mecano.file
          ssh: ssh
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
        , (err, written) ->
            return next err if err
            written.should.be.true()
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: you\n\nfriends: me'
              next()
  
    they 'use append', (ssh, next) ->
      # First we create a file
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'username: me\nfriends: you'
      , (err, written) ->
        return next err if err
        mecano.file
          ssh: ssh
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
        , (err, written) ->
            return next err if err
            written.should.be.true()
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: you\nemail: your@email\nfriends: me'
              next()
  
    they 'handle partial match', (ssh, next) ->
      # First we create a file
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'username: me\nfriends: none'
      , (err, written) ->
        return next err if err
        # First write will not find a match
        mecano.file
          ssh: ssh
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
        , (err, written) ->
            return next err if err
            written.should.be.true()
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: me\nemail: my@email\nfriends: you'
              next()

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
      , (err, written) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
        next()

    they 'if local source doesn\'t exists', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
        local: true
      , (err, written) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
        next()

  describe 'eof', ->

    they 'auto-detected', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'this is\r\nsome content'
        eof: true
      , (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/file", (err, content) ->
          content.toString().should.eql 'this is\r\nsome content\r\n'
          next()

    they 'not detected', (ssh, next) ->
      mecano.file
        ssh: ssh
        target: "#{scratch}/file"
        content: 'this is some content'
        eof: true
      , (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/file", (err, content) ->
          content.toString().should.eql 'this is some content\n'
          next()
