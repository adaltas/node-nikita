import { merge } from "mixme";
import connect from "ssh2-connect";
import { whoami } from "./os.js";
import { hash as hash_str } from "./string.js";

const compare = function (ssh1, ssh2) {
  // Between 2 configurations
  const compare_config = function (config1, config2) {
    return (
      config1 &&
      config2 &&
      config1.host === config2.host &&
      (config1.port || 22) === (config2.port || 22) &&
      config1.username === config2.username
    );
  };
  if (!ssh1 && !ssh2 && !!ssh1 === !!ssh2) {
    // 2 null
    return true;
  }
  const config1 = this.is(ssh1) ? ssh1.config : merge(ssh1);
  const config2 = this.is(ssh2) ? ssh2.config : merge(ssh2);
  if (config1.username == null) {
    config1.username = whoami();
  }
  if (config2.username == null) {
    config2.username = whoami();
  }
  return compare_config(config1, config2);
};

const is = function (ssh) {
  return connect.is(ssh);
};

const hash = function (ssh) {
  return hash_str(JSON.stringify(ssh.config));
};

export { compare, is, hash };

export default {
  compare: compare,
  is: is,
  hash: hash,
};
