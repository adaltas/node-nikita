
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
misc = require "../#{lib}/misc"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'write', ->

  scratch = test.scratch @

  describe 'content', ->
  
    they 'write a string', (ssh, next) ->
      # Write the content
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        return next err if err
        # File has been created
        written.should.be.ok
        # Write the same content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'Hello'
        , (err, written) ->
          return next err if err
          # Content has change
          written.should.not.be.ok
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            content.should.eql 'Hello'
            next()
    
    they 'doesnt increment if destination is same than generated content', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'Hello'
        , (err, written) ->
          return next err if err
          written.should.not.be.ok
          next()
    
    they 'doesnt increment if destination is same than generated content', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file_copy"
          source: "#{scratch}/file"
        , (err, written) ->
          return next err if err
          written.should.be.ok
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            content.should.eql 'Hello'
            next()
    
    they 'empty file', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/empty_file"
        content: ''
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql ''
          next()

    they 'touch file', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/empty_file"
        content: ''
        not_if_exists: true
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql ''
          mecano.write
            ssh: ssh
            destination: "#{scratch}/empty_file"
            content: 'toto'
          , (err, written) ->
            mecano.write
              ssh: ssh
              destination: "#{scratch}/empty_file"
              content: ''
              not_if_exists: true
            , (err, written) ->
              return next err if err
              written.should.not.be.ok
              fs.readFile ssh, "#{scratch}/empty_file", 'utf8', (err, content) ->
                return next err if err
                content.should.eql 'toto'
                next()

    they 'handle integer type', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 123
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/a_file", 'ascii', (err, content) ->
          return next err if err
          content.should.eql '123'
          next()
    
    they 'create parent directory', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/a/missing/dir/a_file"
        content: 'hello'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/a/missing/dir/a_file", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'hello'
          next()

  describe 'ownerships and permissions', ->

    they 'set permission', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0700
      , (err, written) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
          return next err if err
          misc.mode.compare(stat.mode, 0o0700).should.be.ok
          fs.stat ssh, "#{scratch}", (err, stat) ->
            return next err if err
            misc.mode.compare(stat.mode, 0o0700).should.not.be.ok
            next()

    they 'change permission', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 'ok'
        mode: 0o0700
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/a_file"
          content: 'ok'
          mode: 0o0755
        , (err, written) ->
          return next err if err
          written.should.be.ok
          mecano.write
            ssh: ssh
            destination: "#{scratch}/a_file"
            content: 'ok'
            mode: 0o0755
          , (err, written) ->
            return next err if err
            written.should.not.be.ok
            next()

    they 'change permission after modification', (ssh, next) ->
      mecano
      .write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 'Hello'
        mode: 0o0700
      .write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 'World'
        mode: 0o0755
      , (err, written) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
          return next err if err
          misc.mode.compare(stat.mode, 0o0755).should.be.true
          next()

  describe 'from and to', ->
  
    they 'with from and with to', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/fromto.md"
        from: '# from'
        to: '# to'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\n# from\nmy friend\n# to\nyou coquin'
          next()
  
    they 'with from and with to append', (ssh, next) ->
      fs.writeFile ssh, "#{scratch}/fromto.md", 'here we are\nyou coquin', (err) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/fromto.md"
          from: '# from'
          to: '# to'
          append: true
          replace: 'my friend'
        , (err, written) ->
          return next err if err
          written.should.be.ok
          fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nyou coquin\n# from\nmy friend\n# to'
            mecano.write
              ssh: ssh
              destination: "#{scratch}/fromto.md"
              from: '# from'
              to: '# to'
              append: true
              replace: 'my best friend'
              eof: true
            , (err, written) ->
              return next err if err
              written.should.be.ok
              fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
                return next err if err
                content.should.eql 'here we are\nyou coquin\n# from\nmy best friend\n# to\n'
                next()
    
    they 'with from and without to', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/fromto.md"
        from: '# from'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\n# from\nmy friend'
          next()
    
    they 'without from and with to', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/fromto.md"
        to: '# to'
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'my friend\n# to\nyou coquin'
          next()

  describe 'match & replace', ->
  
    they 'with match a line as a string', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/fromto.md"
        match: 'lets try to replace that one'
        content: 'here we are\nlets try to replace that one\nyou coquin'
        replace: 'my friend'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nmy friend\nyou coquin'
          next()
  
    they 'with match a word as a string', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/fromto.md"
        match: 'replace'
        content: 'replace that one\nand\nreplace this one\nand not this one'
        replace: 'switch'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/fromto.md", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'switch that one\nand\nswitch this one\nand not this one'
          next()
  
    they 'with match as a regular expression', (ssh, next) ->
      # With a match
      mecano.write
        ssh: ssh
        destination: "#{scratch}/replace"
        content: 'email=david(at)adaltas(dot)com\nusername=root'
        match: /(username)=(.*)/
        replace: '$1=david (was $2)'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        # Without a match
        mecano.write
          ssh: ssh
          destination: "#{scratch}/replace"
          match: /this wont work/
          replace: '$1=david (was $2)'
        , (err, written) ->
          return next err if err
          written.should.not.be.ok
          fs.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
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
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
          return next err if err
          content.should.eql 'here we are\nmy friend, lets try\nyou coquin'
          next()
    
    they 'with match with global and multilines', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/replace"
        match: /^property=.*$/mg
        content: '#A config file\n#property=30\nproperty=10\nproperty=20\n#End of Config'
        replace: 'property=50'
      , (err, written) ->
        return next err if err
        written.should.be.ok
        fs.readFile ssh, "#{scratch}/replace", 'utf8', (err, content) ->
          return next err if err
          content.should.eql '#A config file\n#property=30\nproperty=50\nproperty=50\n#End of Config'
          next()
    
    they 'will replace destination if source or content does not exists', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 'This is\nsome content\nfor testing'
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/a_file"
          match: /(.*content)/
          replace: 'a text'
        , (err, written) ->
          return next err if err
          written.should.be.ok
          mecano.write
            ssh: ssh
            destination: "#{scratch}/a_file"
            match: /(.*content)/
            replace: 'a text'
          , (err, written) ->
            return next err if err
            written.should.not.be.ok
            fs.readFile ssh, "#{scratch}/a_file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'This is\na text\nfor testing'
              next()

  describe 'before', ->

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
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
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'world'
        before: true
      , (err) ->
        return next err if err
        # File exists, prepends to it
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          replace: 'hello'
          before: true
        , (err) ->
          return next err if err
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'hello\nworld'
            next()

  describe 'append', ->

    they 'append content to missing file', (ssh, next) ->
      # File does not exist, it create it with the content
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
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
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'hello'
        append: true
      , (err) ->
        return next err if err
        # File exists, it append to it
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'world'
          append: true
        , (err) ->
          return next err if err
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'helloworld'
            next()

  describe 'match & append or before', ->

    describe 'will not prepend/append if match', ->

      they 'before', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'you coquin\nhere we are\n'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /.*coquin/
            replace: 'new coquin'
            before: true
          , (err, written) ->
            return next err if err
            written.should.be.ok
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'new coquin\nhere we are\n'
              # Write a second time with same match
              mecano.write
                ssh: ssh
                destination: "#{scratch}/file"
                match: /.*coquin/
                replace: 'new coquin'
                before: true
              , (err, written) ->
                return next err if err
                written.should.not.be.ok
                # Check file content
                fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
                  return next err if err
                  content.should.eql 'new coquin\nhere we are\n'
                  next()

      they 'after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin\n'
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
            written.should.be.ok
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nnew coquin\n'
              # Write a second time with same match
              mecano.write
                ssh: ssh
                destination: "#{scratch}/file"
                match: /.*coquin/
                replace: 'new coquin'
                append: true
              , (err, written) ->
                return next err if err
                written.should.not.be.ok
                # Check file content
                fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
                  return next err if err
                  content.should.eql 'here we are\nnew coquin\n'
                  next()

    they 'will append if no match', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'here we are\nyou coquin\n'
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          append: true
        , (err, written) ->
          return next err if err
          written.should.be.ok
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nyou coquin\nAdd this line'
            next()

    describe 'before/after a match if it is a regexp', ->

      they 'before', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            before: /^.*we.*$/m
          , (err, written) ->
            return next err if err
            written.should.be.ok
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'Add this line\nhere we are\nyou coquin\nshould we\nhave fun'
              next()

      they 'after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it creates it with the content
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            append: /^.*we.*$/m
          , (err, written) ->
            return next err if err
            written.should.be.ok
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nhave fun'
              next()

    describe 'before/after multiple times if regexp with global flag', ->

      they 'before', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            before: /^.*we.*$/gm
          , (err, written) ->
            return next err if err
            written.should.be.ok
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'Add this line\nhere we are\nyou coquin\nAdd this line\nshould we\nhave fun'
              next()

      they 'after', (ssh, next) ->
        # Prepare by creating a file with content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        , (err) ->
          # File does not exist, it create it with the content
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /will never work/
            replace: 'Add this line'
            append: /^.*we.*$/gm
          , (err, written) ->
            return next err if err
            written.should.be.ok
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
              next()


    they 'will append after a match if append is a string', (ssh, next) ->
      # Prepare by creating a file with content
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'here we are\nyou coquin\nshould we\nhave fun'
      , (err) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          match: /will never work/
          replace: 'Add this line'
          append: 'we'
        , (err, written) ->
          return next err if err
          written.should.be.ok
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'
            next()

    describe 'will detect new line if no match', ->

      they 'before', (ssh, next) ->
        # Create file for the test
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin'
        , (err) ->
          # File exist, append replace string to it and detect missing line break
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /will never be found/
            replace: 'Add this line'
            before: true
          , (err, written) ->
            return next err if err
            written.should.be.ok
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'Add this line\nhere we are\nyou coquin'
              next()

      they 'after', (ssh, next) ->
        # Create file for the test
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'here we are\nyou coquin'
        , (err) ->
          # File exist, append replace string to it and detect missing line break
          mecano.write
            ssh: ssh
            destination: "#{scratch}/file"
            match: /will never be found/
            replace: 'Add this line'
            append: true
          , (err, written) ->
            return next err if err
            written.should.be.ok
            # Check file content
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'here we are\nyou coquin\nAdd this line'
              next()

    describe 'create file if not exists', ->

      they 'before', (ssh, next) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          before: true
        , (err, written) ->
          return next err if err
          written.should.be.ok
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'Add this line'
            next()

      they 'after', (ssh, next) ->
        # File does not exist, it create it with the content
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          match: /will never be found/
          replace: 'Add this line'
          append: true
        , (err, written) ->
          return next err if err
          written.should.be.ok
          # Check file content
          fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'Add this line'
            next()
    
    they 'match is optional', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/a_file"
        content: 'Here we are\nyou coquin'
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/a_file"
          replace: 'Add this line'
          append: true
        , (err, written) ->
          return next err if err
          written.should.be.ok
          mecano.write
            ssh: ssh
            destination: "#{scratch}/a_file"
            replace: 'Add this line'
            append: true
          , (err, written) ->
            return next err if err
            written.should.not.be.ok
            mecano.write
              ssh: ssh
              destination: "#{scratch}/a_file"
              write: [
                replace: 'Add this line'
                append: true
              ]
            , (err, written) ->
              return next err if err
              written.should.not.be.ok
              fs.readFile ssh, "#{scratch}/a_file", 'utf8', (err, content) ->
                return next err if err
                content.should.eql 'Here we are\nyou coquin\nAdd this line'
                next()

  describe 'backup', ->
  
    they 'create a file', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'Hello'
      , (err, written) ->
        return next err if err
        # If nothing has change, there should be no backup
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'Hello'
          backup: '.bck'
        , (err, written) ->
          return next err if err
          written.should.be.false
          fs.exists ssh, "#{scratch}/file.bck", (err, exists) ->
            exists.should.be.false
            # If content is different, check the backup
            mecano.write
              ssh: ssh
              destination: "#{scratch}/file"
              content: 'Hello Node'
              backup: '.bck'
            , (err, written) ->
              return next err if err
              written.should.be.true
              fs.readFile ssh, "#{scratch}/file.bck", 'utf8', (err, content) ->
                content.should.eql 'Hello'
                next()
  
    they 'a non-existing file', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/new_file"
        content: 'Hello'
        backup: true
      , (err, written) ->
        written.should.be.true unless err
        next err


  describe 'write', ->
  
    they 'do multiple replace', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'username: me\nemail: my@email\nfriends: you'
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
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
            written.should.be.ok
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: you\n\nfriends: me'
              next()
  
    they 'use append', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'username: me\nfriends: you'
      , (err, written) ->
        return next err if err
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
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
            written.should.be.ok
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: you\nemail: your@email\nfriends: me'
              next()
  
    they 'handle partial match', (ssh, next) ->
      # First we create a file
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'username: me\nfriends: none'
      , (err, written) ->
        return next err if err
        # First write will not find a match
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
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
            written.should.be.ok
            fs.readFile ssh, "#{scratch}/file", 'utf8', (err, content) ->
              return next err if err
              content.should.eql 'username: me\nemail: my@email\nfriends: you'
              next()

  describe 'error', ->

    they 'can not define source and content', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: 'abc'
        source: 'abc'
        content: 'abc'
      , (err) ->
        err.message.should.eql 'Define either source or content'
        next()

    they 'if source doesn\'t exists', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
      , (err, written) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
        next()

    they 'if local source doesn\'t exists', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        source: "#{scratch}/does/not/exists"
        local_source: true
      , (err, written) ->
        err.message.should.eql "Source does not exist: \"#{scratch}/does/not/exists\""
        next()

  describe 'diff', ->

    they 'call function and stdout', (ssh, next) ->
      # Prepare by creating a file with content
      data = []
      diffcalled = false
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'Testing diff\noriginal text'
      , (err) ->
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'Testing diff\nnew text'
          diff: (diff) ->
            diffcalled = true
            diff.should.eql [
              { value: 'Testing diff\n', count: 1 }
              { value: 'new text', count: 1, added: true, removed: undefined }
              { value: 'original text', count: 1, added: undefined, removed: true }
            ]
          stdout: write: (d) -> data.push d
        , (err) ->
          diffcalled.should.be.ok
          data.should.eql ['2 + new text\n', '2 - original text\n']
          next()
  
    they 'write a buffer', (ssh, next) ->
      # Write the content
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: new Buffer 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMKgZ7/2BG9T0vCJT8qlaH1KJNLSqEiJDHZMirPdzVsbI8x1AiT0EO5D47aROAKXTimVY3YsFr2ETXbLxjFFDP64WqqJ0b+3s2leReNq7ld70pVn1m8npyAZKvUc4/uo7WVLm0A1/U1f+iW9eqpYPKN/BY/+Ta2fp6ui0KUtha3B0xMICD66OLwrnmoFmxElEohL4OLZe7rnOW2G9M6Gej+LO5SeJip0YfiG+ImKQ1ngmGxpuopUOvcT1La/1TGki2gEV4AEm4QHW0fZ4Bjz0tdMVPGexUHQW/si9RWF8tJPsoykUcvS6slpbmil2ls9e7tcT6F4KZUCJv9nn6lWSf hdfs@hadoop'
        stdout: write: (d) ->
          # We used to have an error "#{content} has no method 'split'",
          # make sure this is fixed for ever
      , (err, written) ->
        next err

    they 'call stdout', (ssh, next) ->
      data = []
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'Testing diff\noriginal text1\noriginal text2'
      , (err) ->
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: 'Testing diff\nnew text1'
          stdout: write: (d) -> data.push d
        , (err) ->
          data.should.eql ['2 + new text1\n', '2 - original text1\n', '3 - original text2\n']
          next()

    they 'empty source on empty file', (ssh, next) ->
      data = []
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: ''
        stdout: write: (d) -> data.push d
      , (err) ->
        return next err if err
        data.should.eql []
        mecano.write
          ssh: ssh
          destination: "#{scratch}/file"
          content: ''
          stdout: write: (d) -> data.push d
        , (err) ->
          data.should.eql []
          next err

    they 'content on empty file', (ssh, next) ->
      data = []
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'some content'
        stdout: write: (d) -> data.push d
      , (err) ->
        return next err if err
        data.should.eql [ '1 + some content\n' ]
        next err

  describe 'eof', ->

    they 'auto-detected', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'this is\r\nsome content'
        eof: true
      , (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/file", (err, content) ->
          content.toString().should.eql 'this is\r\nsome content\r\n'
          next()

    they 'not detected', (ssh, next) ->
      mecano.write
        ssh: ssh
        destination: "#{scratch}/file"
        content: 'this is some content'
        eof: true
      , (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/file", (err, content) ->
          content.toString().should.eql 'this is some content\n'
          next()









