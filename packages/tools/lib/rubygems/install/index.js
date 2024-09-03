// Dependencies
import semver from "semver";
import utils from "@nikitajs/tools/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { path } }) {
    const gems = {};
    if (gems[config.name] == null) {
      gems[config.name] = config.version;
    }
    // Get all current gems
    const currentGems = {};
    const { stdout } = await this.execute({
      $shy: true,
      command: `${config.gem_bin} list --versions`,
      bash: config.bash,
    });
    for (const line of utils.string.lines(stdout)) {
      if (line.trim() === "") {
        continue;
      }
      const [name, version] = line
        .match(/(.*?)(?:$| \((?:default:\s+)?([\d., ]+)\))/)
        .slice(1, 4);
      currentGems[name] = version.split(", ");
    }
    // Make array of sources and filter
    let sources =
      !config.source ?
        []
      : await (async () => {
          const { files } = await this.fs.glob(config.source);
          const current_filenames = [];
          for (const name in currentGems) {
            for (const version of currentGems[name]) {
              current_filenames.push(`${name}-${version}.gem`);
            }
          }
          return files.filter(function (source) {
            const filename = path.basename(source);
            if (!current_filenames.includes(filename)) {
              return true;
            }
          });
        })();
    // Filter gems
    for (const name in gems) {
      const version = gems[name];
      if (!currentGems[name]) {
        // Install if Gem isnt yet there
        continue;
      }
      // Install if a version is demanded and no installed version satisfy it
      const isVersionMatching = currentGems[name].some((currentVersion) =>
        semver.satisfies(version, currentVersion),
      );
      if (version && !isVersionMatching) {
        continue;
      }
      delete gems[name];
    }
    // Install from sources
    if (sources.length) {
      await this.execute({
        command: sources
          .map((source) =>
            [
              `${config.gem_bin}`,
              "install",
              config.bindir && `--bindir '${config.bindir}'`,
              config.target && `--install-dir '${config.target}'`,
              source && `--local '${source}'`,
              config.build_flags && "--build-flags config.build_flags",
            ]
              .filter(Boolean)
              .join(" "),
          )
          .join("\n"),
        code: [0, 2],
        bash: config.bash,
      });
    }
    // Install from gems
    if (Object.keys(gems).length) {
      await this.execute({
        command: Object.keys(gems)
          .map((name) => {
            const version = gems[name];
            return [
              `${config.gem_bin}`,
              "install",
              `${name}`,
              config.bindir && `--bindir '${config.bindir}'`,
              config.target && `--install-dir '${config.target}'`,
              version && `--version '${version}'`,
              config.build_flags && "--build-flags config.build_flags",
            ]
              .filter(Boolean)
              .join(" ");
          })
          .join("\n"),
        code: [0, 2],
        bash: config.bash,
      });
    }
  },
  metadata: {
    global: "ruby",
    definitions: definitions,
  },
};
