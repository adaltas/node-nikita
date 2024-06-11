// Dependencies
import crypto from "crypto";
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" with { type: "json" };

const errors = {
  NIKITA_FS_HASH_FILETYPE_UNSUPPORTED: function ({ config, stats }) {
    return utils.error(
      "NIKITA_FS_HASH_FILETYPE_UNSUPPORTED",
      [
        'only "File" and "Directory" types are supported,',
        `got ${JSON.stringify(utils.stats.type(stats.mode))},`,
        `location is ${JSON.stringify(config.target)}`,
      ],
      {
        target: config.target,
      }
    );
  },
  NIKITA_FS_HASH_MISSING_OPENSSL: function () {
    return utils.error("NIKITA_FS_HASH_MISSING_OPENSSL", [
      "the `openssl` command must be present on your system,",
      "please install it before pursuing",
    ]);
  },
  NIKITA_FS_HASH_HASH_NOT_EQUAL: function ({ config, hash }) {
    return utils.error(
      "NIKITA_FS_HASH_HASH_NOT_EQUAL",
      [
        "the target hash does not equal the execpted value,",
        `got ${JSON.stringify(hash)},`,
        `expected ${JSON.stringify(config.hash)}`,
      ],
      {
        target: config.target,
      }
    );
  },
};

// Action
export default {
  handler: async function ({ config }) {
    const { stats } = config.stats
      ? config.stats
      : await this.fs.base.stat(config.target);
    if (
      !utils.stats.isFile(stats.mode) &&
      !utils.stats.isDirectory(stats.mode)
    ) {
      throw errors.NIKITA_FS_HASH_FILETYPE_UNSUPPORTED({
        config: config,
        stats: stats,
      });
    }
    const hash = await (async () => {
      // Target is a directory
      if (utils.stats.isDirectory(stats.mode)) {
        const { files } = await this.fs.glob(`${config.target}/**`, {
          dot: true,
        });
        const { stdout } = await this.execute({
          command: [
            "command -v openssl >/dev/null || exit 2",
            ...files.map(
              (file) =>
                `[ -f ${file} ] && openssl dgst -${config.algo} ${file} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'`
            ),
            "exit 0",
          ].join("\n"),
          trim: true,
        }).catch((error) => {
          if (error.exit_code === 2) {
            throw errors.NIKITA_FS_HASH_MISSING_OPENSSL();
          }
          throw error;
        });
        const hashs = utils.string
          .lines(stdout)
          .filter((line) => /\w+/.test(line))
          .sort();
        return hashs.length === 0
          ? crypto.createHash(config.algo).update("").digest("hex")
          : hashs.length === 1
          ? hashs[0]
          : crypto.createHash(config.algo).update(hashs.join("")).digest("hex");
        // Target is a file
      } else if (utils.stats.isFile(stats.mode)) {
        const { stdout: hash } = await this.execute({
          command: dedent`
            command -v openssl >/dev/null || exit 2
            openssl dgst -${config.algo} ${config.target} | sed 's/^.* \([a-z0-9]*\)$/\1/g'
          `,
          trim: true,
        }).catch((error) => {
          if (error.exit_code === 2) {
            throw errors.NIKITA_FS_HASH_MISSING_OPENSSL();
          }
          throw error;
        });
        return hash;
      }
    })();
    if (config.hash && config.hash !== hash) {
      throw errors.NIKITA_FS_HASH_HASH_NOT_EQUAL({
        config: config,
        hash: hash,
      });
    }
    return {
      hash: hash,
    };
  },
  metadata: {
    argument_to_config: "target",
    shy: true,
    definitions: definitions,
  },
};
