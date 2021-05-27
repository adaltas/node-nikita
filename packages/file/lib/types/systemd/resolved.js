// Generated by CoffeeScript 2.5.1
// # `nikita.file.types.systemd.resolved`

// ## Example

// Overwrite `/usr/lib/systemd/resolved.conf.d/10_resolved.conf` in `/mnt` to set
// a list of fallback dns servers by using an array and set ReadEtcHosts to true.

// ```js
// const {$status} = await nikita.file.types.systemd.resolved({
//   target: "/etc/systemd/resolved.conf",
//   rootdir: "/mnt",
//   content:
//     FallbackDNS: ["1.1.1.1", "9.9.9.10", "8.8.8.8", "2606:4700:4700::1111"]
//     ReadEtcHosts: true
// })
// console.info(`File was overwritten: ${$status}`)
// ```

// Write to the default target file (`/etc/systemd/resolved.conf`). Set a single
// DNS server using a string and also modify the value of DNSSEC.  Note: with
// `merge` set to true, this wont overwrite the target file, only specified values
// will be updated.

// ```js
// const {$status} = await nikita.file.types.systemd.resolved({
//   content:
//     DNS: "ns0.fdn.fr"
//     DNSSEC: "allow-downgrade"
//   merge: true
// })
// console.info(`File was written: ${$status}`)
// ```

// ## Schema definitions
var definitions, handler, path;

definitions = {
  config: {
    type: 'object',
    properties: {
      'rootdir': {
        type: 'string',
        description: `Path to the mount point corresponding to the root directory, optional.`
      },
      'reload': {
        type: 'boolean',
        default: null,
        description: `Defaults to true. If set to true the following command will be
executed \`systemctl daemon-reload && systemctl restart
systemd-resolved\` after having wrote the configuration file.`
      },
      'target': {
        type: 'string',
        default: '/usr/lib/systemd/resolved.conf.d/resolved.conf',
        description: `File to write.`
      }
    }
  }
};

// This action uses `file.ini` internally, therefore it honors all
// arguments it provides. `backup` is true by default and `separator` is
// overridden by "=".

// ## Handler

// The resolved configuration file requires all its fields to be under a single
// section called "Time". Thus, everything in `content` will be automatically put
// under a "Time" key so that the user doesn't have to do it manually.
handler = async function({config}) {
  var $status;
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
  ({$status} = (await this.file.ini({
    separator: "=",
    target: config.target,
    content: {
      'Resolve': config.content
    },
    merge: config.merge
  })));
  return (await this.execute({
    $if: function() {
      if (config.reload != null) {
        return config.reload;
      } else {
        return $status;
      }
    },
    sudo: true,
    command: `systemctl daemon-reload
systemctl restart systemd-resolved`,
    trap: true
  }));
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    definitions: definitions
  }
};

// ## Dependencies
path = require('path');
