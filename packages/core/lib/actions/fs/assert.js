// Generated by CoffeeScript 2.6.1
  // # `nikita.fs.assert`

// Assert a file exists or a provided text match the content of a text file.

// ## Output

// * `err` (Error)   
  //   Error if assertion failed.   

// ## Example

// Validate the content of a file:

// ```js
  // nikita.fs.assert({
  //   target: '/tmp/a_file', 
  //   content: 'nikita is around'
  // })
  // ```

// Ensure a file does not exists:

// ```js
  // nikita.fs.assert({
  //   target: '/tmp/a_file',
  //   not: true
  // })
  // ```

// ## Hooks
var definitions, errors, fs, handler, on_action, pad, utils,
  indexOf = [].indexOf;

on_action = function({config, metadata}) {
  if (config.filter instanceof RegExp) {
    return config.filter = [config.filter];
  }
};

// ## Schema definitions
definitions = {
  config: {
    type: 'object',
    properties: {
      'content': {
        oneOf: [
          {
            type: 'string'
          },
          {
            instanceof: 'Buffer'
          },
          {
            instanceof: 'RegExp'
          }
        ],
        description: `Text to validate.`
      },
      'encoding': {
        type: 'string',
        default: 'utf8',
        description: `Content encoding, see the Node.js supported Buffer encoding.`
      },
      'filetype': {
        type: 'array',
        items: {
          type: ['integer', 'string']
        },
        description: `Validate the file, could be any [file type
constants](https://nodejs.org/api/fs.html#fs_file_type_constants) or
one of 'ifreg', 'file', 'ifdir', 'directory', 'ifchr', 'chardevice',
'iffblk', 'blockdevice', 'ififo', 'fifo', 'iflink', 'symlink',
'ifsock',  'socket'.`
      },
      'filter': {
        type: 'array',
        items: {
          instanceof: 'RegExp'
        },
        description: `Text to filter in actual content before matching.`
      },
      'gid': {
        type: ['integer', 'string'],
        description: `Group ID to assert.`
      },
      'md5': {
        type: 'string',
        description: `Validate signature.`
      },
      'mode': {
        type: 'array',
        items: {
          $ref: 'module://@nikitajs/core/lib/actions/fs/base/chmod#/definitions/config/properties/mode'
        },
        description: `Validate file permissions.`
      },
      'not': {
        $ref: 'module://@nikitajs/core/lib/actions/assert#/definitions/config/properties/not'
      },
      'sha1': {
        type: 'string',
        description: `Validate signature.`
      },
      'sha256': {
        type: 'string',
        description: `Validate signature.`
      },
      'target': {
        type: 'string',
        description: `Location of the file to assert.`
      },
      'trim': {
        type: 'boolean',
        default: false,
        description: `Trim the actual and expected content before matching.`
      },
      'uid': {
        type: ['integer', 'string'],
        description: `User ID to assert.`
      }
    },
    required: ['target']
  }
};

