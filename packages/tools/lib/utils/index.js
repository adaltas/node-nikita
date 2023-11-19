
import utils from "@nikitajs/core/utils";
import { diff } from '@nikitajs/file/utils';
import iptables from '@nikitajs/tools/utils/iptables';

export default {
  ...utils,
  diff: diff,
  iptables: iptables
};
