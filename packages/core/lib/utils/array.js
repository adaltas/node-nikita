
const test = function(arr, depth = -1) {
  var i, k, ref, ret;
  ret = [];
  for (i = k = 0, ref = arr.length; (0 <= ref ? k < ref : k > ref); i = 0 <= ref ? ++k : --k) {
    if (Array.isArray(arr[i])) {
      if (depth === 0) {
        ret.push(...arr[i]);
      } else {
        ret.push(...test(arr[i], depth - 1));
      }
    } else {
      ret.push(arr[i]);
    }
  }
  return ret;
};
module.exports = {
  // compare: (array1, array2) ->
  //   # compare lengths - can save a lot of time
  //   if array1.length isnt array2.length
  //     return false
  //   for i in [0...array1.length]
  //     # Check if we have nested arrays
  //     if Array.isArray(array1[i]) and Array.isArray(array2[i])
  //       # recurse into the nested arrays
  //       if !array1[i].equals array2[i]
  //         return false
  //     else if array1[i] != array2[i]
  //         # Warning - two different object instances will never be equal: {x:20} != {x:20}
  //         return false
  //   return true
  clone: function(arr) {
    var el, i, k, len, ret;
    ret = [arr.length];
    for (i = k = 0, len = arr.length; k < len; i = ++k) {
      el = arr[i];
      ret[i] = el;
    }
    return ret;
  },
  intersect: function(array) {
    var argument, i, item, j, k, l, len, len1, result;
    if (array === null) {
      return [];
    }
    result = [];
    for (i = k = 0, len = array.length; k < len; i = ++k) {
      item = array[i];
      if (result.indexOf(item) !== -1) {
        continue;
      }
      for (j = l = 0, len1 = arguments.length; l < len1; j = ++l) {
        argument = arguments[j];
        if (argument.indexOf(item) === -1) {
          break;
        }
      }
      if (j === arguments.length) {
        result.push(item);
      }
    }
    return result;
  },
  flatten: function(arr, depth=Infinity) {
    if(depth === -1){ depth = Infinity}
    return arr.flat(depth)
  },
  // flatten: function(arr, depth = -1) {
  //   var i, k, ref, ret;
  //   ret = [];
  //   for (i = k = 0, ref = arr.length; (0 <= ref ? k < ref : k > ref); i = 0 <= ref ? ++k : --k) {
  //     if (Array.isArray(arr[i])) {
  //       if (depth === 0) {
  //         ret.push(...arr[i]);
  //       } else {
  //         ret.push(...module.exports.flatten(arr[i], depth - 1));
  //       }
  //     } else {
  //       ret.push(arr[i]);
  //     }
  //   }
  //   return ret;
  // },
  multiply: function(...args) {
    // Convert every argument to an array
    for (let i = 0; i < args.length; i++) {
      const arg = args[i];
      if (!Array.isArray(arg)) {
        args[i] = [arg];
      }
    }
    // Multiply arguments
    let results = [];
    for (let i = 0; i < args.length; i++) {
      const arg = args[i];
      const newresults = (function() {
        const results1 = [];
        for (let j = 0; j < arg.length; j++) {
          const arg_element = arg[j];
          // Every element of the first argument will initialize results
          if (i === 0) {
            results1.push([[arg_element]]);
          } else {
            results1.push((function() {
              const results2 = [];
              for (let i = 0; i < results.length; i++) {
                const action = results[i];
                results2.push([...action, arg_element]);
              }
              return results2;
            })());
          }
        }
        return results1;
      })();
      results = newresults.flat(1);
    }
    return results;
  },
  merge: function(...arrays) {
    const r = [];
    for (const array of arrays) {
      for (const el of array) {
        r.push(el);
      }
    }
    return r;
  },
  shuffle: function(a) {
    if (a.length <= 1) {
      return a;
    }
    for (i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  },
  unique: function(array) {
    const obj = {};
    for (let el of array) {
      obj[el] = true;
    }
    return Object.keys(obj);
  }
};
