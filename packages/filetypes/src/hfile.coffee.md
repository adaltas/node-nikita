
`nikita.file.types.hfile`

HFile is an XML format used accros Hadoop components which contains keys and
value properties.

## Options

* `merge` (boolean)   
  Read the target if it exists and merge its content, optional.
* `source` (object, string)   
  Default configuration properties or the path to a default configuration file
  to get initial value from, optional.
* `target` (string)   
  Configuration file where to write, required.
* `properties` (object)   
  Configuration properties to write, required.
* `transform` (function)   
  User defined function used to transform properties.

## Source Code

    module.exports = ({options}) ->
      fnl_props = {}
      org_props = {}
      options.transform ?= null
      options.encoding ?= 'utf8'
      throw Error "Invalid options: \"transform\"" if options.transform? and typeof options.transform isnt 'function'
      @call (_, callback) ->
        @log message: "Read target properties from '#{options.target}'", level: 'DEBUG', module: '@nikita/filetypes/lib/hfile'
        # Populate org_props and, if merge, fnl_props
        @fs.readFile
          encoding: options.encoding
          target: options.target
        , (err, {data}) ->
          return callback() if err?.code is 'ENOENT'
          return callback err if err
          org_props = parse data
          if options.merge
            fnl_props = {}
            for k, v of org_props then fnl_props[k] = v
          callback()
      @call (_, callback) ->
        return callback() unless options.source
        return callback() unless typeof options.source is 'string'
        @log message: "Read source properties from #{options.source}", level: 'DEBUG', module: '@nikita/filetypes/lib/hfile'
        # Populate options.source
        @fs.readFile
          encoding: options.encoding
          target: options.target
        ,
          if options.local then ssh: null else {}
        , (err, {data}) ->
          return callback err if err
          options.source = parse data
          callback()
      @call ->
        return unless options.source
        # Note, source properties overwrite current ones by source, not sure
        # if this is the safest approach
        @log message: "Merge source properties", level: 'DEBUG', module: '@nikita/filetypes/lib/hfile'
        for k, v of options.source
          v = "#{v}" if typeof v is 'number'
          fnl_props[k] = v if fnl_props[k] is undefined or fnl_props[k] is null
      @call ->
        @log message: "Merge user properties", level: 'DEBUG', module: '@nikita/filetypes/lib/hfile'
        for k, v of options.properties
          v = "#{v}" if typeof v is 'number'
          if typeof v is 'undefined' or v is null
            delete fnl_props[k]
          else if Array.isArray v
            fnl_props[k] = v.join ','
          else if typeof v isnt 'string'
            throw Error "Invalid value type '#{typeof v}' for property '#{k}'"
          else fnl_props[k] = v
      @call ->
        return unless options.transform
        fnl_props = options.transform fnl_props
      @call ->
        keys = {}
        for k in Object.keys(org_props) then keys[k] = true
        for k in Object.keys(fnl_props) then keys[k] = true unless keys[k]?
        keys = Object.keys keys
        for k in keys
          continue unless org_props[k] isnt fnl_props[k]
          @log message: "Property '#{k}' was '#{org_props[k]}' and is now '#{fnl_props[k]}'", level: 'WARN', module: '@nikita/filetypes/lib/hfile'
      @call ->
        options.content = stringify fnl_props
        options.source = null
        options.header = null
        @file options

## `parse(xml, [property])`

Parse an xml document and retrieve one or multiple properties.

Retrieve all properties: `properties = parse(xml)`
Retrieve a property: `value = parse(xml, property)`

    parse = (markup, property) ->
      properties = {}
      doc = new xmldom.DOMParser().parseFromString markup
      for propertyChild in doc.documentElement.childNodes
        continue unless propertyChild.tagName?.toUpperCase() is 'PROPERTY'
        name = value = null
        for child in propertyChild.childNodes
          if child.tagName?.toUpperCase() is 'NAME'
            name = child.childNodes[0].nodeValue
          if child.tagName?.toUpperCase() is 'VALUE'
            value = child.childNodes[0]?.nodeValue or ''
        return value if property and name is property and value?
        properties[name] = value if name and value?
      return properties

## `stringify(properties)`

Convert a property object into a valid Hadoop XML markup. Properties are
ordered by name.

Convert an object into a string:

```
markup = stringify({
  'fs.defaultFS': 'hdfs://namenode:8020'
});
```

Convert an array into a string:

```
stringify([{
  name: 'fs.defaultFS', value: 'hdfs://namenode:8020'
}])
```

    stringify = (properties) ->
      markup = builder.create 'configuration', version: '1.0', encoding: 'UTF-8'
      if Array.isArray properties
        properties.sort (el1, el2) -> el1.name > el2.name
        for {name, value} in properties
          property = markup.ele 'property'
          property.ele 'name', name
          property.ele 'value', value
      else
        ks = Object.keys properties
        ks.sort()
        for k in ks
          property = markup.ele 'property'
          property.ele 'name', k
          property.ele 'value', properties[k]
      markup.end pretty: true

## Dependencies

    xmldom = require 'xmldom'
    builder = require 'xmlbuilder'
