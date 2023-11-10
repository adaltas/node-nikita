// Dependencies
const dedent = require("dedent");
const definitions = require("./schema.json");

// ## Schema definitions
var handler, utils;

// ## Handler
handler = async function ({ config, tools: { log } }) {
  // Validate parameters
  if (config.input == null) {
    config.input = config.source;
  }
  if (config.input == null) {
    throw Error("Missing input parameter");
  }
  // need to records the list of image to see if status is modified or not after load
  // for this we print the existing images as REPOSITORY:TAG:IMAGE
  // parse the result to record images as an array of   {'REPOSITORY:TAG:'= 'IMAGE'}
  log("DEBUG", "Storing previous state of image");
  if (config.checksum == null) {
    log("DEBUG", "No checksum provided");
  } else {
    log("INFO", `Checksum provided :${config.checksum}`);
  }
  if (config.checksum == null) {
    config.checksum = "";
  }
  // Load registered image and search for a matching ID
  let checksumExists = false;
  let images = await this.docker.tools
    .execute({
      format: "jsonlines",
      command: `images --filter dangling=false --format '{{json .}}'`,
    })
    .then(({ data }) => data)
    .then((images) =>
      images.map((img) => {
        if (img.ID === config.checksum) {
          log(
            "INFO",
            `Image already exist checksum :${config.checksum}, repo:tag \"${img.Repository}:${img.Tag}\"`
          );
          checksumExists = true;
        }
        return `${img.Repository}:${img.Tag}#${img.ID}`;
      })
    );
  // Stop here if matching ID is found
  if (checksumExists) {
    return false;
  }
  // Load the image and extract its name
  log("INFO", `Start Loading image ${config.input} and extract its name`);
  const { data: name, stdout } = await this.docker.tools.execute({
    command: `load -i ${config.input}`,
    format: ({ stdout }) => /^.*\s(.*)$/.exec(stdout.trim())[1],
  });
  const { data: imageInfo } = await this.docker.tools.execute({
    command: `image ls --format '{{json .}}' ${name}`,
    format: "json",
  });
  let status = !images.includes(
    `${imageInfo.Repository}:${imageInfo.Tag}#${imageInfo.ID}`
  );
  return {
    $status: status,
  };
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};

// ## Dependencies
utils = require("../utils");
