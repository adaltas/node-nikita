// Generated by CoffeeScript 2.7.0
// # `nikita.db.user.exists`

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
// * `username`   
//   The new user name.    
// * `port`   
//   Port to the associated database.   

// ## Schema definitions
var db, definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      // $ref: 'module://@nikitajs/db/lib/query'
      'username': {
        type: 'string',
        description: `Name of the user to check for existance.`
      }
    },
    required: ['username', 'admin_username', 'admin_password', 'engine', 'host']
  }
};

// ## Handler
handler = async function({config}) {
  var stdout;
  ({stdout} = (await this.db.query(db.connection_config(config), {
    database: void 0,
    command: (function() {
      switch (config.engine) {
        case 'mariadb':
        case 'mysql':
          return `SELECT User FROM mysql.user WHERE User = '${config.username}'`;
        case 'postgresql':
          return `SELECT '${config.username}' FROM pg_roles WHERE rolname='${config.username}'`;
      }
    })(),
    trim: true
  })));
  return {
    exists: stdout === config.username
  };
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    argument_to_config: 'username',
    global: 'db',
    shy: true,
    definitions: definitions
  }
};

// ## Dependencies
({db} = require('../utils'));
