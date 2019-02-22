// Generated by CoffeeScript 2.3.2
var constants;

module.exports = {
  // new: (stat)
  //   Stats = (stat) ->
  //     @mode = stat && stat.mode
  //     @uid = stat && stat.uid
  //     @gid = stat && stat.gid
  //     @size = stat && stat.size
  //     @atime = stat && stat.atime
  //     @mtime = stat && stat.mtime
  //   Stats.prototype._checkModeProperty = (property) ->
  //     (this.mode & constants.S_IFMT) is property
  //   Stats.prototype.isDirectory = ->
  //     @_checkModeProperty constants.S_IFDIR
  //   Stats.prototype.isFile = ->
  //     @_checkModeProperty constants.S_IFREG
  //   Stats.prototype.isBlockDevice = ->
  //     @_checkModeProperty constants.S_IFBLK
  //   Stats.prototype.isCharacterDevice = ->
  //     @_checkModeProperty constants.S_IFCHR
  //   Stats.prototype.isSymbolicLink = ->
  //     @_checkModeProperty constants.S_IFLNK
  //   Stats.prototype.isFIFO = ->
  //     @_checkModeProperty constants.S_IFIFO
  //   Stats.prototype.isSocket = ->
  //     @_checkModeProperty constants.S_IFSOCK
  isDirectory: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFDIR;
  },
  isFile: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFREG;
  },
  isBlockDevice: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFBLK;
  },
  isCharacterDevice: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFCHR;
  },
  isSymbolicLink: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFLNK;
  },
  isFIFO: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFIFO;
  },
  isSocket: function(mode) {
    return (mode & constants.S_IFMT) === constants.S_IFSOCK;
  },
  type: function(mode) {
    if (this.isDirectory(mode)) {
      return 'Directory';
    } else if (this.isFile(mode)) {
      return 'File';
    } else if (this.isBlockDevice(mode)) {
      return 'Block Device';
    } else if (this.isCharacterDevice(mode)) {
      return 'Character Device';
    } else if (this.isSymbolicLink(mode)) {
      return 'Symbolic Link';
    } else if (this.isFIFO(mode)) {
      return 'FIFO';
    } else if (this.isSocket(mode)) {
      return 'Socket';
    } else {
      return 'Unknown';
    }
  }
};

//# Dependencies
constants = require('fs').constants;
