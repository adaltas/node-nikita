// Dependencies
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { $status, log, path } }) {
    // Retrieve stats information about the source unless provided through the "source_stats" option.
    const source_stats = await ( async () => {
      if (config.source_stats) {
        log({
          message: "Source Stats: using short circuit",
          level: "DEBUG",
        });
        return config.source_stats;
      } else {
        log({
          message: `Stats source file ${config.source}`,
          level: "DEBUG",
        });
        const { stats } = await this.fs.base.stat({
          target: config.source,
        });
        return stats;
      }
    })()
    // Retrieve stat information about the traget unless provided through the "target_stats" option.
    let target_stats = await ( async () => {
      if (config.target_stats) {
        log({
          message: "Target Stats: using short circuit",
          level: "DEBUG",
        });
        return config.target_stats;
      } else {
        log({
          message: `Stats target file ${config.target}`,
          level: "DEBUG",
        });
        try {
          const { stats } = await this.fs.base.stat({
            target: config.target,
          });
          return stats;
        } catch (error) {
          if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
            // Target file doesn't necessarily exist
            throw error;
          }
        }
      }
    })()
    // Create target parent directory if target does not exists and if the "parent"
    // config is set to "true" (default) or as an object.
    await this.fs.mkdir(
      {
        $if: !!config.parent,
        $unless: target_stats,
        $shy: true,
        target: path.dirname(config.target),
      },
      config.parent
    );
    // Stop here if source is a directory. We traverse all its children
    // Recursively, calling either `fs.mkdir` or `fs.copy`.
    // Like with the Unix `cp` command, ending slash matters if the target directory
    // exists. Let's consider a source directory "/tmp/a_source" and a target directory
    // "/tmp/a_target". Without an ending slash , the directory "/tmp/a_source" is
    // copied into "/tmp/a_target/a_source". With an ending slash, all the files
    // present inside "/tmp/a_source" are copied inside "/tmp/a_target".
    const res = await this.call(
      {
        $shy: true,
      },
      async function () {
        if (!utils.stats.isDirectory(source_stats.mode)) {
          return;
        }
        const sourceEndWithSlash =
          config.source.lastIndexOf("/") === config.source.length - 1;
        if (target_stats && !sourceEndWithSlash) {
          config.target = path.resolve(
            config.target,
            path.basename(config.source)
          );
        }
        log({
          message: "Source is a directory",
          level: "INFO",
        });
        const { files } = await this.fs.glob(`${config.source}/**`, {
          dot: true,
        });
        for(const source of files){
          await (async (source) => {
            const target = path.resolve(
              config.target,
              path.relative(config.source, source)
            );
            const { stats } = await this.fs.base.stat({
              target: source,
            });
            let uid = config.uid;
            if (config.preserve) {
              if (uid == null) {
                uid = stats.uid;
              }
            }
            let gid = config.gid;
            if (config.preserve) {
              if (gid == null) {
                gid = stats.gid;
              }
            }
            let mode = config.mode;
            if (config.preserve) {
              if (mode == null) {
                mode = stats.mode;
              }
            }
            if (utils.stats.isDirectory(stats.mode)) {
              return await this.fs.mkdir({
                target: target,
                uid: uid,
                gid: gid,
                mode: mode,
              });
            } else {
              return await this.fs.copy({
                target: target,
                source: source,
                source_stats: stats,
                uid: uid,
                gid: gid,
                mode: mode,
              });
            }
          })(source);
        }
        return {
          end: true,
        };
      }
    );
    if (res.end) {
      return res.$status;
    }
    // If source is a file and target is a directory, then transform target into a file.
    await this.call(
      {
        $shy: true,
      },
      function () {
        if (!(target_stats && utils.stats.isDirectory(target_stats.mode))) {
          return;
        }
        return (config.target = path.resolve(
          config.target,
          path.basename(config.source)
        ));
      }
    );
    // Compute the source and target hash
    const { hash: hash_source } = await this.fs.hash(config.source);
    let hash_target;
    try {
      ({ hash: hash_target } = await this.fs.hash(config.target));
    } catch (error) {
      if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
        throw error;
      }
    }
    // Copy a file if content differ from source
    if (hash_source === hash_target) {
      log({
        message: `Hash matches as '${hash_source}'`,
        level: "INFO",
      });
    } else {
      log({
        message: `Hash dont match, source is '${hash_source}' and target is '${hash_target}'`,
        level: "WARN",
      });
      await this.fs.base.copy({
        source: config.source,
        target: config.target,
      });
      if ($status) {
        log({
          message: `File copied from ${config.source} into ${config.target}`,
          level: "INFO",
        });
      }
    }
    if (config.preserve) {
      // File ownership and permissions
      if (config.uid == null) {
        config.uid = source_stats.uid;
      }
    }
    if (config.preserve) {
      if (config.gid == null) {
        config.gid = source_stats.gid;
      }
    }
    if (config.preserve) {
      if (config.mode == null) {
        config.mode = source_stats.mode;
      }
    }
    await this.fs.chown({
      $if: config.uid != null || config.gid != null,
      target: config.target,
      stats: target_stats,
      uid: config.uid,
      gid: config.gid,
    });
    await this.fs.chmod({
      $if: config.mode != null,
      target: config.target,
      stats: target_stats,
      mode: config.mode,
    });
    return {};
  },
  hooks: {
    on_action: function({config}) {
      if (config.parent == null) {
        config.parent = {};
      }
      if (config.parent === true) {
        return config.parent = {};
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
