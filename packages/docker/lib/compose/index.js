// Dependencies
import utils from "@nikitajs/docker/utils";
import path from "node:path";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { find, log } }) {
    // Validate parameters
    if (config.target == null && config.content == null) {
      throw Error("Missing docker-compose content or target");
    }
    let clean_target = false;
    if (config.content && config.target == null) {
      config.target ??= `/tmp/nikita_docker_compose_${Date.now()}/docker-compose.yml`;
      clean_target = true;
    }
    if (config.compose_env.length && config.target_env == null) {
      config.target_env ??= `/tmp/nikita_docker_compose_${Date.now()}/.env`;
      clean_target = true;
    }
    await this.file.yaml({
      $if: config.content != null,
      backup: config.backup,
      content: config.content,
      target: config.target,
    });
    await this.file({
      $if: config.compose_env.length,
      backup: config.backup,
      // If compose_env is an object
      // content: Object.keys(config.compose_env)
      //   .map( (key) => "#{key}=#{config.compose_env[key]}")
      //   .join('\n')
      // If compose_env is an array
      content: config.compose_env.join("\n"),
      target: config.target_env,
    });
    let { $status, stdout } = await this.docker.tools.execute({
      $shy: true,
      command: `--file ${config.target} ps -q | xargs docker ${utils.opts(
        config
      )} inspect`,
      compose: true,
      cwd: config.cwd,
      uid: config.uid,
      code: [0, 123],
      // stdout_log: false,
    });
    if (!$status) {
      $status = true;
    } else {
      const containers = JSON.parse(stdout);
      $status = containers.some((container) => !container.State.Running);
      if ($status) log("Docker created, need start");
    }
    try {
      return await this.docker.tools.execute({
        $if: config.force || $status,
        command: [
          `--file ${config.target} up`,
          config.detached ? "-d" : void 0,
          config.force ? "--force-recreate" : void 0,
          ...config.services,
        ].join(" "),
        compose: true,
        cwd: path.dirname(config.target),
        uid: config.uid,
      });
    } catch (error) {
      throw error;
    } finally {
      await this.fs.remove({
        $if: clean_target,
        target: config.target,
      });
      await this.fs.remove({
        $if: clean_target && config.target_env,
        target: config.target_env,
      });
    }
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
