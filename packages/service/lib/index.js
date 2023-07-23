// Dependencies
const {merge} = require('mixme');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({config, parent, state}) {
    const pkgname = config.yum_name || config.name;
    const chkname = config.chk_name || config.srv_name || config.name;
    const srvname = config.srv_name || config.chk_name || config.name;
    if (pkgname) {
      // option name and yum_name are optional, skill installation if not present
      await this.service.install({
        name: pkgname,
        cache: config.cache,
        cacheonly: config.cacheonly,
        installed: config.installed,
        outdated: config.outdated,
        pacman_flags: config.pacman_flags
      });
      parent.state = merge(parent.state, state);
    }
    if (config.startup != null) {
      await this.service.startup({
        name: chkname,
        startup: config.startup
      });
    }
    if (config.state) {
      const {$status} = await this.service.status({
        $shy: true,
        name: srvname
      });
      if (!$status && config.state.includes('started')) {
        await this.service.start({
          name: srvname
        });
      }
      if ($status && config.state.includes('stopped') >= 0) {
        await this.service.stop({
          name: srvname
        });
      }
      if ($status && config.state.includes('restarted') >= 0) {
        await this.service.restart({
          name: srvname
        });
      }
    }
  },
  hooks: {
    on_action: function({config}) {
      if (typeof config.state === 'string') {
        return config.state = config.state.split(',');
      }
    }
  },
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
