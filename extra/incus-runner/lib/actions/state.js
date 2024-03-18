export default async function({config}) {
  const {config: state} = await this.incus.state({
    $header: 'Container state',
    container: `${config.container}`
  });
  process.stdout.write(JSON.stringify(state, null, 2));
};
