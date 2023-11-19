import utils from "@nikitajs/core/utils";
import cgconfig from "@nikitajs/system/utils/cgconfig";
import tmpfs from "@nikitajs/system/utils/tmpfs";

export default {
  ...utils,
  cgconfig: cgconfig,
  tmpfs: tmpfs,
};
