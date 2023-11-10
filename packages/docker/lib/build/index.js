// Dependencies
const path = require("path");
const utils = require("../utils");
const definitions = require("./schema.json");
const esa = utils.string.escapeshellarg;

const errors = {
  NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED: function () {
    return utils.error("NIKITA_DOCKER_BUILD_CONTENT_FILE_REQUIRED", [
      "could not build the container,",
      "one of the `content` or `file` config property must be provided",
    ]);
  },
};

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    var k, line;
    let number_of_step = 0;
    // status unmodified if final tag already exists
    const dockerfile_commands = [
      "CMD",
      "LABEL",
      "EXPOSE",
      "ENV",
      "ADD",
      "COPY",
      "ENTRYPOINT",
      "VOLUME",
      "USER",
      "WORKDIR",
      "ARG",
      "ONBUILD",
      "RUN",
      "STOPSIGNAL",
      "MAINTAINER",
    ];
    if (config.file && config.cwd == null) {
      config.cwd = path.dirname(config.file);
    }
    if (config.cwd && config.file == null) {
      config.file = path.resolve(config.cwd, "Dockerfile");
    }
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
    // Get the content of the Dockerfile
    if (config.content) {
      await this.file({
        content: config.content,
        source: config.file,
        target: ({ content }) => config.content = content,
        from: config.from,
        to: config.to,
        match: config.match,
        replace: config.replace,
        append: config.append,
        before: config.before,
        write: config.write,
      });
    } else {
      // Read Dockerfile if necessary to count steps
      log({
        message: `Reading Dockerfile from : ${config.file}`,
        level: "INFO",
      });
      ({ data: config.content } = await this.fs.base.readFile({
        target: config.file,
        encoding: "utf8",
      }));
    }
    const contentLines = utils.string.lines(config.content);
    // Count steps
    for (const line of contentLines) {
      const [_, cmd] = /^(.*?)\s/.exec(line);
      if (dockerfile_commands.includes(cmd)) {
        number_of_step++;
      }
    }
    let image_id = null;
    // Count cache
    const lines = utils.string.lines(stdout);
    let number_of_cache = 0;
    for (k in lines) {
      line = lines[k];
      if (line.indexOf("Using cache") !== -1) {
        number_of_cache = number_of_cache + 1;
      }
      if (line.indexOf("Successfully built") !== -1) {
        image_id = line.split(" ").pop().toString();
      }
    }
    const userargs = {
      $status: number_of_step !== number_of_cache,
      image: image_id,
      stdout: stdout,
      stderr: stderr,
    };
    log(
      userargs.$status
        ? {
            message: `New image id ${userargs.image}`,
            level: "INFO",
            module: "nikita/lib/docker/build",
          }
        : {
            message: `Identical image id ${userargs.image}`,
            level: "INFO",
            module: "nikita/lib/docker/build",
          }
    );
    return userargs;
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
