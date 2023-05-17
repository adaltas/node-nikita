// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    // note, getting the volume to make sure it exists
    const { $status: volumeExists, data: volume } =
      await this.lxc.storage.volume.get({
        pool: config.pool,
        name: config.name,
        type: config.type,
      });
    if (!volumeExists) {
      throw new Error(`NIKITA_LXD_VOLUME_ATTACH: volume ${JSON.stringify(config.name)} does not exist.`);
    }
    // note, getting the container to make sure it exists
    const { $status: containerExists, data: container } = await this.lxc.info(
      config.container,
      { $relax: true }
    );
    if (!containerExists) {
      throw new Error(`NIKITA_LXD_VOLUME_ATTACH: container ${JSON.stringify(config.container)} does not exist.`);
    }
    switch (container.type) {
      case 'virtual-machine':
        if (volume.content_type === "filesystem") {
          throw new Error(`Type: ${container.type} can only mount block type volumes.`);
        }
        break;
      case 'container':
        if (volume.content_type === "block") {
          throw new Error(`Type: ${container.type} can only mount filesystem type volumes.`);
        }
    }
    if (volume.content_type === "filesystem" && (config.path == null)) {
      throw new Error("Missing requirement: Path is required for filesystem type volumes.");
    }
    const {$status} = await this.lxc.query({
      path: `/1.0/instances/${config.container}`,
      request: 'PATCH',
      data: JSON.stringify({
        devices: {
          [`${config.device}`]: {
            pool: config.pool,
            source: config.name,
            type: "disk",
            path: config.path != null ? config.path : null
          }
        }
      }),
      wait: true,
      format: "string",
      code: [0, 1]
    });
    return {
      $status: $status
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
