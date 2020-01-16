// Generated by CoffeeScript 2.5.0
// `nikita.file.types.pacman_conf`

// Pacman is a package manager utility for Arch Linux. The file is usually located 
// in "/etc/pacman.conf".

// ## Options

// * `rootdir` (string, optional, undefined)   
//   Path to the mount point corresponding to the root directory, optional.
// * `backup` (string|boolean, optional, false)   
//   Create a backup, append a provided string to the filename extension or a
//   timestamp if value is not a string, only apply if the target file exists and
//   is modified.
// * `clean` (boolean, optional, false)   
//   Remove all the lines whithout a key and a value, default to "true".
// * `content` (object, required)   
//   Object to stringify.
// * `merge` (boolean, optional, false)   
//   Read the target if it exists and merge its content.
// * `target` (string, optional, "/etc/pacman.conf")   
//   Destination file.

// ## Source Code
var misc, path;

module.exports = function({options}) {
  this.log({
    message: "Entering file.types.pacman_conf",
    level: 'DEBUG',
    module: 'nikita/lib/file/types/pacman_conf'
  });
  if (options.target == null) {
    options.target = '/etc/pacman.conf';
  }
  if (options.rootdir) {
    options.target = `${path.join(options.rootdir, options.target)}`;
  }
  return this.file.ini({
    stringify: misc.ini.stringify_single_key
  }, options);
};

// ## Dependencies
path = require('path');

misc = require('@nikitajs/core/lib/misc');
