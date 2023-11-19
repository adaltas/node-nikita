import { constants } from "fs";

const isDirectory = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFDIR;
};

const isFile = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFREG;
};

const isBlockDevice = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFBLK;
};

const isCharacterDevice = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFCHR;
};

const isSymbolicLink = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFLNK;
};

const isFIFO = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFIFO;
};

const isSocket = function (mode) {
  return (mode & constants.S_IFMT) === constants.S_IFSOCK;
};

const type = function (mode) {
  if (this.isDirectory(mode)) {
    return "Directory";
  } else if (this.isFile(mode)) {
    return "File";
  } else if (this.isBlockDevice(mode)) {
    return "Block Device";
  } else if (this.isCharacterDevice(mode)) {
    return "Character Device";
  } else if (this.isSymbolicLink(mode)) {
    return "Symbolic Link";
  } else if (this.isFIFO(mode)) {
    return "FIFO";
  } else if (this.isSocket(mode)) {
    return "Socket";
  } else {
    return "Unknown";
  }
};

export {
  isDirectory,
  isFile,
  isBlockDevice,
  isCharacterDevice,
  isSymbolicLink,
  isFIFO,
  isSocket,
  type,
};

export default {
  isDirectory: isDirectory,
  isFile: isFile,
  isBlockDevice: isBlockDevice,
  isCharacterDevice: isCharacterDevice,
  isSymbolicLink: isSymbolicLink,
  isFIFO: isFIFO,
  isSocket: isSocket,
  type: type,
};
