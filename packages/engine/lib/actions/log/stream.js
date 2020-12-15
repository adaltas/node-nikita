// Generated by CoffeeScript 2.5.1
// # `nikita.log.stream`

// Write log to custom destinations in a user provided format.

// ## Schema
var fs, handler, path, schema;

schema = {
  type: 'object',
  properties: {
    'end': {
      type: 'boolean',
      description: `Close the writable stream with the session is finished or stoped on
error.`
    },
    'serializer': {
      type: 'object',
      description: `An object of key value pairs where keys are the event types and the
value is a function which must be implemented to serialize the
information.`,
      patternProperties: {
        '.*': {
          typeof: 'function'
        }
      },
      additionalProperties: false
    },
    'stream': {
      instanceof: 'Object', // WritableStream
      description: `Destination to which data is written.`
    }
  }
};

// ## Handler
handler = function({
    config,
    tools: {events}
  }) {
  var close;
  if (!config.stream) {
    // Validate config
    throw Error('Missing option: "stream"');
  }
  if (!config.serializer) {
    throw Error('Missing option: "serializer"');
  }
  // Normalize
  if (config.end == null) {
    config.end = true;
  }
  // Events
  close = function() {
    return setTimeout(function() {
      if (config.end) {
        return config.stream.close();
      }
    }, 100);
  };
  events.on('nikita:action:start', async function(act) {
    var data;
    if (!config.serializer['nikita:action:start']) {
      return;
    }
    data = (await config.serializer['nikita:action:start'](act));
    if (data != null) {
      return config.stream.write(data);
    }
  });
  // events.on 'lifecycle', (log) ->
  //   return unless config.serializer.lifecycle
  //   data = config.serializer.lifecycle log
  //   config.stream.write data if data?
  events.on('text', function(log) {
    var data;
    if (!config.serializer.text) {
      return;
    }
    data = config.serializer.text(log);
    if (data != null) {
      return config.stream.write(data);
    }
  });
  // events.on 'header', (log) ->
  //   return unless config.serializer.header
  //   data = config.serializer.header log
  //   config.stream.write data if data?
  events.on('stdin', function(log) {
    var data;
    if (!config.serializer.stdin) {
      return;
    }
    data = config.serializer.stdin(log);
    if (data != null) {
      return config.stream.write(data);
    }
  });
  // events.on 'diff', (log) ->
  //   return unless config.serializer.diff
  //   data = config.serializer.diff log
  //   config.stream.write data if data?
  events.on('nikita:action:end', function() {
    var data;
    if (!config.serializer['nikita:action:end']) {
      return;
    }
    data = config.serializer['nikita:action:end'].apply(null, arguments);
    if (data != null) {
      return config.stream.write(data);
    }
  });
  events.on('stdout_stream', function(log) {
    var data;
    if (!config.serializer.stdout_stream) {
      return;
    }
    data = config.serializer.stdout_stream(log);
    if (data != null) {
      return config.stream.write(data);
    }
  });
  // events.on 'stderr', (log) ->
  //   return unless config.serializer.stderr
  //   data = config.serializer.stderr log
  //   config.stream.write data if data?
  events.on('nikita:session:resolved', function() {
    var data;
    if (config.serializer['nikita:session:resolved']) {
      data = config.serializer['nikita:session:resolved'].apply(null, arguments);
      if (data != null) {
        config.stream.write(data);
      }
    }
    return close();
  });
  events.on('nikita:session:rejected', function(err) {
    var data;
    if (config.serializer['nikita:session:rejected']) {
      data = config.serializer['nikita:session:rejected'].apply(null, arguments);
      if (data != null) {
        config.stream.write(data);
      }
    }
    return close();
  });
  return null;
};

// ## Exports
module.exports = {
  ssh: false,
  handler: handler,
  metadata: {
    schema: schema
  }
};

// ## Dependencies
fs = require('fs');

path = require('path');
