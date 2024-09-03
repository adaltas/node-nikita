// Dependencies
import utils from "@nikitajs/core/utils";

export default function (err, stderr) {
  stderr = stderr.trim();
  if (utils.string.lines(stderr).length === 1) {
    return (err.message = stderr);
  }
}
