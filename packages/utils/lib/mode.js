/*
Compare multiple mode. All arguments modes must match. If first mode is any array, then
other arguments mode must much at least one element of the array.
*/
const compare = function (...modes) {
  let ref = modes[0];
  if (ref == null) {
    throw Error(`Invalid mode: ${ref}`);
  }
  if (!Array.isArray(ref)) {
    ref = [ref];
  }
  ref = ref.map((mode) => this.stringify(mode));
  for (let i = 1; i < modes.length; i++) {
    const mode = this.stringify(modes[i]);
    if (
      !ref.some( (m) => {
        const l = Math.min(m.length, mode.length);
        return m.slice(-l) === mode.slice(-l);
      })
    ) {
      return false;
    }
  }
  return true;
};

const stringify = function (mode) {
  return typeof mode === "number" ? mode.toString(8) : mode;
};

export { compare, stringify };

export default {
  compare: compare,
  stringify: stringify,
};
