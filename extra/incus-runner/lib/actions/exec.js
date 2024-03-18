export default async function({config}) {
  // Note, using `incus shell` would be nice but `cwd` doesn't seem right
  // `incus shell --cwd /nikita/packages/$pkg` then `pwd` return `/root`
  // `incus shell --cwd /nikita/packages/$pkg -- pkg` prints:
  //   `pwd: ignoring non-option arguments`
  //   `/nikita/packages/$pkg`
  await this.execute({
    $header: 'Container exec',
    command: `incus exec --cwd ${config.cwd} ${config.container} -- ${config.cmd}`,
    stdio: ['inherit', 'inherit', 'inherit'],
    stdin: process.stdin,
    stdout: process.stdout,
    stderr: process.stderr
  });
};
