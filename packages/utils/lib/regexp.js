
import quote from 'regexp-quote';

// Escape RegExp related charracteres
// eg `///^\*/\w+@#{misc.regexp.escape realm}\s+\*///mg`
const escape = function(str) {
  return str.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
};

const is = function(reg) {
  return reg instanceof RegExp;
};

export { escape, is, quote };

export default {
  escape: escape,
  is: is,
  quote: quote
};
