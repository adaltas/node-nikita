import util from "util";
import each from "each";

const array_filter = async function (items, concurrency, handler) {
  const fail = Symbol();
  return (
    await each(items, concurrency, async (item) => ((await handler(item)) ? item : fail))
  ).filter((i) => i !== fail);
};

const is = function (obj) {
  return util.types.isPromise(obj);
};

export { array_filter, is };

export default {
  array_filter: array_filter,
  is: is,
};
