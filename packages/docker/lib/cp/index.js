// Dependencies
import utils from "@nikitajs/docker/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { path } }) {
    let [, source_container, source_path] = /(.*:)?(.*)/.exec(config.source);
    let [, target_container, target_path] = /(.*:)?(.*)/.exec(config.target);
    if (source_container && target_container) {
      throw Error("Incompatible source and target config");
    }
    if (!source_container && !target_container) {
      throw Error("Incompatible source and target config");
    }
    const source_mkdir = false;
    let target_mkdir = false;
    // Source is on the host, normalize path
    if (!source_container) {
      if (/\/$/.test(source_path)) {
        source_path = path.join(source_path, path.basename(target_path));
      }
      try {
        const { stats } = await this.fs.stat({
          target: source_path,
        });
        if (utils.stats.isDirectory(stats.mode)) {
          source_path = path.join(source_path, path.basename(target_path));
        }
      } catch (error) {
        if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
          throw error;
        }
        // TODO wdavidw: seems like a mistake to me, we shall have source_mkdir instead
        target_mkdir = true;
      }
    }
    await this.fs.mkdir({
      $if: source_mkdir,
      target: source_path,
    });
    // Destination is on the host
    if (!target_container) {
      if (/\/$/.test(target_path)) {
        target_path = `${target_path}/${path.basename(target_path)}`;
      }
      try {
        const { stats } = await this.fs.stat({
          target: target_path,
        });
        if (utils.stats.isDirectory(stats.mode)) {
          target_path = `${target_path}/${path.basename(target_path)}`;
        }
      } catch (error) {
        if (error.code !== "NIKITA_FS_STAT_TARGET_ENOENT") {
          throw error;
        }
        target_mkdir = true;
      }
    }
    await this.fs.base.mkdir({
      $if: target_mkdir,
      target: target_path,
    });
    await this.docker.tools.execute({
      command: `cp ${config.source} ${config.target}`,
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
