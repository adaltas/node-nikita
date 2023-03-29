
/*
# Plugin `@nikitajs/core/lib/plugins/execute`

Convert the execute configuration properties into metadata which are
inherited from parent actions.
*/

const {merge, mutate} = require('mixme');

module.exports = {
  name: '@nikitajs/core/lib/plugins/execute',
  require: [
    '@nikitajs/core/lib/plugins/tools/find',
    '@nikitajs/core/lib/plugins/tools/walk'
  ],
  hooks: {
    'nikita:schema': function({schema}) {
      mutate(schema.definitions.metadata.properties, {
        sudo: {
          type: 'boolean',
          description: `Run the action with as the superuser.`
        }
      });
    },
    'nikita:action': {
      handler: async function({
        config,
        metadata,
        tools: {find, walk}
      }) {
        if (metadata.module !== '@nikitajs/core/lib/actions/execute') {
          return;
        }
        if (config.arch_chroot == null) {
          config.arch_chroot = await find(
            ({metadata}) => metadata.arch_chroot
          );
        }
        if (config.arch_chroot_rootdir == null) {
          config.arch_chroot_rootdir = await find(
            ({metadata}) => metadata.arch_chroot_rootdir
          );
        }
        if (config.bash == null) {
          config.bash = await find(
            ({metadata}) => metadata.bash
          );
        }
        if (config.dry == null) {
          config.dry = await find(
            ({metadata}) => metadata.dry
          );
        }
        const env = merge(
          config.env,
          ...(await walk(({metadata}) => metadata.env))
        );
        if (Object.keys(env).length) {
          config.env = env;
        }
        if (config.env_export == null) {
          config.env_export = await find(
            ({metadata}) => metadata.env_export
          );
        }
        if (config.sudo == null) {
          config.sudo = await find(
            ({metadata}) => metadata.sudo
          );
        }
      }
    }
  }
};
