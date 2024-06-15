// Dependencies
import path from "node:path";
import utils from "@nikitajs/docker/utils";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
import definitions from "./schema.json" with { type: "json" };

const errors = {
  NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED: function () {
    return utils.error("NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED", [
      "could not build the container,",
      "one of the `content` or `file` config property must be provided",
    ]);
  },
};

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Normalization
    if (config.file && config.cwd == null) {
      config.cwd = path.dirname(config.file);
    }
    if (config.cwd && config.file == null) {
      config.file = path.resolve(config.cwd, "Dockerfile");
    }
    // Retrieve previous image
    const { images: oldImages } = await this.docker.images({
      filters: {
        reference: config.tag ? `${config.image}:${config.tag}` : config.image
      }
    })
    const oldID = oldImages.length === 1 ? oldImages[0].ID : null;
    // Make sure the Dockerfile exists
    if (!config.content) {
      await this.fs.assert(config.file);
    }
    // Build the image
    const { stdout, stderr } = await this.docker.tools.execute({
      command: [
        "build",
        // arguments is a boolean
        ...["force_rm", "quiet", "no_cache"]
          .filter((opt) => !!config[opt])
          .map((opt) => `--${opt.replace("_", "-")}`),
        // arguments is an array or a string
        ...utils.array.flatten(
          ["build_arg"]
            .filter((opt) => !!config[opt])
            .map((opt) =>
              (Array.isArray(values) ? config[opt] : [config[opt]]).map(
                (value) => `--${opt.replace("_", "-")} ${esa(value)}`
              )
            )
        ),
        // arguments is a boolean string
        "--rm=" + (config.rm ? "true" : "false"),
        "-t " + esa(config.image + (config.tag ? `:${config.tag}` : "")),
        config.content != null
          ? (log({
              message:
                "Building from text: Docker won't have a context. ADD/COPY not working",
              level: "WARN",
            }),
            config.content != null
              ? `- <<DOCKERFILE\n${config.content}\nDOCKERFILE`
              : void 0)
          : config.file != null
          ? (log({
              message: `Building from Dockerfile: \"${config.file}\"`,
              level: "INFO",
            }),
            `-f ${config.file} ${config.cwd}`)
          : (log({
              message: "Building from CWD",
              level: "INFO",
            }),
            "."),
      ].join(" "),
      cwd: config.cwd,
    });
    // Extract the new image ID
    const { images: newImages } = await this.docker.images({
      filters: {
        reference: config.tag ? `${config.image}:${config.tag}` : config.image
      }
    })
    const [newImage] = newImages;
    const { ID: newID } = newImage;
    // Output
    log(
      "INFO",
      oldID !== newID
        ? `New image id ${newID}`
        : `Identical image id ${newID}`
    );
    return {
      $status: oldID !== newID,
      image_id: newID,
      stdout: stdout,
      stderr: stderr,
    };
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
  hooks: {
    on_action: function ({ config }) {
      if (config.content != null && config.file != null) {
        throw errors.NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED();
      }
    },
  },
};
