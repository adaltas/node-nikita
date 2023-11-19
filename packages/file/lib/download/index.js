// Dependencies
import fs from "node:fs";
import url from "node:url";
import utils from "@nikitajs/file/utils";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, ssh, tools: { log, path } }) {
    // Only move the file at the end of action if match is true
    let match = false;
    let algo, source_hash;
    if (config.md5 != null) {
      const md5Type = typeof config.md5;
      if (md5Type !== "string" && md5Type !== "boolean") {
        throw Error(`Invalid MD5 Hash:${config.md5}`);
      }
      algo = "md5";
      source_hash = config.md5;
    } else if (config.sha1 != null) {
      const sha1Type = typeof config.sha1;
      if (sha1Type !== "string" && sha1Type !== "boolean") {
        throw Error(`Invalid SHA-1 Hash:${config.sha1}`);
      }
      algo = "sha1";
      source_hash = config.sha1;
    } else if (config.sha256 != null) {
      const sha256Type = typeof config.sha256;
      if (sha256Type !== "string" && sha256Type !== "boolean") {
        throw Error(`Invalid SHA-256 Hash:${config.sha256}`);
      }
      algo = "sha256";
      source_hash = config.sha256;
    } else {
      algo = "md5";
    }
    const protocols_http = ["http:", "https:"];
    // const protocols_ftp = ["ftp:", "ftps:"];
    if (config.force) {
      log("DEBUG", `Using force: ${JSON.stringify(config.force)}`);
    }
    let source_url = url.parse(config.source);
    if (config.cache == null && source_url.protocol === null) {
      // Disable caching if source is a local file and cache isnt explicitly set by user
      config.cache = false;
    }
    if (config.cache == null) {
      config.cache = !!(config.cache_dir || config.cache_file);
    }
    if (config.http_headers == null) {
      config.http_headers = [];
    }
    if (config.cookies == null) {
      config.cookies = [];
    }
    // Normalization
    config.target = config.cwd
      ? path.resolve(config.cwd, config.target)
      : path.normalize(config.target);
    if (ssh && !path.isAbsolute(config.target)) {
      throw Error(
        `Non Absolute Path: target is ${JSON.stringify(
          config.target
        )}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option`
      );
    }
    // Shortcircuit accelerator:
    // If we know the source signature and if the target file exists
    // we compare it with the target file signature and stop if they match
    if (typeof source_hash === "string") {
      const { shortcircuit } = await this.call(
        {
          $shy: true,
        },
        async function () {
          log("WARN", "Shortcircuit check if provided hash match target");
          try {
            const { hash } = await this.fs.hash(config.target, {
              algo: algo,
            });
            return {
              shortcircuit: !source_hash === hash,
            };
          } catch (error) {
            if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
              throw error;
            }
            return {
              shortcircuit: false,
            };
          }
        }
      );
      if (shortcircuit) {
        return true;
      }
      log("INFO", "Destination with valid signature, download aborted");
    }
    // Download the file and place it inside local cache
    // Overwrite the config.source and source_url properties to make them
    // look like a local file instead of an HTTP URL
    if (config.cache) {
      await this.file.cache({
        // Local file must be readable by the current process
        $ssh: false,
        $sudo: false,
        source: config.source,
        cache_dir: config.cache_dir,
        cache_file: config.cache_file,
        http_headers: config.http_headers,
        cookies: config.cookies,
        md5: config.md5,
        proxy: config.proxy,
        location: config.location,
      });
      source_url = url.parse(config.source);
    }
    try {
      // TODO
      // The current implementation seems inefficient. By modifying stageDestination,
      // we download the file, check the hash, and again treat it the HTTP URL
      // as a local file and check hash again.
      const { stats } = await this.fs.base.stat({
        target: config.target,
      });
      if (utils.stats.isDirectory(stats != null ? stats.mode : void 0)) {
        log("DEBUG", "Destination is a directory");
        config.target = path.join(config.target, path.basename(config.source));
      }
    } catch (error) {
      if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
        throw error;
      }
    }
    const stageDestination = `${config.target}.${Date.now()}${Math.round(
      Math.random() * 1000
    )}`;
    if (protocols_http.includes(source_url.protocol) === true) {
      log("DEBUG", "HTTP download target url");
      // Ensure target directory exists
      await this.fs.mkdir({
        $shy: true,
        target: path.dirname(stageDestination),
      });
      // Download the file
      await this.execute({
        $shy: true,
        command: [
          "curl",
          config.fail ? "--fail" : undefined,
          // todo: add config.insecure
          source_url.protocol === "https:" ? "--insecure" : undefined,
          config.location ? "--location" : undefined,
          ...config.http_headers.map((header) => `--header ${esa(header)}`),
          ...config.cookies.map((cookie) => `--cookie ${esa(cookie)}`),
          `-s ${config.source}`,
          `-o ${stageDestination}`,
          config.proxy ? `-x ${config.proxy}` : void 0,
        ].join(" "),
      });
      const { hash: hash_source } = await this.fs.hash(stageDestination, {
        algo: algo,
      });
      if (typeof source_hash === "string" && source_hash !== hash_source) {
        // Hash validation
        // Probably not the best to check hash, it only applies to HTTP for now
        throw Error(
          `Invalid downloaded checksum, found '${hash_source}' instead of '${source_hash}'`
        );
      }
      const { exists } = await this.fs.base.exists({
        target: config.target,
      });
      const { hash: hash_target } =
        exists &&
        (await this.fs.hash({
          target: config.target,
          algo: algo,
        }));
      match = hash_source === hash_target;
      match
        ? log("INFO", `Hash matches as "${hash_source}".`)
        : log(
            "WARN",
            `Hash dont match, source is "${hash_source}" and target is "${hash_target}".`
          );
      if (match) {
        await this.fs.remove({
          $shy: true,
          target: stageDestination,
        });
      }
    } else if (protocols_http.includes(source_url.protocol) === false && !ssh) {
      log("DEBUG", `File download without ssh (cache ${
          config.cache ? "enabled" : "disabled"
        })`);
      const { hash: hash_source } = await this.fs.hash({
        target: config.source,
        algo: algo,
      });
      const { exists } = await this.fs.base.exists({
        target: config.target,
      });
      const { hash: hash_target } =
        exists &&
        (await this.fs.hash({
          target: config.target,
          algo: algo,
        }));
      match = hash_source === hash_target;
      match
        ? log("INFO", `Hash matches as "${hash_source}'`)
        : log(
            "WARN",
            `Hash dont match, source is "${hash_source}" and target is "${hash_target}"`
          );
      if (!match) {
        await this.fs.mkdir({
          $shy: true,
          target: path.dirname(stageDestination),
        });
        await this.fs.copy({
          source: config.source,
          target: stageDestination,
        });
      }
    } else if (protocols_http.includes(source_url.protocol) === false && ssh) {
      log("DEBUG", `File download with ssh (cache ${
          config.cache ? "enabled" : "disabled"
        })`);
      const { hash: hash_source } = await this.fs.hash({
        $ssh: false,
        $sudo: false,
        target: config.source,
        algo: algo,
      });
      const { exists } = await this.fs.base.exists({
        target: config.target,
      });
      const { hash: hash_target } =
        exists &&
        (await this.fs.hash({
          target: config.target,
          algo: algo,
        }));
      match = hash_source === hash_target;
      match
        ? log("INFO", `Hash matches as "${hash_source}".`)
        : log(
            "WARN",
            `Hash dont match, source is "${hash_source}" and target is "${hash_target}".`
          );
      if (!match) {
        await this.fs.mkdir({
          $shy: true,
          target: path.dirname(stageDestination),
        });
        try {
          await this.fs.base.createWriteStream({
            target: stageDestination,
            stream: function (ws) {
              return fs.createReadStream(config.source).pipe(ws);
            },
          });
          log(
            "INFO",
            `Downloaded local source ${JSON.stringify(
              config.source
            )} to remote target ${JSON.stringify(stageDestination)}.`
          );
        } catch (error) {
          log(
            "ERROR",
            `Downloaded local source ${JSON.stringify(
              config.source
            )} to remote target ${JSON.stringify(stageDestination)} failed.`
          );
          throw error;
        }
      }
    }
    log("DEBUG", "Unstage downloaded file");
    if (!match) {
      await this.fs.move({
        source: stageDestination,
        target: config.target,
      });
    }
    if (config.mode) {
      await this.fs.chmod({
        target: config.target,
        mode: config.mode,
      });
    }
    if (config.uid || config.gid) {
      await this.fs.chown({
        target: config.target,
        uid: config.uid,
        gid: config.gid,
      });
    }
  },
  hooks: {
    on_action: async function ({ config, tools: { find } }) {
      config.cache = await find(({ config: { cache } }) => cache);
      config.cache_file = await find(
        ({ config: { cache_file } }) => cache_file
      );
      config.cache_dir = await find(({ config: { cache_dir } }) => cache_dir);
      if (/^file:\/\//.test(config.source)) {
        return (config.source = config.source.substr(7));
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
