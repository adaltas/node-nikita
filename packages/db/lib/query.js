// Generated by CoffeeScript 2.4.1
// # `nikita.db.user.query`

// Check if a user exists in the database.

// ## Options

// * `admin_username`   
//   The login of the database administrator. It should have credentials to 
//   create accounts.   
// * `admin_password`   
//   The password of the database administrator.   
// * `database` (String)   
//   The database name to which the user should be added.   
// * `engine`   
//   The engine type, can be MySQL or PostgreSQL, default to MySQL.   
// * `host`   
//   The hostname of the database.     
// * `port`   
//   Port to the associated database.   

// ## Schema
var cmd, connection_options, escape, handler, jdbc, on_options, regexp, schema;

schema = {
  type: 'object',
  properties: {
    'admin_username': {
      type: 'string'
    },
    'admin_password': {
      type: 'string'
    },
    'database': {
      type: ['null', 'string'],
      default: null
    },
    'grep': {
      type: 'string'
    },
    'egrep': {
      instanceof: 'RegExp'
    },
    'engine': {
      type: 'string',
      enum: ['mariadb', 'mysql', 'postgres', 'postgresql']
    },
    'host': {
      type: 'string'
    },
    'port': {
      type: 'integer'
    },
    'silent': {
      type: 'boolean',
      default: true
    },
    'trim': {
      type: 'boolean',
      default: false
    }
  },
  required: ['admin_password', 'cmd', 'engine', 'host', 'admin_username']
};

// ## Hooks
on_options = function({options}) {
  var k, ref, ref1, v;
  ref = options.db || {};
  for (k in ref) {
    v = ref[k];
    // Import all properties from `options.db`
    if (options[k] == null) {
      options[k] = v;
    }
  }
  // throw Error 'Required Option: "admin_password"' if options.admin_username and not options.admin_password
  // throw Error 'Required Option: "password"' if options.username and not options.password
  // throw Error 'Required Option: "admin_username" or "username"' if not options.admin_username and not options.username
  // options.admin_password = null unless options.admin_username
  if (regexp.is(options.grep)) {
    options.egrep = options.grep;
    delete options.grep;
  }
  options.engine = (ref1 = options.engine) != null ? ref1.toLowerCase() : void 0;
  if (typeof options.port === 'string' && /^\d+$/.test(options.port)) {
    options.port = parseInt(options.port);
  }
  if (options.engine === 'postgres') {
    console.log('Deprecated Value: options "postgres" is deprecated in favor of "postgresql"');
    return options.engine = 'postgresql';
  }
};

// ## Handler
handler = function({options}, callback) {
  return this.system.execute({
    cmd: cmd(options),
    // code_skipped: options.code_skipped
    trim: options.trim
  }, function(err, {stdout}) {
    if (err) {
      return callback(err);
    }
    if (options.grep) {
      return callback(null, {
        stdout: stdout,
        status: stdout.split('\n').some(function(line) {
          return line === options.grep;
        })
      });
    }
    if (options.egrep) {
      return callback(null, {
        stdout: stdout,
        status: stdout.split('\n').some(function(line) {
          return options.egrep.test(line);
        })
      });
    }
    return callback(null, {
      status: true,
      stdout: stdout
    });
  });
};


// ## Escape

// Escape SQL for Bash processing.
escape = function(sql) {
  return sql.replace(/[\\"]/g, "\\$&");
};

// ## Command

// Build the CLI query command.
cmd = function(...opts) {
  var i, k, len, opt, options, v;
  options = {};
  for (i = 0, len = opts.length; i < len; i++) {
    opt = opts[i];
    if (typeof opt === 'string') {
      opt = {
        cmd: opt
      };
    }
    for (k in opt) {
      v = opt[k];
      options[k] = v;
    }
  }
  switch (options.engine) {
    case 'mariadb':
    case 'mysql':
      if (options.path == null) {
        options.path = 'mysql';
      }
      if (options.port == null) {
        options.port = '3306';
      }
      return [
        "mysql",
        `-h${options.host}`,
        `-P${options.port}`,
        `-u${options.admin_username}`,
        `-p'${options.admin_password}'`,
        options.database ? `-D${options.database}` : void 0,
        options.mysql_options ? `${options.mysql_options}` : void 0,
        // -N, --skip-column-names   Don't write column names in results.
        // -s, --silent              Be more silent. Print results with a tab as separator, each row on new line.
        // -r, --raw                 Write fields without conversion. Used with --batch.
        options.silent ? "-N -s -r" : void 0,
        options.cmd ? `-e "${escape(options.cmd)}"` : void 0
      ].join(' ');
    case 'postgresql':
      if (options.path == null) {
        options.path = 'psql';
      }
      if (options.port == null) {
        options.port = '5432';
      }
      return [
        `PGPASSWORD=${options.admin_password}`,
        "psql",
        `-h ${options.host}`,
        `-p ${options.port}`,
        `-U ${options.admin_username}`,
        options.database ? `-d ${options.database}` : void 0,
        options.postgres_options ? `${options.postgres_options}` : void 0,
        // -t, --tuples-only        Print rows only
        // -A, --no-align           Unaligned table output mode
        // -q, --quiet              Run quietly (no messages, only query output)
        "-tAq",
        options.cmd ? `-c "${options.cmd}"` : void 0
      ].join(' ');
    default:
      throw Error(`Unsupported engine: ${JSON.stringify(options.engine)}`);
  }
};


// ## Parse JDBC URL

// Enrich the result of `url.parse` with the "engine" and "db" properties.

// Exemple:

// ```
// parse 'jdbc:mysql://host1:3306,host2:3306/hive?createDatabaseIfNotExist=true'
// { engine: 'mysql',
//   addresses:
//    [ { host: 'host1', port: '3306' },
//      { host: 'host2', port: '3306' } ],
//   database: 'hive' }
// ```
jdbc = function(jdbc) {
  var _, addresses, database, engine;
  if (/^jdbc:mysql:/.test(jdbc)) {
    [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec(jdbc);
    addresses = addresses.split(',').map(function(address) {
      var host, port;
      [host, port] = address.split(':');
      return {
        host: host,
        port: port || 3306
      };
    });
    return {
      engine: 'mysql',
      addresses: addresses,
      database: database
    };
  } else if (/^jdbc:postgresql:/.test(jdbc)) {
    [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec(jdbc);
    addresses = addresses.split(',').map(function(address) {
      var host, port;
      [host, port] = address.split(':');
      return {
        host: host,
        port: port || 5432
      };
    });
    return {
      engine: 'postgresql',
      addresses: addresses,
      database: database
    };
  } else {
    throw Error('Invalid JDBC URL');
  }
};

// ## Copy options
connection_options = function(opts) {
  var k, options, v;
  options = {};
  for (k in opts) {
    v = opts[k];
    if (k !== 'admin_username' && k !== 'admin_password' && k !== 'database' && k !== 'engine' && k !== 'host' && k !== 'port' && k !== 'silent') {
      continue;
    }
    options[k] = v;
  }
  return options;
};

// ## Exports
module.exports = {
  on_options: on_options,
  handler: handler,
  schema: schema,
  cmd: cmd,
  // Utils
  connection_options: connection_options,
  escape: escape,
  jdbc: jdbc
};

// ## Dependencies
({regexp} = require('@nikitajs/core/lib/misc'));
