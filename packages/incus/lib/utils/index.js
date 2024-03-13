// Dependencies
import utils from "@nikitajs/core/utils";
import stderr_to_error_message from '@nikitajs/incus/utils/stderr_to_error_message';

export default {
  ...utils,
  stderr_to_error_message: stderr_to_error_message
};
