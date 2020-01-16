// Generated by CoffeeScript 2.5.0
  // `nikita.file.types.locale_gen`

// Update the locale definition file located in "/etc/locale.gen".

// ## Options

// *   `rootdir` (string)   
  //     Path to the mount point corresponding to the root directory, optional.
  // *   `generate` (boolean, optional, null)   
  //     Run `locale-gen` by default if target was modified or force running the
  //     command if value is a boolean.
  // *   `locales` (string)   
  //     List of supported locales, required.
  // *   `target` (string)   
  //     File to write, default to "/etc/locale.gen".

// ## Example

// ```javascript
  // require('nikita')
  // .file.types.locale_gen({
  //   target: '/etc/locale.gen',
  //   rootdir: '/mnt',
  //   locales: ['fr_FR.UTF-8', 'en_US.UTF-8'],
  //   locale: 'en_US.UTF-8'
  // })
  // ```
var path,
  indexOf = [].indexOf;

module.exports = function({options}) {
  this.log({
    message: "Entering file.types.local_gen",
    level: 'DEBUG',
    module: 'nikita/lib/file/types/local_gen'
  });
  // Options
  if (options.target == null) {
    options.target = '/etc/locale.gen';
  }
  if (options.rootdir) {
    options.target = `${path.join(options.rootdir, options.target)}`;
  }
  if (options.generate == null) {
    options.generate = null;
  }
  // Write configuration
  this.call(function({}, callback) {
    return this.fs.readFile({
      ssh: options.ssh,
      target: options.target,
      encoding: 'ascii'
    }, function(err, {data}) {
      var i, j, len, locale, locales, match, ref, ref1, status;
      if (err) {
        return callback(err);
      }
      status = false;
      locales = data.split('\n');
      for (i = j = 0, len = locales.length; j < len; i = ++j) {
        locale = locales[i];
        if (match = /^#([\w_\-\.]+)($| .+$)/.exec(locale)) {
          if (ref = match[1], indexOf.call(options.locales, ref) >= 0) {
            locales[i] = match[1] + match[2];
            status = true;
          }
        }
        if (match = /^([\w_\-\.]+)($| .+$)/.exec(locale)) {
          if (ref1 = match[1], indexOf.call(options.locales, ref1) < 0) {
            locales[i] = '#' + match[1] + match[2];
            status = true;
          }
        }
      }
      if (!status) {
        return callback();
      }
      data = locales.join('\n');
      return this.fs.writeFile({
        ssh: options.ssh,
        target: options.target,
        content: data
      }, function(err) {
        return callback(err, true);
      });
    });
  });
  // Reload configuration
  return this.system.execute({
    if: function() {
      if (options.generate != null) {
        return options.generate;
      } else {
        return this.status(-1);
      }
    },
    cmd: "locale-gen"
  });
};

// ## Dependencies
path = require('path');
