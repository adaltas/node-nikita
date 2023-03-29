
const util = require('util')

module.exports = {
  array_filter: async function(arr, handler) {
    const fail = Symbol();
    return (
      await Promise.all(
        arr.map(async function(item) {
          if (await handler(item)) {
            return item;
          } else {
            return fail;
          }
        })
      )
    ).filter(function(i) {
      return i !== fail;
    });
  },
  is: function(obj) {
    // return !!obj && (typeof obj === 'object' || typeof obj === 'function') && typeof obj.then === 'function';
    return util.types.isPromise(obj)
  }
};
