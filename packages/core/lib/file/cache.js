// Generated by CoffeeScript 2.5.0
  // # `nikita.file.cache`

// Download a file and place it on a local or remote folder for later usage.

// ## Options

// * `cache_dir` (path)   
  //   Path of the cache directory.
  // * `cache_file` (string | boolean)
  //   Alias for "target".
  // * `cache_local` (boolean)   
  //   Apply to SSH mode, treat the cache file and directories as local from where
  //   the command is used instead of over SSH.
  // * `cookies` (array)   
  //   Extra cookies  to include in the request when sending HTTP to a server.
  // * `fail` (boolean)   
  //   Send an error if the HTTP response code is invalid. Similar to the curl
  //   option of the same name.
  // * `force` (boolean)   
  //   Overwrite the target file if it exists, bypass md5 verification.
  // * `http_headers` (array)   
  //   Extra header  to include in the request when sending HTTP to a server.
  // * `location` (boolean)   
  //   If the server reports that the requested page has moved to a different
  //   location (indicated with a Location: header and a 3XX response code), this
  //   option will make curl redo the request on the new place.
  // * `proxy` (string)   
  //   Use the specified HTTP proxy. If the port number is not specified, it is
  //   assumed at port 1080. See curl(1) man page.
  // * `source` (path)   
  //   File, HTTP URL, FTP, GIT repository. File is the default protocol if source
  //   is provided without any.
  // * `target` (string | boolean)   
  //   Cache the file on the executing machine, equivalent to cache unless an ssh
  //   connection is provided. If a string is provided, it will be the cache path.
  //   Default to the basename of source.

// ## Callback Parameters

// * `err`   
  //   Error object if any.   
  // * `status`   
  //   Value is "true" if cache file was created or modified.   

// ## HTTP example

// Cache can be used from the `file.download` action:

// ```js
  // require('nikita')
  // .file.download({
  //   source: 'https://github.com/wdavidw/node-nikita/tarball/v0.0.1',
  //   cache_dir: '/var/tmp'
  // }, function(err, {status}){
  //   console.info(err ? err.message : 'File downloaded: ' + status);
  // });
  // ```

// ## Source Code
var curl, path, protocols_ftp, protocols_http, url,
  indexOf = [].indexOf;

