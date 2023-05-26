// Dependencies
const path = require('path');
const dedent = require('dedent');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config }) {
    if (config.rootdir) {
      // Configs
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    if (Array.isArray(config.content.DNS)) {
      config.content.DNS = config.content.DNS.join(" ");
    }
    if (Array.isArray(config.content.FallbackDNS)) {
      config.content.FallbackDNS = config.content.FallbackDNS.join(" ");
    }
    if (Array.isArray(config.content.Domains)) {
      config.content.Domains = config.content.Domains.join(" ");
    }
    // Write configuration
    const { $status } = await this.file.ini({
      separator: "=",
      target: config.target,
      content: {
        Resolve: config.content,
      },
      merge: config.merge,
    });
    await this.execute({
      $if: config.reload != null ?  config.reload : $status,
      sudo: true,
      command: dedent`
        systemctl daemon-reload
        systemctl restart systemd-resolved
      `,
      trap: true,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
