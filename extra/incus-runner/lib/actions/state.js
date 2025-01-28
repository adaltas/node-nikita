export default async function ({ config }) {
  let state = "";
  const { exists } = await this.incus.exists({
    $header: "Container exists",
    container: `${config.container}`,
  });
  if (!exists) {
    state = "NOT_CREATED";
  } else {
    ({ config: state } = await this.incus.state({
      $if: exists,
      $header: "Container state",
      container: `${config.container}`,
    }));
  }
  // process.stdout.write(JSON.stringify(state, null, 2));
  return { state: state };
}
