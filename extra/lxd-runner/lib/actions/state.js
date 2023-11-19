export default async function({config}) {
  const {config: state} = await this.lxc.state({
    $header: 'Container state',
    container: `${config.container}`
  });
  process.stdout.write(JSON.stringify(state, null, 2));
};
