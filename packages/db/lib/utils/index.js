import utils from "@nikitajs/core/utils";
import db from "@nikitajs/db/utils/db";

export { db };

export default {
  ...utils,
  db: db,
};
