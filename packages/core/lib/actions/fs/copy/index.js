// Dependencies
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { $status, log, path } }) {
    // Retrieve stats information about the source unless provided through the "source_stats" option.
    const source_stats = await (async () => {
      if (config.source_stats) {
        log("DEBUG", "Source Stats: using short circuit");
        return config.source_stats;
      }
      log("DEBUG", `Stats source file ${config.source}`);
      return await this.fs.stat({
        target: config.source,
      }).then( ({stats}) => stats);
    })();
    // Retrieve stat information about the traget unless provided through the "target_stats" option.
    const target_stats = await (async () => {
      if (config.target_stats) {
        log("DEBUG", "Target Stats: using short circuit");
        return config.target_stats;
      }
      log("DEBUG", `Stats target file ${config.target}`);
      return await this.fs
        .stat({
          target: config.target,
        })
        .then(({ stats }) => stats)
        .catch((error) => {
          if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
            // Target file doesn't necessarily exist
            throw error;
          }
        });
    })();
    // Create target parent directory if target does not exists and if the "parent"
    // config is set to "true" (default) or as an object.
    await this.fs.mkdir({
      $if: !!config.parent,
      $unless: target_stats,
      $shy: true,
      target: path.dirname(config.target),
      ...config.parent,
    });
    // Stop here if source is a directory. We traverse all its children
    // Recursively, calling either `fs.mkdir` or `fs.copy`.
    // Like with the Unix `cp` command, ending slash matters if the target directory
    // exists. Let's consider a source directory "/tmp/a_source" and a target directory
    // "/tmp/a_target". Without an ending slash , the directory "/tmp/a_source" is
    // copied into "/tmp/a_target/a_source". With an ending slash, all the files
    // present inside "/tmp/a_source" are copied inside "/tmp/a_target".
    if (utils.stats.isDirectory(source_stats.mode)) {
      const sourceEndWithSlash =
        config.source.lastIndexOf("/") === config.source.length - 1;
      if (target_stats && !sourceEndWithSlash) {
        config.target = path.resolve(
          config.target,
          path.basename(config.source)
        );
      }
      log("Source is a directory");
      const { files } = await this.fs.glob(`${config.source}/**`, {
        dot: true,
      });
      for (const source of files) {
        const target = path.resolve(
          config.target,
          path.relative(config.source, source)
        );
        const { stats } = await this.fs.stat({
          target: source,
        });
        const uid =
          config.preserve && config.uid == null ? stats.uid : config.uid;
        const gid =
          config.preserve && config.gid == null ? stats.gid : config.gid;
        const mode =
          config.preserve && config.mode == null ? stats.mode : config.mode;
        if (utils.stats.isDirectory(stats.mode)) {
          await this.fs.mkdir({
            target: target,
            uid: uid,
            gid: gid,
            mode: mode,
          });
        } else {
          await this.fs.copy({
            target: target,
            source: source,
            source_stats: stats,
            uid: uid,
            gid: gid,
            mode: mode,
          });
        }
      }
      return;
    }
    // If source is a file and target is a directory, then transform target into a file.
    if (target_stats && utils.stats.isDirectory(target_stats.mode)) {
      config.target = path.resolve(config.target, path.basename(config.source));
    }
    // Compute the source and target hash
    const { hash: hash_source } = await this.fs.hash(config.source);
    const { hash: hash_target } = await this.fs
      .hash(config.target)
      .catch((error) => {
        if (error.code === "NIKITA_FS_STAT_TARGET_ENOENT") {
          return {};
        }
        throw error;
      });
    // Copy a file if content differ from source
    if (hash_source === hash_target) {
      log(`Hash matches as '${hash_source}'`);
    } else {
      log(
        "WARN",
        `Hash dont match, source is '${hash_source}' and target is '${hash_target}'`
      );
      await this.fs.base.copy({
        source: config.source,
        target: config.target,
      });
      if ($status) {
        log(`File copied from ${config.source} into ${config.target}`);
      }
    }
    await this.fs.chown({
      $if: config.uid != null || config.gid != null,
      target: config.target,
      stats: target_stats,
      uid:
        config.preserve && config.uid == null ? source_stats.uid : config.uid,
      gid:
        config.preserve && config.gid == null ? source_stats.gid : config.gid,
    });
    await this.fs.chmod({
      $if: config.mode != null,
      target: config.target,
      stats: target_stats,
      mode:
        config.preserve && config.mode == null
          ? source_stats.mode
          : config.mode,
    });
    return {};
  },
  hooks: {
    on_action: function ({ config }) {
      config.parent ??= {};
      if (config.parent === true) {
        return (config.parent = {});
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
