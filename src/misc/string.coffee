
crypto = require 'crypto'

module.exports =
    escapeshellarg: (arg) ->
      result = arg.replace /[^\\]'/g, (match) ->
        match.slice(0, 1) + '\\\''
      "'#{result}'"
    ###
    `string.hash(file, [algorithm], callback)`
    ------------------------------------------
    Output the hash of a supplied string in hexadecimal 
    form. The default algorithm to compute the hash is md5.
    ###
    hash: (data, algorithm) ->
      if arguments.length is 1
        algorithm = 'md5'
      crypto.createHash(algorithm).update(data).digest('hex')
    repeat: (str, l) ->
      Array(l+1).join str
    ###
    `string.endsWith(search, [position])`
    -------------------------------------
    Determines whether a string ends with the characters of another string, 
    returning true or false as appropriate.   
    This method has been added to the ECMAScript 6 specification and its code 
    was borrowed from [Mozilla](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/endsWith)
    ###
    endsWith: (str, search, position) ->
      position = position or str.length
      position = position - search.length
      lastIndex = str.lastIndexOf search
      return lastIndex isnt -1 and lastIndex is position
    lines: (str) ->
      str.split /\r\n|[\n\r\u0085\u2028\u2029]/g
    print_time: (time) ->
      if time > 1000*60
        "#{time / 1000}m"
      if time > 1000
        "#{time / 1000}s"
      else
        "#{time}ms"
    underscore: (str) ->
      trim(str).replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/[-\s]+/g, '_').toLowerCase()
    render: (options) ->
      options.log message: "Rendering with #{options.engine}", level: 'DEBUG', module: 'mecano/lib/write'
      try
        switch options.engine
          when 'nunjunks'
            env = new nunjucks.Environment null, autoescape: false
            options.filters ?= {}
            options.filters.isString ?= (obj) -> typeof obj is 'string'
            options.filters.isArray ?= (obj) -> Array.isArray obj
            options.filters.isObject ?= (obj) -> typeof obj is 'object' and not Array.isArray obj
            options.filters.contains ?= (arr, obj) -> if Array.isArray arr then obj in arr else false
            options.filters.isEmpty ?= (obj) ->
              return true if !obj? or obj is ''
              return true if Array.isArray obj and obj.length is 0
              return true if typeof obj is 'object' and Object.keys(obj).length is 0
              return false
            for filter, func of options.filters
              if typeof func is 'function'
                env.addFilter filter, func
              else
                options.log message: "Option filter not a function and ignored", level: 'WARN', module: 'mecano/lib/write'
            options.content = env.renderString options.content.toString(), options.context
          when 'eco'
            options.content = eco.render options.content.toString(), options.context
          else throw Error "Invalid engine: #{options.engine}"
      catch err
        throw (if typeof err is 'string' then Error(err) else err)
    replace_partial: (options) ->
      return unless options.write?.length
      options.log message: "Replacing sections of the file", level: 'DEBUG', module: 'mecano/lib/misc/string'
      for opts in options.write
        if opts.match
          opts.match ?= opts.replace
          options.log message: "Convert match string to regexp", level: 'DEBUG', module: 'mecano/lib/misc/string' if typeof opts.match is 'string'
          opts.match = ///#{quote opts.match}///mg if typeof opts.match is 'string'
          throw Error "Invalid match option" unless opts.match instanceof RegExp
          if opts.match.test options.content
            options.content = options.content.replace opts.match, opts.replace
            options.log message: "Match existing partial", level: 'INFO', module: 'mecano/lib/misc/string'
          else if opts.place_before and typeof opts.replace is 'string'
            if typeof opts.place_before is "string"
              opts.place_before = new RegExp ///^.*#{quote opts.place_before}.*$///mg
            if opts.place_before instanceof RegExp
              options.log message: "Replace with match and place_before regexp", level: 'DEBUG', module: 'mecano/lib/misc/string'
              posoffset = 0
              orgContent = options.content
              while (res = opts.place_before.exec orgContent) isnt null
                options.log message: "Before regexp found a match", level: 'INFO', module: 'mecano/lib/misc/string'
                pos = posoffset + res.index #+ res[0].length
                options.content = options.content.slice(0,pos) + opts.replace + '\n' + options.content.slice(pos)
                posoffset += opts.replace.length + 1
                break unless opts.place_before.global
              place_before = false
            else# if content
              options.log message: "Forgot how we could get there, test shall say it all", level: 'DEBUG', module: 'mecano/lib/misc/string'
              linebreak = if options.content.length is 0 or options.content.substr(options.content.length - 1) is '\n' then '' else '\n'
              options.content = opts.replace + linebreak + options.content
          else if opts.append and typeof opts.replace is 'string'
            if typeof opts.append is "string"
              options.log message: "Convert append string to regexp", level: 'DEBUG', module: 'mecano/lib/misc/string'
              opts.append = new RegExp "^.*#{quote opts.append}.*$", 'mg'
            if opts.append instanceof RegExp
              options.log message: "Replace with match and append regexp", level: 'DEBUG', module: 'mecano/lib/misc/string'
              posoffset = 0
              orgContent = options.content
              while (res = opts.append.exec orgContent) isnt null
                options.log message: "Append regexp found a match", level: 'INFO', module: 'mecano/lib/misc/string'
                pos = posoffset + res.index + res[0].length
                options.content = options.content.slice(0,pos) + '\n' + opts.replace + options.content.slice(pos)
                posoffset += opts.replace.length + 1
                break unless opts.append.global
            else
              linebreak = if options.content.length is 0 or options.content.substr(options.content.length - 1) is '\n' then '' else '\n'
              options.content = options.content + linebreak + opts.replace
          else
            continue # Did not match, try callback
        else if opts.place_before is true
          options.log message: "Before is true, need to explain how we could get here", level: 'INFO', module: 'mecano/lib/misc/string'
        else if opts.from or opts.to
          if opts.from and opts.to
            from = ///(^#{quote opts.from}$)///m.exec(options.content)
            to = ///(^#{quote opts.to}$)///m.exec(options.content)
            if from? and not to?
              options.log message: "Found 'from' but missing 'to', skip writing", level: 'WARN', module: 'mecano/lib/misc/string'
            else if not from? and to?
              options.log message: "Missing 'from' but found 'to', skip writing", level: 'WARN', module: 'mecano/lib/misc/string'
            else if not from? and not to?
              if opts.append
                options.content += '\n' + opts.from + '\n' + opts.replace+ '\n' + opts.to
              else
                options.log message: "Missing 'from' and 'to' without append, skip writing", level: 'WARN', module: 'mecano/lib/misc/string'
            else
              options.content = options.content.substr(0, from.index + from[1].length + 1) + opts.replace + '\n' + options.content.substr(to.index)
          else if opts.from and not opts.to
            from = ///(^#{quote opts.from}$)///m.exec(options.content)
            if from?
              options.content = options.content.substr(0, from.index + from[1].length) + '\n' + opts.replace
            else # TODO: honors append
              options.log message: "Missing 'from', skip writing", level: 'WARN', module: 'mecano/lib/misc/string'
          else if not opts.from and opts.to
            from_index = 0
            to = ///(^#{quote opts.to}$)///m.exec(options.content)
            if to?
              options.content = opts.replace + '\n' + options.content.substr(to.index)
            else # TODO: honors append
              options.log message: "Missing 'to', skip writing", level: 'WARN', module: 'mecano/lib/misc/string'

eco = require 'eco'
nunjucks = require 'nunjucks/src/environment'
quote = require 'regexp-quote'
