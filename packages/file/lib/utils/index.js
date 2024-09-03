import utils from "@nikitajs/core/utils";
import diff from "@nikitajs/file/utils/diff";
import hfile from "@nikitajs/file/utils/hfile";
import ini from "@nikitajs/file/utils/ini";
import partial from "@nikitajs/file/utils/partial";

export { diff, hfile, ini, partial };

export default {
  ...utils,
  diff: diff,
  hfile: hfile,
  ini: ini,
  partial: partial,
};
