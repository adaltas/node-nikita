// Dependencies
const definitions = require('./schema.json');


// ## Handler
handler = async function({
    config,
    tools: {log}
  }) {
  const global = config.global ? '-g' : '';
  // Get installed packages
  let installed = [];
  const {stdout} = (await this.execute({
    $shy: true,
    command: `npm list --json ${global}`,
    code: [0, 1],
    cwd: config.cwd,
    stdout_log: false
  }));
  const pkgs = JSON.parse(stdout);
  if (Object.keys(pkgs).length) {
    installed = Object.keys(pkgs.dependencies);
  }
  // Uninstall
  const uninstall = config.name.filter((pkg) =>
    installed.includes(pkg)
  );
  if (!uninstall.length) {
    return;
  }
  await this.execute({
    command: `npm uninstall ${global} ${uninstall.join(' ')}`,
    cwd: config.cwd
  });
  log({
    message: `NPM uninstalled packages: ${uninstall.join(', ')}`
  });
};

// Action
module.exports = {
  handler: handler,
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
