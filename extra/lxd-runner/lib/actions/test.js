export default async function({config}) {
  // @lxc.exec
  //   container: "#{config.container}"
  //   cwd: "#{config.cwd}"
  //   command: 'npm run test:local'
  //   shell: 'bash -l'
  await this.execute({
    stdout: process.stdout,
    env: process.env,
    command: [
      'lxc exec',
      `--cwd ${config.cwd}`,
      // Note, core ssh env log in as "source" user
      config.test_user ? `--user ${config.test_user}` : void 0,
      `${config.container} --`,
      'bash -l -c "npm run test:local"'
    ].join(' ')
  });
};