// ## Handler
handler = async function({config, metadata}) {
  var _hash, algo, data, err, exists, filetype, filter, hash, i, j, len, len1, ref, ref1, ref10, ref11, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9, stats;
  config.filetype = (function() {
    var i, len, ref, results;
    ref = config.filetype || [];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      filetype = ref[i];
      if (!filetype) {
        continue;
      }
      if (typeof filetype === 'string') {
        switch (filetype.toLowerCase()) {
          case 'ifreg':
          case 'file':
            results.push(fs.constants.S_IFREG);
            break;
          case 'ifdir':
          case 'directory':
            results.push(fs.constants.S_IFDIR);
            break;
          case 'ifchr':
          case 'chardevice':
            results.push(fs.constants.S_IFCHR);
            break;
          case 'iffblk':
          case 'blockdevice':
            results.push(fs.constants.S_IFBLK);
            break;
          case 'ififo':
          case 'fifo':
            results.push(fs.constants.S_IFIFO);
            break;
          case 'iflink':
          case 'symlink':
            results.push(fs.constants.S_IFLNK);
            break;
          case 'ifsock':
          case 'socket':
            results.push(fs.constants.S_IFSOCK);
            break;
          default:
            results.push(filetype);
        }
      } else {
        results.push(filetype);
      }
    }
    return results;
  })();
  if (typeof config.content === 'string') {
    if (config.trim) {
      config.content = config.content.trim();
    }
    config.content = Buffer.from(config.content, config.encoding);
  } else if (Buffer.isBuffer(config.content)) {
    if (config.trim) {
      config.content = utils.buffer.trim(config.content, config.encoding);
    }
  }
  // Assert file exists
  if (!((config.content != null) || config.md5 || config.sha1 || config.sha256 || ((ref = config.mode) != null ? ref.length : void 0))) {
    ({exists} = (await this.fs.base.exists(config.target.toString())));
    if (!config.not) {
      if (!exists) {
        err = errors.NIKITA_FS_ASSERT_FILE_MISSING({
          config: config
        });
      }
    } else {
      if (exists) {
        err = errors.NIKITA_FS_ASSERT_FILE_EXISTS({
          config: config
        });
      }
    }
    if (err) {
      throw err;
    }
  }
  // Assert file filetype
  if ((ref1 = config.filetype) != null ? ref1.length : void 0) {
    ({stats} = (await this.fs.base.lstat(config.target)));
    if ((ref2 = fs.constants.S_IFREG, indexOf.call(config.filetype, ref2) >= 0) && !utils.stats.isFile(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'File',
        stats: stats
      });
    }
    if ((ref3 = fs.constants.S_IFDIR, indexOf.call(config.filetype, ref3) >= 0) && !utils.stats.isDirectory(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'Directory',
        stats: stats
      });
    }
    if ((ref4 = fs.constants.S_IFCHR, indexOf.call(config.filetype, ref4) >= 0) && !utils.stats.isCharacterDevice(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'Character Device',
        stats: stats
      });
    }
    if ((ref5 = fs.constants.S_IFBLK, indexOf.call(config.filetype, ref5) >= 0) && !utils.stats.isBlockDevice(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'Block Device',
        stats: stats
      });
    }
    if ((ref6 = fs.constants.S_IFIFO, indexOf.call(config.filetype, ref6) >= 0) && !utils.stats.isFIFO(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'FIFO',
        stats: stats
      });
    }
    if ((ref7 = fs.constants.S_IFLNK, indexOf.call(config.filetype, ref7) >= 0) && !utils.stats.isSymbolicLink(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'Symbolic Link',
        stats: stats
      });
    }
    if ((ref8 = fs.constants.S_IFSOCK, indexOf.call(config.filetype, ref8) >= 0) && !utils.stats.isSocket(stats.mode)) {
      throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
        config: config,
        expect: 'Socket',
        stats: stats
      });
    }
  }
  // Assert content equal
  if ((config.content != null) && (typeof config.content === 'string' || Buffer.isBuffer(config.content))) {
    ({data} = (await this.fs.base.readFile(config.target)));
    ref9 = config.filter || [];
    for (i = 0, len = ref9.length; i < len; i++) {
      filter = ref9[i];
      data = filter[Symbol.replace](data, '');
    }
    // RegExp returns string
    if (typeof data === 'string') {
      data = Buffer.from(data);
    }
    if (config.trim) {
      data = utils.buffer.trim(data, config.encoding);
    }
    if (!config.not) {
      if (!data.equals(config.content)) {
        throw errors.NIKITA_FS_ASSERT_CONTENT_UNEQUAL({
          config: config,
          expect: data
        });
      }
    } else {
      if (data.equals(config.content)) {
        throw errors.NIKITA_FS_ASSERT_CONTENT_EQUAL({
          config: config,
          expect: data
        });
      }
    }
    if (err) {
      throw err;
    }
  }
  // Assert content match
  if ((config.content != null) && config.content instanceof RegExp) {
    ({data} = (await this.fs.base.readFile(config.target)));
    ref10 = config.filter || [];
    for (j = 0, len1 = ref10.length; j < len1; j++) {
      filter = ref10[j];
      data = filter[Symbol.replace](data, '');
    }
    if (config.trim) {
      data = utils.buffer.trim(data, config.encoding);
    }
    if (!config.not) {
      if (!config.content.test(data)) {
        throw errors.NIKITA_FS_ASSERT_CONTENT_UNMATCH({
          config: config,
          expect: data
        });
      }
    } else {
      if (config.content.test(data)) {
        throw errors.NIKITA_FS_ASSERT_CONTENT_MATCH({
          config: config,
          expect: data
        });
      }
    }
    if (err) {
      throw err;
    }
  }
  if (config.md5) {
    // Assert hash match
    // todo, also support config.algo and config.hash
    (algo = 'md5', _hash = config.md5);
  }
  if (config.sha1) {
    (algo = 'sha1', _hash = config.sha1);
  }
  if (config.sha256) {
    (algo = 'sha256', _hash = config.sha256);
  }
  if (algo) {
    ({hash} = (await this.fs.hash(config.target, {
      algo: algo
    })));
    if (!config.not) {
      if (_hash !== hash) {
        throw errors.NIKITA_FS_ASSERT_HASH_UNMATCH({
          config: config,
          algo: algo,
          hash: {
            expected: _hash,
            actual: hash
          }
        });
      }
    } else {
      if (_hash === hash) {
        throw errors.NIKITA_FS_ASSERT_HASH_MATCH({
          config: config,
          algo: algo,
          hash: hash
        });
      }
    }
  }
  // Assert uid ownerships
  if (config.uid != null) {
    ({stats} = (await this.fs.base.lstat(config.target)));
    if (!config.not) {
      if (`${stats.uid}` !== `${config.uid}`) {
        throw errors.NIKITA_FS_ASSERT_UID_UNMATCH({
          config: config,
          actual: stats.uid
        });
      }
    } else {
      if (`${stats.uid}` === `${config.uid}`) {
        throw errors.NIKITA_FS_ASSERT_UID_MATCH({
          config: config
        });
      }
    }
  }
  // Assert gid ownerships
  if (config.gid != null) {
    ({stats} = (await this.fs.base.stat(config.target)));
    if (!config.not) {
      if (`${stats.gid}` !== `${config.gid}`) {
        throw errors.NIKITA_FS_ASSERT_GID_UNMATCH({
          config: config,
          actual: stats.gid
        });
      }
    } else {
      if (`${stats.gid}` === `${config.gid}`) {
        throw errors.NIKITA_FS_ASSERT_GID_MATCH({
          config: config
        });
      }
    }
  }
  // Assert file permissions
  if ((ref11 = config.mode) != null ? ref11.length : void 0) {
    ({stats} = (await this.fs.base.stat(config.target)));
    if (!config.not) {
      if (!utils.mode.compare(config.mode, stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_MODE_UNMATCH({
          config: config,
          mode: stats.mode
        });
      }
    } else {
      if (utils.mode.compare(config.mode, stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_MODE_MATCH({
          config: config
        });
      }
    }
  }
};

// ## Exports
module.exports = {
  handler: handler,
  hooks: {
    on_action: on_action
  },
  metadata: {
    argument_to_config: 'target',
    definitions: definitions
  }
};

// ## Errors
errors = {
  NIKITA_FS_ASSERT_FILE_MISSING: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_FILE_MISSING', ['file does not exists,', `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_FILE_EXISTS: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_FILE_EXISTS', ['file exists,', `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_FILETYPE_INVALID: function({config, expect, stats}) {
    return utils.error('NIKITA_FS_ASSERT_FILETYPE_INVALID', ['filetype is invalid,', `expect ${JSON.stringify(expect)} type,`, `got ${JSON.stringify(utils.stats.type(stats.mode))} type,`, `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_CONTENT_UNEQUAL: function({config, expect}) {
    return utils.error('NIKITA_FS_ASSERT_CONTENT_UNEQUAL', ['content does not equal the expected value,', `expect ${JSON.stringify(expect.toString())}`, `to equal ${JSON.stringify(config.content.toString())},`, `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_CONTENT_EQUAL: function({config, expect}) {
    return utils.error('NIKITA_FS_ASSERT_CONTENT_EQUAL', ['content is matching,', `not expecting to equal ${JSON.stringify(expect.toString())},`, `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_CONTENT_UNMATCH: function({config, expect}) {
    return utils.error('NIKITA_FS_ASSERT_CONTENT_UNMATCH', ['content does not match the provided regexp,', `expect ${JSON.stringify(expect.toString())}`, `to match ${config.content.toString()},`, `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_CONTENT_MATCH: function({config, expect}) {
    return utils.error('NIKITA_FS_ASSERT_CONTENT_MATCH', ['content is matching the provided regexp,', `got ${JSON.stringify(expect.toString())}`, `to match ${config.content.toString()},`, `location is ${JSON.stringify(config.target)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_HASH_UNMATCH: function({config, algo, hash}) {
    return utils.error('NIKITA_FS_ASSERT_HASH_UNMATCH', [`an invalid ${algo} signature was computed,`, `expect ${JSON.stringify(hash.expected)},`, `got ${JSON.stringify(hash.actual)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_HASH_MATCH: function({config, algo, hash}) {
    return utils.error('NIKITA_FS_ASSERT_HASH_MATCH', [`the ${algo} signatures are matching,`, `not expecting to equal ${JSON.stringify(hash)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_MODE_UNMATCH: function({config, mode}) {
    var expect;
    expect = config.mode.map(function(mode) {
      return `${pad(4, utils.mode.stringify(mode), '0')}`;
    });
    return utils.error("NIKITA_FS_ASSERT_MODE_UNMATCH", ['content permission don\'t match the provided mode,', `expect ${expect},`, `got ${utils.mode.stringify(mode).substr(-4)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_MODE_MATCH: function({config}) {
    var expect;
    expect = config.mode.map(function(mode) {
      return `${pad(4, utils.mode.stringify(mode), '0')}`;
    });
    return utils.error("NIKITA_FS_ASSERT_MODE_MATCH", ['the content permission match the provided mode,', `not expecting to equal ${expect}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_UID_UNMATCH: function({config, actual}) {
    return utils.error('NIKITA_FS_ASSERT_UID_UNMATCH', ['the uid of the target does not match the expected value,', `expected ${JSON.stringify(config.uid)},`, `got ${JSON.stringify(actual)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_UID_MATCH: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_UID_MATCH', ['the uid of the target  match the provided value,', `not expecting to equal ${JSON.stringify(config.uid)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_GID_UNMATCH: function({config, actual}) {
    return utils.error('NIKITA_FS_ASSERT_GID_UNMATCH', ['the gid of the target does not match the expected value,', `expected ${JSON.stringify(config.uid)},`, `got ${JSON.stringify(actual)}.`], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_GID_MATCH: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_GID_MATCH', ['the gid of the target  match the provided value,', `not expecting to equal ${JSON.stringify(config.uid)}.`], {
      target: config.target,
      message: config.error
    });
  }
};

// ## Dependencies
pad = require('pad');

fs = require('fs');

utils = require('../../utils');