module.exports = function({metadata, options}, callback) {
  var _hash, algo, cookie, header, ref, ref1, ref2, ref3, ssh, u;
  this.log({
    message: "Entering file.cache",
    level: 'DEBUG',
    module: 'nikita/lib/file/cache'
  });
  // SSH connection
  ssh = this.ssh(options.ssh);
  if (metadata.argument != null) {
    // Options
    options.source = metadata.argument;
  }
  if (!options.source) {
    throw Error(`Missing source: '${options.source}'`);
  }
  if (!(options.cache_file || options.target || options.cache_dir)) {
    throw Error("Missing one of 'target', 'cache_file' or 'cache_dir' option");
  }
  if (options.target == null) {
    options.target = options.cache_file;
  }
  if (options.target == null) {
    options.target = path.basename(options.source);
  }
  options.target = path.resolve(options.cache_dir, options.target);
  if (/^file:\/\//.test(options.source)) {
    options.source = options.source.substr(7);
  }
  if (options.http_headers == null) {
    options.http_headers = [];
  }
  if (options.cookies == null) {
    options.cookies = [];
  }
  // todo, also support options.algo and options.hash
  if (options.md5 != null) {
    if ((ref = typeof options.md5) !== 'string' && ref !== 'boolean') {
      throw Error(`Invalid MD5 Hash:${options.md5}`);
    }
    algo = 'md5';
    _hash = options.md5;
  } else if (options.sha1 != null) {
    if ((ref1 = typeof options.sha1) !== 'string' && ref1 !== 'boolean') {
      throw Error(`Invalid SHA-1 Hash:${options.sha1}`);
    }
    algo = 'sha1';
    _hash = options.sha1;
  } else if (options.sha256 != null) {
    if ((ref2 = typeof options.sha256) !== 'string' && ref2 !== 'boolean') {
      throw Error(`Invalid SHA-1 Hash:${options.sha256}`);
    }
    algo = 'sha256';
    _hash = options.sha256;
  } else {
    algo = 'md5';
    _hash = false;
  }
  u = url.parse(options.source);
  this.call(function(_, callback) {
    if (u.protocol !== null) {
      this.log({
        message: "Bypass source hash computation for non-file protocols",
        level: 'WARN',
        module: 'nikita/lib/file/cache'
      });
      return callback();
    }
    if (_hash !== true) {
      return callback();
    }
    return this.file.hash(options.source, function(err, {hash}) {
      if (err) {
        return callback(err);
      }
      this.log({
        message: `Computed hash value is '${hash}'`,
        level: 'INFO',
        module: 'nikita/lib/file/cache'
      });
      _hash = hash;
      return callback();
    });
  });
  // Download the file if
  // - file doesnt exist
  // - option force is provided
  // - hash isnt true and doesnt match
  this.call({
    shy: true
  }, function({}, callback) {
    this.log({
      message: `Check if target (${options.target}) exists`,
      level: 'DEBUG',
      module: 'nikita/lib/file/cache'
    });
    return this.fs.exists({
      target: options.target
    }, (err, {exists}) => {
      if (err) {
        return callback(err);
      }
      if (exists) {
        this.log({
          message: "Target file exists",
          level: 'INFO',
          module: 'nikita/lib/file/cache'
        });
        // If no checksum , we ignore MD5 check
        if (options.force) {
          this.log({
            message: "Force mode, cache will be overwritten",
            level: 'DEBUG',
            module: 'nikita/lib/file/cache'
          });
          return callback(null, true);
        } else if (_hash && typeof _hash === 'string') {
          // then we compute the checksum of the file
          this.log({
            message: `Comparing ${algo} hash`,
            level: 'DEBUG',
            module: 'nikita/lib/file/cache'
          });
          return this.file.hash(options.target, (err, {hash}) => {
            if (err) {
              return callback(err);
            }
            // And compare with the checksum provided by the user
            if (_hash === hash) {
              this.log({
                message: "Hashes match, skipping",
                level: 'DEBUG',
                module: 'nikita/lib/file/cache'
              });
              return callback(null, false);
            }
            this.log({
              message: "Hashes don't match, delete then re-download",
              level: 'WARN',
              module: 'nikita/lib/file/cache'
            });
            return this.fs.unlink({
              target: options.target
            }, function(err) {
              if (err) {
                return callback(err);
              }
              return callback(null, true);
            });
          });
        } else {
          this.log({
            message: "Target file exists, check disabled, skipping",
            level: 'DEBUG',
            module: 'nikita/lib/file/cache'
          });
          return callback(null, false);
        }
      } else {
        this.log({
          message: "Target file does not exists",
          level: 'INFO',
          module: 'nikita/lib/file/cache'
        });
        return callback(null, true);
      }
    });
  }, function(err, {status}) {
    if (!status) {
      return this.end();
    }
  });
  // Place into cache
  if (ref3 = u.protocol, indexOf.call(protocols_http, ref3) >= 0) {
    this.system.mkdir({
      ssh: options.cache_local ? false : options.ssh,
      target: path.dirname(options.target)
    });
    this.system.execute({
      cmd: [
        'curl',
        options.fail ? '--fail' : void 0,
        u.protocol === 'https:' ? '--insecure' : void 0,
        options.location ? '--location' : void 0,
        ...((function() {
          var i,
        len,
        ref4,
        results;
          ref4 = options.http_headers;
          results = [];
          for (i = 0, len = ref4.length; i < len; i++) {
            header = ref4[i];
            results.push(`--header '${header.replace('\'',
        '\\\'')}'`);
          }
          return results;
        })()),
        ...((function() {
          var i,
        len,
        ref4,
        results;
          ref4 = options.cookies;
          results = [];
          for (i = 0, len = ref4.length; i < len; i++) {
            cookie = ref4[i];
            results.push(`--cookie '${cookie.replace('\'',
        '\\\'')}'`);
          }
          return results;
        })()),
        `-s ${options.source}`,
        `-o ${options.target}`,
        options.proxy ? `-x ${options.proxy}` : void 0
      ].join(' '),
      ssh: options.cache_local ? false : options.ssh,
      unless_exists: options.target
    });
  } else {
    this.system.mkdir({ // todo: copy shall handle this
      target: `${path.dirname(options.target)}`
    });
    this.system.copy({
      source: `${options.source}`,
      target: `${options.target}`
    });
  }
  // Validate the cache
  this.file.hash({
    target: options.target,
    if: _hash
  }, function(err, {status, hash}) {
    if (err) {
      throw err;
    }
    if (!status) {
      return;
    }
    if (_hash !== hash) {
      throw Error(`Invalid Target Hash: target ${JSON.stringify(options.target)} got ${hash} instead of ${_hash}`);
    }
  });
  return this.next(function(err, {status}) {
    return callback(err, {
      status: status,
      target: options.target
    });
  });
};

module.exports.protocols_http = protocols_http = ['http:', 'https:'];

module.exports.protocols_ftp = protocols_ftp = ['ftp:', 'ftps:'];

// ## Dependencies
path = require('path');

url = require('url');

curl = require('../misc/curl');
