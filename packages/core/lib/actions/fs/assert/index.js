// Dependencies
import pad from 'pad';
import fs from 'fs';
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" with { type: "json" };

const errors = {
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
    return utils.error('NIKITA_FS_ASSERT_CONTENT_UNMATCH', [
      'content does not match the provided regexp,',
      `expect ${JSON.stringify(expect.toString())}`,
      `to match ${config.content.toString()},`,
      `location is ${JSON.stringify(config.target)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_CONTENT_MATCH: function({config, expect}) {
    return utils.error('NIKITA_FS_ASSERT_CONTENT_MATCH', [
      'content is matching the provided regexp,',
      `got ${JSON.stringify(expect.toString())}`,
      `to match ${config.content.toString()},`,
      `location is ${JSON.stringify(config.target)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_FILETYPE_INVALID_VALUE: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_FILETYPE_INVALID_VALUE', [
      'provided filetype is not supported,',
      `got ${JSON.stringify(config.filetype)}.`
    ], {
      target: config.target,
    });
  },
  NIKITA_FS_ASSERT_FILETYPE_INVALID_TYPE: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_FILETYPE_INVALID_TYPE', [
      'filetype must be a string or a number,',
      `got ${JSON.stringify(config.filetype)}.`
    ], {
      target: config.target,
    });
  },
  NIKITA_FS_ASSERT_HASH_UNMATCH: function({config, algo, hash}) {
    return utils.error('NIKITA_FS_ASSERT_HASH_UNMATCH', [
      `an invalid ${algo} signature was computed,`,
      `expect ${JSON.stringify(hash.expected)},`,
      `got ${JSON.stringify(hash.actual)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_HASH_MATCH: function({config, algo, hash}) {
    return utils.error('NIKITA_FS_ASSERT_HASH_MATCH', [
      `the ${algo} signatures are matching,`,
      `not expecting to equal ${JSON.stringify(hash)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_MODE_UNMATCH: function({config, mode}) {
    const expect = config.mode.map(function(mode) {
      return pad(4, utils.mode.stringify(mode), '0');
    });
    return utils.error("NIKITA_FS_ASSERT_MODE_UNMATCH", [
      'content permission don\'t match the provided mode,',
      `expect ${expect},`,
      `got ${utils.mode.stringify(mode).slice(-4)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_MODE_MATCH: function({config}) {
    const expect = config.mode.map(function(mode) {
      return pad(4, utils.mode.stringify(mode), '0');
    });
    return utils.error("NIKITA_FS_ASSERT_MODE_MATCH", [
      'the content permission match the provided mode,',
      `not expecting to equal ${expect}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_UID_UNMATCH: function({config, actual}) {
    return utils.error('NIKITA_FS_ASSERT_UID_UNMATCH', [
      'the uid of the target does not match the expected value,',
      `expected ${JSON.stringify(config.uid)},`, `got ${JSON.stringify(actual)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_UID_MATCH: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_UID_MATCH', [
      'the uid of the target  match the provided value,',
      `not expecting to equal ${JSON.stringify(config.uid)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_GID_UNMATCH: function({config, actual}) {
    return utils.error('NIKITA_FS_ASSERT_GID_UNMATCH', [
      'the gid of the target does not match the expected value,',
      `expected ${JSON.stringify(config.uid)},`,
      `got ${JSON.stringify(actual)}.`
    ], {
      target: config.target,
      message: config.error
    });
  },
  NIKITA_FS_ASSERT_GID_MATCH: function({config}) {
    return utils.error('NIKITA_FS_ASSERT_GID_MATCH', [
      'the gid of the target  match the provided value,',
      `not expecting to equal ${JSON.stringify(config.uid)}.`
    ], {
      target: config.target,
      message: config.error
    });
  }
};

// Action
export default {
  handler: async function({config}) {
    // Cached version of `nikita.fs.base.lstat`
    const cache = {}
    const lstat = async (location) => {
      if (cache[location] != null) return cache[location];
      return cache[location] = await this.fs.base.lstat(config.target)
    }
    config.filetype = (function() {
      const results = [];
      for(const filetype of config.filetype ?? []) {
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
              throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID_VALUE({config});
          }
        } else if (typeof filetype === 'number') {
          results.push(filetype);
        } else {
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID_TYPE({config});
        }
      }
      return results;
    })();
    // Asset content string and buffer
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
    // if content is not defined and there is no hash nor mode
    // hash and mode verification are done later, whether the file was updated or not
    if ((config.content == null && !(config.md5 || config.sha1 || config.sha256 || config.mode?.length))) {
      const {exists} = (await this.fs.base.exists(config.target.toString()));
      if (!config.not) {
        if (!exists) {
          throw errors.NIKITA_FS_ASSERT_FILE_MISSING({
            config: config
          });
        }
      } else {
        if (exists) {
          throw errors.NIKITA_FS_ASSERT_FILE_EXISTS({
            config: config
          });
        }
      }
    }
    // Assert file filetype
    if (config.filetype?.length) {
      const {stats} = await lstat(config.target);
      if (config.filetype.includes(fs.constants.S_IFREG) && ! utils.stats.isFile(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'File',
          stats: stats
        });
      }
      if (config.filetype.includes(fs.constants.S_IFDIR) && !utils.stats.isDirectory(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'Directory',
          stats: stats
        });
      }
      if (config.filetype.includes(fs.constants.S_IFCHR) && !utils.stats.isCharacterDevice(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'Character Device',
          stats: stats
        });
      }
      if (config.filetype.includes(fs.constants.S_IFBLK) && !utils.stats.isBlockDevice(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'Block Device',
          stats: stats
        });
      }
      if (config.filetype.includes(fs.constants.S_IFIFO) && !utils.stats.isFIFO(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'FIFO',
          stats: stats
        });
      }
      if (config.filetype.includes(fs.constants.S_IFLNK) && !utils.stats.isSymbolicLink(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'Symbolic Link',
          stats: stats
        });
      }
      if (config.filetype.includes(fs.constants.S_IFSOCK) && !utils.stats.isSocket(stats.mode)) {
        throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID({
          config: config,
          expect: 'Socket',
          stats: stats
        });
      }
    }
    // Assert content equal
    if ((config.content != null) && (typeof config.content === 'string' || Buffer.isBuffer(config.content))) {
      let {data} = (await this.fs.base.readFile(config.target));
      for (const filter of config.filter) {
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
    }
    // Assert content match
    if (config.content != null && config.content instanceof RegExp) {
      let {data} = (await this.fs.base.readFile(config.target));
      for (const filter of config.filter)  {
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
    }
    let hashExpected, algo;
    if (config.md5) {
      // Assert hash match
      // todo, also support config.algo and config.hash
      (algo = 'md5', hashExpected = config.md5);
    }
    if (config.sha1) {
      (algo = 'sha1', hashExpected = config.sha1);
    }
    if (config.sha256) {
      (algo = 'sha256', hashExpected = config.sha256);
    }
    if (algo) {
      const {hash} = (await this.fs.hash(config.target, {
        algo: algo
      }));
      if (!config.not) {
        if (hashExpected !== hash) {
          throw errors.NIKITA_FS_ASSERT_HASH_UNMATCH({
            config: config,
            algo: algo,
            hash: {
              expected: hashExpected,
              actual: hash
            }
          });
        }
      } else {
        if (hashExpected === hash) {
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
      const {stats} = await lstat(config.target);
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
      const {stats} = await lstat(config.target);
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
    if (config.mode?.length) {
      const {stats} = (await lstat(config.target));
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
  },
  hooks: {
    on_action: function({config, metadata}) {
      if (config.filter instanceof RegExp) {
        return config.filter = [config.filter];
      }
    }
  },
  metadata: {
    argument_to_config: 'target',
    definitions: definitions
  }
};
