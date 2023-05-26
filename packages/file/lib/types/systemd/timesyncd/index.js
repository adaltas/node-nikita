// Dependencies
const path = require('path');
const dedent = require('dedent');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    if (Array.isArray(config.content.NTP)) {
      config.content.NTP = config.content.NTP.join(" ");
    }
    if (Array.isArray(config.content.FallbackNTP)) {
      config.content.FallbackNTP = config.content.FallbackNTP.join(" ");
    }
    // Write configuration
    const {$status} = (await this.file.ini({
      separator: "=",
      target: config.target,
      content: {
        'Time': config.content
      },
      merge: config.merge
    }));
    await this.execute({
      $if: config.reload != null ? config.reload : $status,
      sudo: true,
      command: dedent`
        systemctl daemon-reload
        systemctl restart systemd-timesyncd
      `,
      trap: true,
    });
  },
  metadata: {
    definitions: definitions
  }
};
