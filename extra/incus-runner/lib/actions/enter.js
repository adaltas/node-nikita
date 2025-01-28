export default async function ({ config }) {
  // Note, using `incus shell` would be nice but `cwd` doesn't seem right
  // `incus shell --cwd /nikita/packages/$pkg` then `pwd` return `/root`
  // `incus shell --cwd /nikita/packages/$pkg -- pkg` prints:
  //   `pwd: ignoring non-option arguments`
  //   `/nikita/packages/$pkg`
  await this.execute({
    $header: "Container enter",
    // To be tested
    // command: `incus shell --cwd ${config.cwd} ${config.container}`,
    command: `incus exec --cwd ${config.cwd} ${config.container} -- bash`,
    stdio: ["inherit", "inherit", "inherit"],
    stdin: process.stdin,
    stdout: process.stdout,
    stderr: process.stderr,
  });
}
