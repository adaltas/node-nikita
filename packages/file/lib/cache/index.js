// Dependencies
import path from "node:path";
import url from "node:url";
import utils from "@nikitajs/file/utils";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Errors
const errors = {
  NIKITA_FILE_INVALID_TARGET_HASH: function ({ config, hash, _hash }) {
    return utils.error("NIKITA_FILE_INVALID_TARGET_HASH", [
      `target ${JSON.stringify(config.target)} got ${JSON.stringify(hash)} instead of ${JSON.stringify(_hash)}.`,
    ]);
  },
};

const protocols_http = ["http:", "https:"];
const protocols_ftp = ["ftp:", "ftps:"];

export { protocols_http, protocols_ftp };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (config.target == null) {
      config.target = config.cache_file;
    }
    if (config.target == null) {
      config.target = path.basename(config.source);
    }
    config.target = path.resolve(config.cache_dir, config.target);
    if (/^file:\/\//.test(config.source)) {
      config.source = config.source.slice(7);
    }
    // todo, also support config.algo and config.hash
    // replace alog and _hash with
    // config.algo = null
    // config.hash = false
    let algo, _hash;
    if (config.md5 != null) {
      algo = "md5";
      _hash = config.md5;
    } else if (config.sha1 != null) {
      algo = "sha1";
      _hash = config.sha1;
    } else if (config.sha256 != null) {
      algo = "sha256";
      _hash = config.sha256;
    } else {
      algo = "md5";
      _hash = false;
    }
    const u = url.parse(config.source);
    if (u.protocol !== null) {
      log("WARN", "Bypass source hash computation for non-file protocols");
    } else {
      if (_hash === true) {
        _hash = await this.fs.hash(config.source);
        _hash =
          (
            _hash != null ? _hash.hash : void 0
          ) ?
            _hash.hash
          : false;
        log("INFO", `Computed hash value is '${_hash}'`);
      }
    }
    // Download the file if
    // - file doesnt exist
    // - option force is provided
    // - hash isnt true and doesnt match
    const { $status } = await this.call(async function () {
      log("DEBUG", `Check if target (${config.target}) exists`);
      const { exists } = await this.fs.exists({
        target: config.target,
      });
      if (exists) {
        log("INFO", "Target file exists");
        // If no checksum, we ignore MD5 check
        if (config.force) {
          log("DEBUG", "Force mode, cache will be overwritten");
          return true;
        } else if (_hash && typeof _hash === "string") {
          // then we compute the checksum of the file
          log("DEBUG", `Comparing ${algo} hash`);
          const { hash } = await this.fs.hash(config.target);
          // And compare with the checksum provided by the user
          if (_hash === hash) {
            log("DEBUG", "Hashes match, skipping");
            return false;
          }
          log({
            message: "Hashes don't match, delete then re-download",
            level: "WARN",
          });
          await this.fs.unlink({
            target: config.target,
          });
          return true;
        } else {
          log("DEBUG", "Target file exists, check disabled, skipping");
          return false;
        }
      } else {
        log("INFO", "Target file does not exists");
        return true;
      }
    });
    if (!$status) {
      return $status;
    }
    // Place into cache
    if (protocols_http.includes(u.protocol) === true) {
      await this.fs.mkdir({
        $ssh: config.cache_local ? false : void 0,
        target: path.dirname(config.target),
      });
      await this.execute({
        $ssh: config.cache_local ? false : void 0,
        $unless_exists: config.target,
        command: [
          "curl",
          config.fail ? "--fail" : void 0,
          u.protocol === "https:" && "--insecure",
          config.location && "--location",
          ...config.http_headers.map((header) => `--header ${esa(header)}`),
          ...config.cookies.map((cookie) => `--cookie ${esa(cookie)}`),
          `-s ${config.source}`,
          `-o ${config.target}`,
          config.proxy ? `-x ${config.proxy}` : void 0,
        ]
          .filter(Boolean)
          .join(" "),
      });
    } else {
      await this.fs.mkdir({
        // todo: copy shall handle this
        target: `${path.dirname(config.target)}`,
      });
      await this.fs.copy({
        source: `${config.source}`,
        target: `${config.target}`,
      });
    }
    // Validate the cache
    let { hash } = await this.fs.hash({
      $if: _hash,
      target: config.target,
    });
    if (hash == null) {
      hash = false;
    }
    if (_hash !== hash) {
      throw errors.NIKITA_FILE_INVALID_TARGET_HASH({
        config: config,
        hash: hash,
        _hash: _hash,
      });
    }
    return {};
  },
  metadata: {
    argument_to_config: "source",
    definitions: definitions,
  },
};
