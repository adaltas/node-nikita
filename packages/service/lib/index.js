// Dependencies
import {merge} from 'mixme';
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
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
      const {started} = await this.service.status({
        $shy: true,
        name: srvname
      });
      if (!started && config.state.includes('started')) {
        await this.service.start({
          name: srvname
        });
      }
      if (started && config.state.includes('stopped')) {
        await this.service.stop({
          name: srvname
        });
      }
      if (started && config.state.includes('restarted')) {
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
