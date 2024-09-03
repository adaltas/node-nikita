/*
Default in-memory engine implementation.
*/

// Plugin
export default function () {
  const store = {};
  return {
    set: function (key, value) {
      if (store[key] == null) {
        store[key] = {};
      }
      store[key].value = value;
      if (store[key].promises == null) {
        store[key].promises = [];
      }
      let promise;
      while ((promise = store[key].promises.shift())) {
        promise.call(null, store[key].value);
      }
    },
    get: function (key) {
      return new Promise(function (resolve) {
        if (store[key]?.value) {
          resolve(store[key].value);
        } else {
          if (store[key] == null) {
            store[key] = {};
          }
          if (store[key].promises == null) {
            store[key].promises = [];
          }
          store[key].promises.push(resolve);
        }
      });
    },
  };
}
