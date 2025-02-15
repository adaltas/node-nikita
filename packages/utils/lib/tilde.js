import path from "node:path";
import tilde from "tilde-expansion";

/*
Not, those function are not aware of an SSH connection
and can't use `path.posix` when appropriate over SSH.
It could be assumed that a path starting with `~` is 
always posix but this is not yet handled and tested.
*/

const normalize = function (location) {
  return new Promise(function (accept) {
    return tilde(location, function (location) {
      return accept(path.normalize(location));
    });
  });
};

const resolve = async function (...locations) {
  const normalized = locations.map(normalize);
  const paths = await Promise.all(normalized);
  return path.resolve(...paths);
};

export { normalize, resolve };

export default {
  normalize: normalize,
  resolve: resolve,
};
