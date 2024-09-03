import util from "node:util";
import each from "each";

const array_filter = async function (items, concurrency, handler) {
  const fail = Symbol();
  return (
    await each(items, concurrency, async (item) =>
      (await handler(item)) ? item : fail,
    )
  ).filter((i) => i !== fail);
};

const is = function (obj) {
  return util.types.isPromise(obj);
};

const withResolvers = function () {
  let resolve, reject;
  const promise = new Promise((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, reject, resolve };
};

export { array_filter, is, withResolvers };

export default {
  array_filter: array_filter,
  is: is,
  withResolvers: withResolvers,
};
