export default async function({config}) {
  await this.lxc.stop({
    $header: 'Container stop',
    container: `${config.container}`
  });
};
