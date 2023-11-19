import util from "util";

const array_filter = async function (arr, handler) {
  const fail = Symbol();
  return (
    await Promise.all(
      arr.map(async (item) => ((await handler(item)) ? item : fail))
    )
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
